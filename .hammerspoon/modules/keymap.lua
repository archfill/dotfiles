-- Keymap Module
-- Single place that registers hotkeys and keeps a record of them (label,
-- description, category), so the cheatsheet (modules.cheatsheet) never goes
-- out of date. Mirrors the bind("category", key, "description", fn) style of
-- Hyprland's keybinds.lua.
--
-- Formatting and sorting are pure functions (no hs.*) so that
-- tests/hammerspoon/keymap_test.lua can run under plain Lua. The record is
-- rebuilt on every reload because the module state starts empty.

local keymap = {}

-- Category names and their order in the cheatsheet (UI strings, Japanese)
keymap.categories = {
	move = "ウィンドウの移動",
	layout = "配置",
	groups = "グループ",
	apps = "アプリ",
	other = "そのほか",
}
keymap.categoryOrder = {
	keymap.categories.move,
	keymap.categories.layout,
	keymap.categories.groups,
	keymap.categories.apps,
	keymap.categories.other,
}

local HYPER_MODS = { "ctrl", "cmd", "alt", "shift" }

local KEY_NAMES = {
	left = "←",
	right = "→",
	up = "↑",
	down = "↓",
}

local MOD_NAMES = {
	ctrl = "Ctrl",
	cmd = "Cmd",
	alt = "Alt",
	shift = "Shift",
}
local MOD_ORDER = { "ctrl", "alt", "shift", "cmd" }

--- Display name of a key: arrows as symbols, everything else upper case
--- @param key string
--- @return string
function keymap.formatKey(key)
	return KEY_NAMES[key] or tostring(key):upper()
end

--- True when mods contains exactly the four Hyper modifiers
--- @param mods table
--- @return boolean
function keymap.isHyper(mods)
	local set = {}
	local count = 0
	for _, mod in ipairs(mods or {}) do
		if not set[mod] then
			set[mod] = true
			count = count + 1
		end
	end
	if count ~= #HYPER_MODS then
		return false
	end
	for _, mod in ipairs(HYPER_MODS) do
		if not set[mod] then
			return false
		end
	end
	return true
end

--- Display label such as "Hyper + H" or "Hyper + G → G" (two-step)
--- @param mods table Modifier names
--- @param key string Key (entering key for two-step)
--- @param subKey string|nil Second key of a two-step operation
--- @return string
function keymap.formatLabel(mods, key, subKey)
	local parts = {}
	if keymap.isHyper(mods) then
		parts[1] = "Hyper"
	else
		local set = {}
		for _, mod in ipairs(mods or {}) do
			set[mod] = true
		end
		for _, mod in ipairs(MOD_ORDER) do
			if set[mod] then
				parts[#parts + 1] = MOD_NAMES[mod]
			end
		end
	end
	parts[#parts + 1] = keymap.formatKey(key)
	local label = table.concat(parts, " + ")
	if subKey then
		label = label .. " → " .. keymap.formatKey(subKey)
	end
	return label
end

--- Sort entries by category order, then by registration order.
--- Categories not in `order` go after the known ones, in registration order.
--- Returns a new table; the input is left alone.
--- @param entries table List of { category = string, seq = number, ... }
--- @param order table|nil Category names in display order
--- @return table
function keymap.sortEntries(entries, order)
	local rank = {}
	for i, name in ipairs(order or keymap.categoryOrder) do
		rank[name] = i
	end
	local unknown = #(order or keymap.categoryOrder) + 1
	local sorted = {}
	for i, entry in ipairs(entries) do
		sorted[i] = entry
	end
	table.sort(sorted, function(a, b)
		local ra, rb = rank[a.category] or unknown, rank[b.category] or unknown
		if ra ~= rb then
			return ra < rb
		end
		return a.seq < b.seq
	end)
	return sorted
end

--------------------------------------------------------------------------------
-- Record
--------------------------------------------------------------------------------

local records = {}
local nextSeq = 0

--- Record a key without registering it (two-step rows, keys handled outside
--- Hammerspoon, keys registered elsewhere).
--- @param entry table { category, label, description, fn = nil | function }
---   fn == nil means display only: the cheatsheet shows the row but does nothing
function keymap.add(entry)
	nextSeq = nextSeq + 1
	records[#records + 1] = {
		category = entry.category,
		label = entry.label,
		description = entry.description,
		fn = entry.fn,
		seq = nextSeq,
	}
end

--- hs.hotkey.bind plus a record for the cheatsheet
--- @param mods table
--- @param key string
--- @param info table { category, description, runnable = false for display only }
--- @param fn function
--- @return hs.hotkey
function keymap.bind(mods, key, info, fn)
	info = info or {}
	keymap.add({
		category = info.category or keymap.categories.other,
		label = keymap.formatLabel(mods, key),
		description = info.description or "",
		fn = info.runnable ~= false and fn or nil,
	})
	return hs.hotkey.bind(mods, key, fn)
end

--- All records in display order (category order, then registration order)
--- @return table
function keymap.entries()
	return keymap.sortEntries(records)
end

return keymap
