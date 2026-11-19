-- Window Group Tab Bar
-- Draws the tab bar of the group the focused window belongs to.
-- Holds only the canvas; the group state is passed in on every update.

local M = {}

local TAB_HEIGHT = 24
local TAB_PADDING = 8
local TAB_BG = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 }
local TAB_ACTIVE = { red = 0.3, green = 0.5, blue = 0.8, alpha = 1 }
local TAB_INACTIVE = { red = 0.25, green = 0.25, blue = 0.25, alpha = 1 }
local TAB_TEXT = { red = 1, green = 1, blue = 1, alpha = 1 }
local TAB_TEXT_INACTIVE = { red = 0.7, green = 0.7, blue = 0.7, alpha = 1 }

local tabCanvas = nil

--- Get app name for window
local function getAppName(win)
	if not win then
		return "?"
	end
	local app = win:application()
	return app and app:name() or "?"
end

--- Remove the tab bar
function M.hide()
	if tabCanvas then
		tabCanvas:delete()
		tabCanvas = nil
	end
end

--- Redraw the tab bar
--- Shown only when the focused window is a member of a group; hidden otherwise
--- (hs.canvas stays on top of other windows, so other groups' bars are not drawn).
--- @param state table Group state (see state.lua)
--- @param focusedId number|nil Id of the focused window
--- @param getWindow function id -> hs.window|nil
function M.update(state, focusedId, getWindow)
	M.hide()

	local groupId = focusedId and state.windowToGroup[focusedId]
	if not groupId then
		return
	end
	local group = state.groups[groupId]
	local frame = group.frame

	tabCanvas = hs.canvas.new({
		x = frame.x,
		y = frame.y,
		w = frame.w,
		h = TAB_HEIGHT,
	})

	-- Background
	tabCanvas[1] = {
		type = "rectangle",
		fillColor = TAB_BG,
		strokeColor = { red = 0.3, green = 0.3, blue = 0.3, alpha = 1 },
		strokeWidth = 1,
		roundedRectRadii = { xRadius = 4, yRadius = 4 },
	}

	-- Calculate tab width
	local tabCount = #group.windowIds
	local totalPadding = TAB_PADDING * (tabCount + 1)
	local tabWidth = (frame.w - totalPadding) / tabCount

	-- Draw tabs
	for i, id in ipairs(group.windowIds) do
		local isActive = (id == group.activeId)
		local tabX = TAB_PADDING + (i - 1) * (tabWidth + TAB_PADDING)

		-- Tab background
		tabCanvas[#tabCanvas + 1] = {
			type = "rectangle",
			frame = { x = tabX, y = 4, w = tabWidth, h = TAB_HEIGHT - 8 },
			fillColor = isActive and TAB_ACTIVE or TAB_INACTIVE,
			roundedRectRadii = { xRadius = 3, yRadius = 3 },
		}

		-- Tab text (app name, truncated if too long)
		local appName = getAppName(getWindow(id))
		if #appName > 15 then
			appName = appName:sub(1, 12) .. "..."
		end

		tabCanvas[#tabCanvas + 1] = {
			type = "text",
			frame = { x = tabX, y = 5, w = tabWidth, h = TAB_HEIGHT - 8 },
			text = appName,
			textAlignment = "center",
			textColor = isActive and TAB_TEXT or TAB_TEXT_INACTIVE,
			textSize = 11,
		}
	end

	tabCanvas:level(hs.canvas.windowLevels.floating)
	tabCanvas:show()
end

return M
