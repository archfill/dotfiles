-- Cheatsheet Module
-- Hyper + U shows every registered key (modules.keymap) in an hs.chooser.
-- Enter runs the key's action; display-only rows (keys handled outside
-- Hammerspoon) do nothing. Styled like the Hyper + W chooser (config.fzf.ui).

local keymap = require("modules.keymap")

local cheatsheet = {}

-- Delay between hiding the chooser and running the action, so that focus is
-- back on the previous window (focused-window actions must hit that window)
local RUN_DELAY = 0.1

-- Rows shown at once
local ROWS = 15

-- Display-only rows (keys handled outside Hammerspoon) are grey (text and
-- keycap), so they are not mistaken for rows that run something.
-- Sizes match the chooser's default fonts.
local DISPLAY_ONLY_COLOR = { white = 0.5 }
local DISPLAY_ONLY_TEXT_SIZE = 14
local DISPLAY_ONLY_SUBTEXT_SIZE = 10

-- Row icon: the key itself drawn as a keycap ("H", "←", "G→L").
-- Grey for display-only rows. Cached per text and colour.
local KEYCAP_SIZE = 64 -- px; the chooser scales it down to the row icon size
local KEYCAP_COLORS = {
	run = { fill = { white = 0.22 }, stroke = { white = 0.55 }, text = { white = 0.95 } },
	display = { fill = { white = 0.16 }, stroke = { white = 0.3 }, text = { white = 0.5 } },
}
local keycapCache = {}

--- Key part of a label: "Hyper + G → L" -> "G→L"
local function keycapText(label)
	local key = label:match("^Hyper %+ (.+)$") or label
	return (key:gsub(" → ", "→"))
end

--- @param text string
--- @param runnable boolean
--- @return hs.image
local function keycapImage(text, runnable)
	local style = runnable and "run" or "display"
	local cacheKey = style .. ":" .. text
	if keycapCache[cacheKey] then
		return keycapCache[cacheKey]
	end
	local colors = KEYCAP_COLORS[style]
	local size = KEYCAP_SIZE
	-- Longer texts (two-step keys) get a smaller font to fit
	local fontSize = (utf8.len(text) or #text) <= 1 and 30 or 20
	local canvas = hs.canvas.new({ x = 0, y = 0, w = size, h = size })
	canvas[1] = {
		type = "rectangle",
		frame = { x = 4, y = 4, w = size - 8, h = size - 8 },
		roundedRectRadii = { xRadius = 10, yRadius = 10 },
		fillColor = colors.fill,
		strokeColor = colors.stroke,
		strokeWidth = 2,
	}
	canvas[2] = {
		type = "text",
		text = hs.styledtext.new(text, {
			font = { name = ".AppleSystemUIFont", size = fontSize },
			color = colors.text,
			paragraphStyle = { alignment = "center" },
		}),
		-- Vertically centre the single line
		frame = { x = 4, y = (size - fontSize * 1.25) / 2, w = size - 8, h = fontSize * 1.4 },
	}
	local image = canvas:imageFromCanvas()
	canvas:delete()
	keycapCache[cacheKey] = image
	return image
end

--- Grey styled text for a display-only row
local function styled(str, size)
	return hs.styledtext.new(str, {
		font = { name = ".AppleSystemUIFont", size = size },
		color = DISPLAY_ONLY_COLOR,
	})
end

local chooser = nil
local entriesByIndex = {}

--- Build chooser rows from the keymap record (rebuilt on every open)
--- @return table
local function buildChoices()
	local choices = {}
	entriesByIndex = {}
	for i, entry in ipairs(keymap.entries()) do
		local runnable = entry.fn ~= nil
		local text = entry.label .. "　" .. entry.description
		local subText = runnable and entry.category or (entry.category .. "（表示のみ）")
		choices[i] = {
			text = runnable and text or styled(text, DISPLAY_ONLY_TEXT_SIZE),
			subText = runnable and subText or styled(subText, DISPLAY_ONLY_SUBTEXT_SIZE),
			image = keycapImage(keycapText(entry.label), runnable),
			index = i,
		}
		entriesByIndex[i] = entry
	end
	return choices
end

--- @param config table
--- @param helpers table
function cheatsheet.init(config, helpers)
	local settings = config.cheatsheet or {}
	if settings.enabled == false then
		return
	end

	local ui = (config.fzf or {}).ui or {}

	chooser = hs.chooser.new(function(selection)
		if not selection then
			return
		end
		local entry = entriesByIndex[selection.index]
		if entry and entry.fn then
			hs.timer.doAfter(RUN_DELAY, entry.fn)
		end
	end)
	if ui.bgDark ~= nil then
		chooser:bgDark(ui.bgDark)
	end
	chooser:searchSubText(true)
	chooser:rows(ROWS)
	chooser:placeholderText("キーを検索")

	keymap.bind(config.hyper, settings.key or "u", {
		category = keymap.categories.other,
		description = "この一覧を開く・閉じる",
		runnable = false,
	}, function()
		if chooser:isVisible() then
			chooser:hide()
			return
		end
		-- Same width logic as the Hyper + W chooser
		if ui.widthPixels then
			local screenWidth = hs.screen.mainScreen():frame().w
			chooser:width(math.min(ui.widthPixels / screenWidth * 100, ui.maxWidthPercent or 90))
		end
		chooser:choices(buildChoices())
		chooser:query(nil)
		chooser:show()
	end)
end

return cheatsheet
