-- Unit tests for .hammerspoon/modules/groups/state.lua (pure Lua, no hs.*)
-- Run: nix shell nixpkgs#lua5_4 -c lua tests/hammerspoon/groups_state_test.lua

local root = arg[0]:match("^(.*)/tests/hammerspoon/[^/]+$") or "."
package.path = root .. "/.hammerspoon/?.lua;" .. package.path

local state = require("modules.groups.state")

local passed, failed = 0, 0

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		passed = passed + 1
		print("ok   " .. name)
	else
		failed = failed + 1
		print("FAIL " .. name .. ": " .. tostring(err))
	end
end

local function eq(actual, expected, msg)
	if actual ~= expected then
		error((msg or "eq") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
	end
end

local function listEq(actual, expected)
	eq(#actual, #expected, "length")
	for i, v in ipairs(expected) do
		eq(actual[i], v, "item " .. i)
	end
end

local F = { x = 0, y = 30, w = 1720, h = 1410 }

test("createGroup makes a single-member group", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	eq(state.groupOf(s, 10), g)
	listEq(s.groups[g].windowIds, { 10 })
	eq(s.groups[g].activeId, 10)
	eq(s.groups[g].frame.w, 1720)
end)

test("createGroup copies the frame", function()
	local s = state.new()
	local f = { x = 1, y = 2, w = 3, h = 4 }
	local g = state.createGroup(s, 10, f)
	f.x = 99
	eq(s.groups[g].frame.x, 1)
end)

test("addWindow appends and activates", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	eq(state.addWindow(s, g, 20), true)
	eq(state.addWindow(s, g, 30), true)
	listEq(s.groups[g].windowIds, { 10, 20, 30 })
	eq(s.groups[g].activeId, 30)
	eq(state.groupOf(s, 20), g)
	eq(state.addWindow(s, 999, 40), false)
end)

test("addWindow moves a window out of its previous group", function()
	local s = state.new()
	local a = state.createGroup(s, 10, F)
	local b = state.createGroup(s, 20, F)
	state.addWindow(s, a, 11)
	state.addWindow(s, a, 20)
	eq(s.groups[b], nil, "empty group removed")
	listEq(s.groups[a].windowIds, { 10, 11, 20 })
	eq(state.groupOf(s, 20), a)
end)

test("removeWindow deletes empty groups", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.addWindow(s, g, 20)
	eq(state.removeWindow(s, 20), g)
	listEq(s.groups[g].windowIds, { 10 })
	eq(s.groups[g].activeId, 10)
	eq(state.groupOf(s, 20), nil)
	state.removeWindow(s, 10)
	eq(s.groups[g], nil)
	eq(state.removeWindow(s, 10), nil)
end)

test("removing the active window picks a neighbour", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.addWindow(s, g, 20)
	state.addWindow(s, g, 30)
	state.setActive(s, 20)
	state.removeWindow(s, 20)
	eq(s.groups[g].activeId, 10)
	state.removeWindow(s, 10)
	eq(s.groups[g].activeId, 30)
end)

test("dissolve frees all members", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.addWindow(s, g, 20)
	state.dissolve(s, g)
	eq(s.groups[g], nil)
	eq(state.groupOf(s, 10), nil)
	eq(state.groupOf(s, 20), nil)
end)

test("setActive ignores non-members", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.addWindow(s, g, 20)
	eq(state.setActive(s, 10), g)
	eq(s.groups[g].activeId, 10)
	eq(state.setActive(s, 99), nil)
	eq(s.groups[g].activeId, 10)
end)

test("nextId wraps around in both directions", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.addWindow(s, g, 20)
	state.addWindow(s, g, 30)
	eq(state.nextId(s, 10, 1), 20)
	eq(state.nextId(s, 20, 1), 30)
	eq(state.nextId(s, 30, 1), 10)
	eq(state.nextId(s, 10, -1), 30)
	eq(state.nextId(s, 30, -1), 20)
	eq(state.nextId(s, 99, 1), nil)
	-- state unchanged
	eq(s.groups[g].activeId, 30)
end)

test("nextId returns itself for a single member", function()
	local s = state.new()
	state.createGroup(s, 10, F)
	eq(state.nextId(s, 10, 1), 10)
	eq(state.nextId(s, 10, -1), 10)
end)

test("setFrame changes the group frame", function()
	local s = state.new()
	local g = state.createGroup(s, 10, F)
	state.setFrame(s, g, { x = 5, y = 6, w = 7, h = 8 })
	eq(s.groups[g].frame.x, 5)
	eq(s.groups[g].frame.h, 8)
end)

test("prune removes missing windows and empty groups", function()
	local s = state.new()
	local a = state.createGroup(s, 10, F)
	state.addWindow(s, a, 11)
	local b = state.createGroup(s, 20, F)
	local changed = state.prune(s, function(id)
		return id == 10
	end)
	eq(changed, true)
	listEq(s.groups[a].windowIds, { 10 })
	eq(s.groups[b], nil)
	eq(state.groupOf(s, 11), nil)
	eq(state.prune(s, function() return true end), false)
end)

test("serialize -> deserialize restores the state", function()
	local s = state.new()
	local a = state.createGroup(s, 10, F)
	state.addWindow(s, a, 11)
	state.setActive(s, 10)
	local b = state.createGroup(s, 20, { x = 1, y = 2, w = 3, h = 4 })
	local copy = state.deserialize(state.serialize(s))
	eq(copy.nextGroupId, s.nextGroupId)
	listEq(copy.groups[a].windowIds, { 10, 11 })
	eq(copy.groups[a].activeId, 10)
	eq(copy.groups[b].frame.w, 3)
	eq(copy.windowToGroup[11], a)
	eq(copy.windowToGroup[20], b)
	-- new ids keep counting up
	local c = state.createGroup(copy, 30, F)
	eq(c, s.nextGroupId)
end)

test("serialized form has no numeric-keyed tables (JSON safe)", function()
	local s = state.new()
	state.createGroup(s, 10, F)
	state.createGroup(s, 20, F)
	local data = state.serialize(s)
	eq(data.windowToGroup, nil)
	eq(#data.groups, 2)
	eq(data.groups[1].id, 1)
end)

test("deserialize rejects invalid data", function()
	eq(state.deserialize(nil), nil)
	eq(state.deserialize("x"), nil)
	eq(state.deserialize({ version = 99, groups = {} }), nil)
	eq(state.deserialize({ version = 1 }), nil)
	eq(state.deserialize({ version = 1, groups = { { id = 1, windowIds = {}, frame = F } } }), nil)
	eq(state.deserialize({ version = 1, groups = { { id = 1, windowIds = { 1 } } } }), nil)
	local dup = {
		{ id = 1, windowIds = { 1 }, frame = F },
		{ id = 2, windowIds = { 1 }, frame = F },
	}
	eq(state.deserialize({ version = 1, groups = dup }), nil)
end)

print(("\n%d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
