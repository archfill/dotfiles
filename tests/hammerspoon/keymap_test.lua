-- Unit tests for .hammerspoon/modules/keymap.lua formatting and sorting (pure Lua, no hs.*)
-- Run: nix shell nixpkgs#lua5_4 -c lua tests/hammerspoon/keymap_test.lua

local root = arg[0]:match("^(.*)/tests/hammerspoon/[^/]+$") or "."
package.path = root .. "/.hammerspoon/?.lua;" .. package.path

local keymap = require("modules.keymap")

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

local HYPER = { "ctrl", "cmd", "alt", "shift" }

test("formatKey: letters upper case, arrows as symbols", function()
	eq(keymap.formatKey("h"), "H")
	eq(keymap.formatKey("/"), "/")
	eq(keymap.formatKey("-"), "-")
	eq(keymap.formatKey("left"), "←")
	eq(keymap.formatKey("right"), "→")
	eq(keymap.formatKey("up"), "↑")
	eq(keymap.formatKey("down"), "↓")
end)

test("isHyper: all four modifiers in any order", function()
	eq(keymap.isHyper(HYPER), true)
	eq(keymap.isHyper({ "shift", "alt", "cmd", "ctrl" }), true)
	eq(keymap.isHyper({ "ctrl", "cmd", "alt" }), false)
	eq(keymap.isHyper({ "ctrl", "cmd", "alt", "alt" }), false)
	eq(keymap.isHyper({}), false)
end)

test("formatLabel: Hyper, arrows, other modifiers, two-step", function()
	eq(keymap.formatLabel(HYPER, "h"), "Hyper + H")
	eq(keymap.formatLabel(HYPER, "left"), "Hyper + ←")
	eq(keymap.formatLabel({ "cmd", "shift" }, "k"), "Shift + Cmd + K")
	eq(keymap.formatLabel(HYPER, "g", "g"), "Hyper + G → G")
	eq(keymap.formatLabel(HYPER, "m", "l"), "Hyper + M → L")
end)

test("sortEntries: category order, then registration order", function()
	local order = { "A", "B", "C" }
	local input = {
		{ category = "C", seq = 1, label = "c1" },
		{ category = "A", seq = 2, label = "a1" },
		{ category = "B", seq = 3, label = "b1" },
		{ category = "A", seq = 4, label = "a2" },
		{ category = "C", seq = 5, label = "c2" },
	}
	local sorted = keymap.sortEntries(input, order)
	local labels = {}
	for i, e in ipairs(sorted) do
		labels[i] = e.label
	end
	eq(table.concat(labels, ","), "a1,a2,b1,c1,c2")
	eq(input[1].label, "c1", "input untouched")
end)

test("sortEntries: unknown categories go last in registration order", function()
	local sorted = keymap.sortEntries({
		{ category = "Z", seq = 1, label = "z1" },
		{ category = "A", seq = 2, label = "a1" },
		{ category = "Y", seq = 3, label = "y1" },
	}, { "A" })
	eq(sorted[1].label, "a1")
	eq(sorted[2].label, "z1")
	eq(sorted[3].label, "y1")
end)

test("add / entries: records sorted with the default category order", function()
	local cats = keymap.categories
	keymap.add({ category = cats.other, label = "Hyper + R", description = "r", fn = function() end })
	keymap.add({ category = cats.move, label = "Hyper + H", description = "h", fn = function() end })
	keymap.add({ category = cats.layout, label = "Hyper + ←", description = "left" })
	keymap.add({ category = cats.move, label = "Hyper + L", description = "l", fn = function() end })
	local entries = keymap.entries()
	eq(#entries, 4)
	eq(entries[1].label, "Hyper + H")
	eq(entries[2].label, "Hyper + L")
	eq(entries[3].label, "Hyper + ←")
	eq(entries[3].fn, nil, "display only has no fn")
	eq(entries[4].label, "Hyper + R")
end)

print(("\n%d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
