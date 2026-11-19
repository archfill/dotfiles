-- Window Group State
-- Pure data model for window groups. Must not call hs.* so that it can be
-- tested with a plain Lua interpreter.
--
-- Windows are held by id (win:id()), never as hs.window objects.

local M = {}

M.VERSION = 1

--- Create an empty state
--- @return table
function M.new()
	return {
		version = M.VERSION,
		nextGroupId = 1,
		groups = {}, -- [groupId] = { windowIds, activeId, frame }
		windowToGroup = {}, -- [windowId] = groupId (derived from groups)
	}
end

local function copyFrame(frame)
	return { x = frame.x, y = frame.y, w = frame.w, h = frame.h }
end

local function indexOf(list, value)
	for i, v in ipairs(list) do
		if v == value then
			return i
		end
	end
	return nil
end

--- Get the group id a window belongs to
--- @return number|nil
function M.groupOf(state, windowId)
	return state.windowToGroup[windowId]
end

--- Remove a window from its group. Empty groups are deleted.
--- If the removed window was the active one, a neighbour becomes active.
--- @return number|nil groupId the window was removed from
function M.removeWindow(state, windowId)
	local groupId = state.windowToGroup[windowId]
	if not groupId then
		return nil
	end
	local group = state.groups[groupId]
	local idx = indexOf(group.windowIds, windowId)
	table.remove(group.windowIds, idx)
	state.windowToGroup[windowId] = nil

	if #group.windowIds == 0 then
		state.groups[groupId] = nil
	elseif group.activeId == windowId then
		group.activeId = group.windowIds[math.max(1, idx - 1)]
	end
	return groupId
end

--- Create a group that holds a single window
--- The window leaves its previous group, if any.
--- @return number groupId
function M.createGroup(state, windowId, frame)
	M.removeWindow(state, windowId)
	local groupId = state.nextGroupId
	state.nextGroupId = groupId + 1
	state.groups[groupId] = {
		windowIds = { windowId },
		activeId = windowId,
		frame = copyFrame(frame),
	}
	state.windowToGroup[windowId] = groupId
	return groupId
end

--- Add a window to a group and make it the active one
--- The window leaves its previous group, if any.
--- @return boolean false when the group does not exist
function M.addWindow(state, groupId, windowId)
	local group = state.groups[groupId]
	if not group then
		return false
	end
	if state.windowToGroup[windowId] == groupId then
		group.activeId = windowId
		return true
	end
	M.removeWindow(state, windowId)
	-- removeWindow may have deleted another group, never this one
	table.insert(group.windowIds, windowId)
	group.activeId = windowId
	state.windowToGroup[windowId] = groupId
	return true
end

--- Dissolve a group (all members become ungrouped)
--- @return table|nil the member window ids
function M.dissolve(state, groupId)
	local group = state.groups[groupId]
	if not group then
		return nil
	end
	for _, id in ipairs(group.windowIds) do
		state.windowToGroup[id] = nil
	end
	state.groups[groupId] = nil
	return group.windowIds
end

--- Make a window the active one of its group (no-op for non-members)
--- @return number|nil groupId
function M.setActive(state, windowId)
	local groupId = state.windowToGroup[windowId]
	if groupId then
		state.groups[groupId].activeId = windowId
	end
	return groupId
end

--- Id of the next (step = 1) or previous (step = -1) window in the same group
--- Does not change the state.
--- @return number|nil nil when the window is not in a group
function M.nextId(state, windowId, step)
	local groupId = state.windowToGroup[windowId]
	if not groupId then
		return nil
	end
	local ids = state.groups[groupId].windowIds
	local idx = indexOf(ids, windowId)
	return ids[(idx - 1 + step) % #ids + 1]
end

--- Change the frame of a group
function M.setFrame(state, groupId, frame)
	local group = state.groups[groupId]
	if group then
		group.frame = copyFrame(frame)
	end
end

--- Remove windows for which existsFn(id) is false. Empty groups are deleted.
--- @return boolean true when something was removed
function M.prune(state, existsFn)
	local gone = {}
	for id in pairs(state.windowToGroup) do
		if not existsFn(id) then
			gone[#gone + 1] = id
		end
	end
	for _, id in ipairs(gone) do
		M.removeWindow(state, id)
	end
	return #gone > 0
end

--- Convert to a plain table for saving (JSON friendly: no numeric keys)
--- windowToGroup is not saved; deserialize rebuilds it.
function M.serialize(state)
	local list = {}
	for groupId, group in pairs(state.groups) do
		list[#list + 1] = {
			id = groupId,
			windowIds = { table.unpack(group.windowIds) },
			activeId = group.activeId,
			frame = copyFrame(group.frame),
		}
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	return {
		version = M.VERSION,
		nextGroupId = state.nextGroupId,
		groups = list,
	}
end

--- Restore a state from a saved table
--- @return table|nil nil when the table is invalid or has another version
function M.deserialize(data)
	if type(data) ~= "table" or data.version ~= M.VERSION or type(data.groups) ~= "table" then
		return nil
	end
	local state = M.new()
	local maxId = 0
	for _, g in ipairs(data.groups) do
		local f = g.frame
		if
			type(g.id) ~= "number"
			or type(g.windowIds) ~= "table"
			or #g.windowIds == 0
			or type(f) ~= "table"
			or type(f.x) ~= "number"
			or type(f.y) ~= "number"
			or type(f.w) ~= "number"
			or type(f.h) ~= "number"
			or state.groups[g.id]
		then
			return nil
		end
		local ids = {}
		for _, id in ipairs(g.windowIds) do
			-- A window can belong to only one group
			if type(id) ~= "number" or state.windowToGroup[id] then
				return nil
			end
			ids[#ids + 1] = id
			state.windowToGroup[id] = g.id
		end
		state.groups[g.id] = {
			windowIds = ids,
			activeId = indexOf(ids, g.activeId) and g.activeId or ids[1],
			frame = copyFrame(f),
		}
		maxId = math.max(maxId, g.id)
	end
	state.nextGroupId = math.max(tonumber(data.nextGroupId) or 1, maxId + 1)
	return state
end

return M
