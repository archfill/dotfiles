-- Window Management Module
-- Provides window manipulation features: temporary maximize toggle, ultrawide
-- layouts (70/30), directional focus.
-- Modifier + drag move/resize is done by BetterTouchTool: Control + click does
-- not reach Hammerspoon's eventtap (it is handled earlier as a secondary click).

local keymodal = require("modules.keymodal")
local keymap = require("modules.keymap")

local windows = {}

-- Store previous window frames for restore
local previousFrames = {}

--- Toggle temporary maximize
--- If window is maximized, restore to previous position
--- If window is not maximized, save position and maximize
local function toggleMaximize()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local id = win:id()
	local screen = win:screen()
	local maxFrame = screen:frame()
	local currentFrame = win:frame()

	-- Check if window is already maximized (with small tolerance)
	local isMaximized = math.abs(currentFrame.w - maxFrame.w) < 10 and math.abs(currentFrame.h - maxFrame.h) < 10

	if previousFrames[id] and isMaximized then
		-- Restore to previous position
		win:setFrame(previousFrames[id])
		previousFrames[id] = nil
	else
		-- Save current position and maximize
		previousFrames[id] = currentFrame
		win:maximize()
	end
end

-- Window filter for directional focus (created once, reused)
local windowFilter = nil

-- Pending focus check after a directional focus (see focusDirection)
local focusCheckTimer = nil

--------------------------------------------------------------------------------
-- Mouse follows keyboard focus (like Hyprland's default cursor warp)
--------------------------------------------------------------------------------

-- Set from config.windows.mouseFollowsFocus in windows.init
local mouseFollowsFocus = false

-- Focus changes by keyboard can scroll the wrong window on macOS: scrolling
-- goes to the window under the cursor, not the focused one.

--- Move the cursor to the center of a window, unless it is already inside it
--- (so a window focused by clicking never moves the cursor).
--- @param win hs.window|nil
function windows.moveMouseInto(win)
	if not mouseFollowsFocus or not win then
		return
	end
	local frame = win:frame()
	local pos = hs.mouse.absolutePosition()
	if pos.x >= frame.x and pos.x < frame.x + frame.w and pos.y >= frame.y and pos.y < frame.y + frame.h then
		return
	end
	hs.mouse.absolutePosition({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
end

-- For focus changes made by code we cannot hook into (hs.window.switcher
-- focuses the window when the modifiers are released): move the cursor on the
-- next focus change within a short time.
local WARP_WINDOW = 3 -- seconds
local warpUntil = nil
local warpFilter = nil

function windows.moveMouseOnNextFocus()
	if not mouseFollowsFocus then
		return
	end
	warpUntil = hs.timer.secondsSinceEpoch() + WARP_WINDOW
	if not warpFilter then
		warpFilter = hs.window.filter.new():setDefaultFilter({ allowRoles = "AXStandardWindow" })
		warpFilter:subscribe(hs.window.filter.windowFocused, function(win)
			if warpUntil and hs.timer.secondsSinceEpoch() <= warpUntil then
				warpUntil = nil
				windows.moveMouseInto(win)
			end
		end)
	end
end

--- Get or create window filter for current space
--- @return hs.window.filter
local function getWindowFilter()
	if not windowFilter then
		-- Create filter: current space only, exclude problematic windows.
		-- Only AXStandardWindow: menu bar panels and notification widgets are excluded.
		windowFilter = hs.window.filter.new()
			:setCurrentSpace(true)
			:setDefaultFilter({ allowRoles = "AXStandardWindow" })
			:rejectApp("Finder") -- Exclude Finder (often has invisible desktop window)
	end
	return windowFilter
end

--- Pick the first candidate window in a direction.
--- Uses hs.window.filter for better performance and filtering.
--- Also used by modules.groups to choose the group in a direction.
--- @param win hs.window Origin window
--- @param direction string Direction: "west", "east", "north", "south"
--- @return hs.window|nil
function windows.windowInDirection(win, direction)
	local wf = getWindowFilter()

	-- frontmost = true: only windows that are not fully hidden behind others.
	-- macOS windows overlap (unlike a tiling WM such as Hyprland), so without
	-- this the nearest window can be one hidden behind the focused window.
	-- strict = true: only windows within ±45° of the direction. Without it, a
	-- window just below the focused one whose center is a few pixels to the
	-- right counts as "east" and gets focus before the window that is
	-- actually to the right.
	local frontmost, strict = true, true
	local method = ({
		west = "windowsToWest",
		east = "windowsToEast",
		north = "windowsToNorth",
		south = "windowsToSouth",
	})[direction]
	if not method then
		return nil
	end
	local candidates = wf[method](wf, win, frontmost, strict)
	return candidates[1]
end

--- Focus a window reliably.
--- Used instead of wf:focusWindow<Dir>(): when the app has several windows
--- (e.g. Chrome on two screens), activating the app can bring its other window
--- to the front. Raise the target first, then check shortly after and focus it
--- again if another window took focus. Cancel the check from a previous call,
--- so that a quick second press is not pulled back to the first target.
--- @param target hs.window
function windows.focusWindow(target)
	if focusCheckTimer then
		focusCheckTimer:stop()
	end
	target:raise()
	target:focus()
	windows.moveMouseInto(target)
	focusCheckTimer = hs.timer.doAfter(0.1, function()
		focusCheckTimer = nil
		local focused = hs.window.focusedWindow()
		if not focused or focused:id() ~= target:id() then
			target:raise()
			target:focus()
		end
	end)
end

--------------------------------------------------------------------------------
-- Last window (like Hyprland's focuscurrentorlast)
--------------------------------------------------------------------------------

-- Ids of recently focused windows, most recent first. Unlike ⌘Tab (per app),
-- this also goes back to another window of the same app.
local HISTORY_SIZE = 10
local focusHistory = {}
local historyFilter = nil

local function recordFocus(win)
	local id = win and win:id()
	if not id then
		return
	end
	for i = #focusHistory, 1, -1 do
		if focusHistory[i] == id then
			table.remove(focusHistory, i)
		end
	end
	table.insert(focusHistory, 1, id)
	focusHistory[HISTORY_SIZE + 1] = nil
end

--- Focus the most recently focused window other than the current one
local function focusLast()
	local current = hs.window.focusedWindow()
	local currentId = current and current:id()
	for i = 1, #focusHistory do
		local id = focusHistory[i]
		if id ~= currentId then
			local win = hs.window.get(id)
			if win then
				windows.focusWindow(win)
				return
			end
		end
	end
end

--- Focus window in direction (like yabai/hyprland)
--- @param direction string Direction: "west", "east", "north", "south"
local function focusDirection(direction)
	-- Get current window
	local win = hs.window.focusedWindow()
	if not win then
		-- Try frontmost app
		local frontApp = hs.application.frontmostApplication()
		if frontApp then
			local appWindows = frontApp:allWindows()
			if #appWindows > 0 then
				win = appWindows[1]
			end
		end
	end

	local target = windows.windowInDirection(win, direction)
	if not target then
		return false
	end

	windows.focusWindow(target)
	return true
end

--------------------------------------------------------------------------------
-- Swap with the window in a direction (like Hyprland's swapwindow)
--------------------------------------------------------------------------------

-- Set by modules.groups: lets a group be swapped as one unit. Without it
-- (groups disabled) only single windows are swapped.
-- { groupOf(windowId) -> groupId|nil, outerFrame(groupId) -> frame,
--   moveGroup(groupId, outer) }
local groupAdapter = nil

function windows.setGroupAdapter(adapter)
	groupAdapter = adapter
end

--- The unit that moves together with a window: a group or the window itself
--- @return table unit { groupId = ..., win = ..., frame = outer frame }
local function swapUnit(win)
	local groupId = groupAdapter and groupAdapter.groupOf(win:id())
	if groupId then
		return { groupId = groupId, win = win, frame = groupAdapter.outerFrame(groupId) }
	end
	return { win = win, frame = win:frame() }
end

local function moveUnit(unit, outer)
	if unit.groupId then
		groupAdapter.moveGroup(unit.groupId, outer)
	else
		unit.win:setFrame(outer, 0)
	end
end

--- Swap the focused window (or its group) with the one in a direction
--- @param direction string Direction: "west", "east", "north", "south"
local function swapDirection(direction)
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No window", 0.5)
		return
	end

	local other = windows.windowInDirection(win, direction)
	if not other then
		hs.alert.show("No window", 0.5)
		return
	end

	-- Read both outer frames before anything moves
	local a = swapUnit(win)
	local b = swapUnit(other)
	if a.groupId and a.groupId == b.groupId then
		return
	end
	local frameA, frameB = a.frame, b.frame

	moveUnit(a, frameB)
	moveUnit(b, frameA)

	-- Moving does not change focus; the cursor follows the focused window
	windows.moveMouseInto(win)
end

-- Cheatsheet descriptions (UI strings) per direction
local DIRECTION_FOCUS_TEXT = {
	west = "左のウィンドウへ移る",
	south = "下のウィンドウへ移る",
	north = "上のウィンドウへ移る",
	east = "右のウィンドウへ移る",
}
local DIRECTION_SWAP_TEXT = {
	west = "左のウィンドウと入れ替える",
	south = "下のウィンドウと入れ替える",
	north = "上のウィンドウと入れ替える",
	east = "右のウィンドウと入れ替える",
}

--- Keys of a table in sorted order (keeps the cheatsheet order stable)
local function sortedKeys(t)
	local list = {}
	for key in pairs(t) do
		list[#list + 1] = key
	end
	table.sort(list)
	return list
end

--- Cheatsheet description of a layout unit rect (e.g. left 70%)
local function layoutDescription(unit)
	local percent = math.floor(unit.w * 100 + 0.5)
	if unit.h == 1 and unit.x == 0 then
		return ("画面の左 %d%% に配置"):format(percent)
	elseif unit.h == 1 and math.abs(unit.x + unit.w - 1) < 1e-6 then
		return ("画面の右 %d%% に配置"):format(percent)
	end
	return "指定の位置に配置"
end

--- Initialize window management hotkeys
--- @param config table Configuration table with hyper key and window settings
--- @param helpers table Helper functions
function windows.init(config, helpers)
	local hyper = config.hyper
	local windowConfig = config.windows or {}
	mouseFollowsFocus = windowConfig.mouseFollowsFocus == true

	-- Temporary maximize toggle
	if windowConfig.enableMaximizeToggle ~= false then
		local key = windowConfig.maximizeToggleKey or "f"
		keymap.bind(hyper, key, {
			category = keymap.categories.layout,
			description = "最大化と元の大きさを切り替える",
		}, toggleMaximize)
	end

	-- Window positioning (left/right half, etc.)
	if windowConfig.enablePositioning then
		-- Left half
		keymap.bind(hyper, "left", {
			category = keymap.categories.layout,
			description = "左半分に配置",
		}, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(hs.layout.left50)
			end
		end)

		-- Right half
		keymap.bind(hyper, "right", {
			category = keymap.categories.layout,
			description = "右半分に配置",
		}, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(hs.layout.right50)
			end
		end)

		-- Top half
		keymap.bind(hyper, "up", {
			category = keymap.categories.layout,
			description = "上半分に配置",
		}, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit({ x = 0, y = 0, w = 1, h = 0.5 })
			end
		end)

		-- Bottom half
		keymap.bind(hyper, "down", {
			category = keymap.categories.layout,
			description = "下半分に配置",
		}, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit({ x = 0, y = 0.5, w = 1, h = 0.5 })
			end
		end)
	else
		-- Rectangle handles the arrows: shown in the cheatsheet only
		for _, arrow in ipairs({
			{ "left", "左半分に配置（Rectangle）" },
			{ "right", "右半分に配置（Rectangle）" },
			{ "up", "上半分に配置（Rectangle）" },
			{ "down", "下半分に配置（Rectangle）" },
		}) do
			keymap.add({
				category = keymap.categories.layout,
				label = keymap.formatLabel(hyper, arrow[1]),
				description = arrow[2],
			})
		end
	end

	-- Ultrawide layouts (e.g. 70/30)
	local layoutKeys = {}
	for key in pairs(windowConfig.layouts or {}) do
		layoutKeys[#layoutKeys + 1] = key
	end
	table.sort(layoutKeys)
	for _, key in ipairs(layoutKeys) do
		local unit = windowConfig.layouts[key]
		keymap.bind(hyper, key, {
			category = keymap.categories.layout,
			description = layoutDescription(unit),
		}, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(unit, 0)
			end
		end)
	end

	-- Last window (Hyper + - by default: right of L on the MONA2 home row)
	if windowConfig.lastWindowKey ~= false then
		historyFilter = hs.window.filter.new():setDefaultFilter({ allowRoles = "AXStandardWindow" })
		historyFilter:subscribe(hs.window.filter.windowFocused, recordFocus)
		recordFocus(hs.window.focusedWindow())
		keymap.bind(hyper, windowConfig.lastWindowKey or "-", {
			category = keymap.categories.move,
			description = "直前のウィンドウへ戻る",
		}, focusLast)
	end

	-- Directional focus (like yabai/hyprland mod+hjkl)
	local keys = windowConfig.directionalFocusKeys or { h = "west", j = "south", k = "north", l = "east" }
	if windowConfig.enableDirectionalFocus ~= false then
		for _, key in ipairs(sortedKeys(keys)) do
			local direction = keys[key]
			keymap.bind(hyper, key, {
				category = keymap.categories.move,
				description = DIRECTION_FOCUS_TEXT[direction],
			}, function()
				focusDirection(direction)
			end)
		end
	end

	-- Swap: Hyper + swapKey, then a direction key
	local swapKey = windowConfig.swapKey
	if swapKey == nil then
		swapKey = "m"
	end
	if swapKey then
		local letters = {}
		for key in pairs(keys) do
			letters[#letters + 1] = key:upper()
		end
		table.sort(letters)
		local modal = keymodal.new(hyper, swapKey, "Swap: " .. table.concat(letters))
		for _, key in ipairs(sortedKeys(keys)) do
			local direction = keys[key]
			modal:bindAction(key, function()
				swapDirection(direction)
			end, {
				category = keymap.categories.layout,
				description = DIRECTION_SWAP_TEXT[direction],
			})
		end
	end
end

return windows
