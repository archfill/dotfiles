-- Window Group Module
-- Provides Hyprland-style window grouping with a tab bar.
--
-- Structure:
--   state.lua  - Pure state and the functions that change it (no hs.*)
--   store.lua  - Saving / loading the state as JSON
--   tabbar.lua - Tab bar drawing (stateless)
--   init.lua   - Hotkeys (modal), window events, wiring (this file)
--
-- Keys: Hyper + <toggle> enters a short-lived modal, then:
--   <toggle>  create a group from the focused window / dissolve its group
--   h/j/k/l   put the focused window into the group in that direction
--   <out>     take the focused window out of its group
-- Hyper + <next> / <prev> cycle inside the group of the focused window.

local state = require("modules.groups.state")
local store = require("modules.groups.store")
local tabbar = require("modules.groups.tabbar")
local windows = require("modules.windows")

local groups = {}

local MODAL_TIMEOUT = 1 -- seconds before the modal exits by itself
local FRAME_TOLERANCE = 2 -- px; smaller frame differences are ignored
local FOLLOW_INTERVAL = 0.03 -- seconds; at most one follow-up move per interval while dragging
local SAVE_DELAY = 0.5 -- seconds; save once after moves have stopped

local st = state.new()
local statePath = store.DEFAULT_PATH

-- Focus tracking for autoJoinNewWindows
local currentFocusedId = nil
local previousFocusedId = nil

--- Look up a window by id
local function getWindow(id)
	return hs.window.get(id)
end

--- Get app name for window
local function getAppName(win)
	local app = win and win:application()
	return app and app:name() or "?"
end

-- Move watchers on group members (window id -> hs.uielement.watcher).
-- hs.window.filter's windowMoved event is delayed until 0.5 s after the last
-- move, so members followed the active window late. These watchers get the
-- accessibility notifications directly.
local moveWatchers = {}
local onMemberMoved -- defined below

local function syncMoveWatchers()
	for id, watcher in pairs(moveWatchers) do
		if not st.windowToGroup[id] then
			watcher:stop()
			moveWatchers[id] = nil
		end
	end
	for id in pairs(st.windowToGroup) do
		if not moveWatchers[id] then
			local win = hs.window.get(id)
			if win then
				local watcher = win:newWatcher(function(element)
					onMemberMoved(element, id)
				end)
				watcher:start({ hs.uielement.watcher.windowMoved, hs.uielement.watcher.windowResized })
				moveWatchers[id] = watcher
			end
		end
	end
end

local saveTimer = nil

local function save()
	if saveTimer then
		saveTimer:stop()
		saveTimer = nil
	end
	store.write(statePath, state.serialize(st))
	syncMoveWatchers()
end

--- Save after moves have stopped (used while dragging)
local function saveSoon()
	if saveTimer then
		saveTimer:setNextTrigger(SAVE_DELAY)
	else
		saveTimer = hs.timer.doAfter(SAVE_DELAY, function()
			saveTimer = nil
			save()
		end)
	end
end

--- Redraw the tab bar for the focused window (or the given id)
local function refresh(focusedId)
	if focusedId == nil then
		local win = hs.window.focusedWindow()
		focusedId = win and win:id()
	end
	tabbar.update(st, focusedId, getWindow)
end

local function sameFrame(a, b)
	return math.abs(a.x - b.x) <= FRAME_TOLERANCE
		and math.abs(a.y - b.y) <= FRAME_TOLERANCE
		and math.abs(a.w - b.w) <= FRAME_TOLERANCE
		and math.abs(a.h - b.h) <= FRAME_TOLERANCE
end

--- Apply the group frame to every member whose frame differs
local function applyFrame(groupId, exceptId)
	local group = st.groups[groupId]
	for _, id in ipairs(group.windowIds) do
		if id ~= exceptId then
			local win = getWindow(id)
			if win and not sameFrame(win:frame(), group.frame) then
				win:setFrame(group.frame, 0)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

--- Create a group from the focused window, or dissolve its group
local function toggleGroup()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No window", 0.5)
		return
	end

	local id = win:id()
	local groupId = state.groupOf(st, id)
	if groupId then
		state.dissolve(st, groupId)
		hs.alert.show("Group dissolved", 0.5)
	else
		state.createGroup(st, id, win:frame())
		hs.alert.show("New group: " .. getAppName(win), 0.5)
	end
	save()
	refresh(id)
end

--- Put the focused window into the group in a direction
local function addToDirection(direction)
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No window", 0.5)
		return
	end

	local target = windows.windowInDirection(win, direction)
	local groupId = target and state.groupOf(st, target:id())
	if not groupId then
		hs.alert.show("No group", 0.5)
		return
	end

	local id = win:id()
	if state.groupOf(st, id) == groupId then
		return
	end

	-- addWindow also takes the window out of its previous group
	state.addWindow(st, groupId, id)
	win:setFrame(st.groups[groupId].frame, 0)
	save()
	refresh(id)
	hs.alert.show("Added: " .. getAppName(win) .. " (#" .. #st.groups[groupId].windowIds .. ")", 0.5)
end

--- Take the focused window out of its group
local function moveOut()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local id = win:id()
	if not state.removeWindow(st, id) then
		return
	end
	save()
	refresh(id)
	hs.alert.show("Removed: " .. getAppName(win), 0.5)
end

--- Focus the next (step = 1) or previous (step = -1) window in the group
local function cycle(step)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local id = win:id()
	local groupId = state.groupOf(st, id)
	if not groupId then
		return
	end

	-- Skip members that no longer exist
	local candidateId = id
	for _ = 1, #st.groups[groupId].windowIds do
		candidateId = state.nextId(st, candidateId, step)
		if candidateId == id then
			return
		end
		local target = getWindow(candidateId)
		if target then
			state.setActive(st, candidateId)
			save()
			windows.focusWindow(target)
			refresh(candidateId)
			return
		end
		state.removeWindow(st, candidateId)
		save()
		-- The window is gone; continue from the current window
		candidateId = id
	end
	refresh(id)
end

--------------------------------------------------------------------------------
-- Window events
--------------------------------------------------------------------------------

local function onFocused(win)
	local id = win:id()
	if not id then
		return
	end
	previousFocusedId = currentFocusedId
	currentFocusedId = id
	if state.setActive(st, id) then
		save()
	end
	refresh(id)
end

local function onDestroyed(win)
	local id = win:id()
	if id and state.removeWindow(st, id) then
		save()
		refresh()
	end
end

--- Make the group follow its active member (id) if that member moved
local function followActive(id)
	local groupId = state.groupOf(st, id)
	if not groupId then
		return
	end
	local group = st.groups[groupId]

	-- Only the active member drives the group. This also stops the events
	-- caused by our own setFrame on the other members from coming back.
	if group.activeId ~= id then
		return
	end
	local win = getWindow(id)
	if not win then
		return
	end
	local frame = win:frame()
	if sameFrame(frame, group.frame) then
		return
	end

	state.setFrame(st, groupId, frame)
	applyFrame(groupId, id)
	saveSoon()
	refresh(id)
end

-- Throttle while dragging: follow at most once per FOLLOW_INTERVAL, and once
-- more at the end so the last position is applied.
local followTimer = nil
local followPendingId = nil

function onMemberMoved(_, id)
	if followTimer then
		followPendingId = id
		return
	end
	followActive(id)
	followTimer = hs.timer.doAfter(FOLLOW_INTERVAL, function()
		followTimer = nil
		local pending = followPendingId
		followPendingId = nil
		if pending then
			onMemberMoved(nil, pending)
		end
	end)
end

local function onCreated(win)
	local id = win:id()
	if not id or state.groupOf(st, id) then
		return
	end
	-- The new window may already be reported as focused
	local baseId = (currentFocusedId ~= id) and currentFocusedId or previousFocusedId
	local groupId = baseId and state.groupOf(st, baseId)
	if not groupId then
		return
	end
	state.addWindow(st, groupId, id)
	win:setFrame(st.groups[groupId].frame, 0)
	save()
	refresh(id)
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------

--- Load the saved state and drop windows that no longer exist
local function loadState()
	local loaded = state.deserialize(store.read(statePath))
	st = loaded or state.new()
	if state.prune(st, function(id)
		return getWindow(id) ~= nil
	end) then
		save()
	end
end

--- Initialize group module
function groups.init(config, helpers)
	local hyper = config.hyper
	local groupConfig = config.groups or {}

	if groupConfig.enabled == false then
		return
	end

	local keys = groupConfig.keys or {}
	local toggleKey = keys.toggle or "g"
	local outKey = keys.out or "o"
	local nextKey = keys.next or "n"
	local prevKey = keys.prev or "p"
	statePath = groupConfig.stateFile or store.DEFAULT_PATH

	local windowConfig = config.windows or {}
	local directionKeys = windowConfig.directionalFocusKeys or { h = "west", j = "south", k = "north", l = "east" }

	loadState()

	-- Next / previous
	hs.hotkey.bind(hyper, nextKey, function()
		cycle(1)
	end)
	hs.hotkey.bind(hyper, prevKey, function()
		cycle(-1)
	end)

	-- Modal: Hyper + toggleKey, then one of the operation keys
	local dirLetters = {}
	for key in pairs(directionKeys) do
		dirLetters[#dirLetters + 1] = key:upper()
	end
	table.sort(dirLetters)
	local helpText = ("Group: %s / %s / %s"):format(toggleKey:upper(), table.concat(dirLetters), outKey:upper())

	local modal = hs.hotkey.modal.new(hyper, toggleKey)
	local modalTimer = nil
	local modalAlert = nil
	local modalTap = nil

	function modal:entered()
		modalAlert = hs.alert.show(helpText, MODAL_TIMEOUT + 1)
		modalTimer = hs.timer.doAfter(MODAL_TIMEOUT, function()
			modal:exit()
		end)
		-- Another Hyper key press leaves the modal and still reaches its own binding
		modalTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
			local flags = event:getFlags()
			if flags.ctrl and flags.cmd and flags.alt and flags.shift then
				hs.timer.doAfter(0, function()
					modal:exit()
				end)
			end
			return false
		end)
		modalTap:start()
	end

	function modal:exited()
		if modalTimer then
			modalTimer:stop()
			modalTimer = nil
		end
		if modalTap then
			modalTap:stop()
			modalTap = nil
		end
		if modalAlert then
			hs.alert.closeSpecific(modalAlert, 0)
			modalAlert = nil
		end
	end

	local function bindModal(key, fn)
		modal:bind({}, key, function()
			modal:exit()
			fn()
		end)
	end

	modal:bind({}, "escape", function()
		modal:exit()
	end)
	bindModal(toggleKey, toggleGroup)
	bindModal(outKey, moveOut)
	for key, direction in pairs(directionKeys) do
		bindModal(key, function()
			addToDirection(direction)
		end)
	end

	-- Window events (standard windows only, all spaces)
	local wf = hs.window.filter.new():setDefaultFilter({ allowRoles = "AXStandardWindow" })
	wf:subscribe(hs.window.filter.windowFocused, onFocused)
	wf:subscribe(hs.window.filter.windowDestroyed, onDestroyed)
	-- Moves are watched per member (syncMoveWatchers), not with windowMoved,
	-- because windowMoved is delayed by 0.5 s
	syncMoveWatchers()
	if groupConfig.autoJoinNewWindows then
		wf:subscribe(hs.window.filter.windowCreated, onCreated)
	end
	groups.windowFilter = wf -- keep a reference so it is not garbage collected

	-- Initial tab bar
	local focused = hs.window.focusedWindow()
	currentFocusedId = focused and focused:id()
	refresh(currentFocusedId)
end

return groups
