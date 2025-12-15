-- Window Group Module
-- Provides Hyprland-style window grouping with tab indicator

local groups = {}

-- Current group state
local currentGroup = {}  -- Array of window objects
local groupIndex = 1     -- Current position in group
local groupFrame = nil   -- Shared frame for grouped windows

-- Tab bar UI
local tabCanvas = nil
local TAB_HEIGHT = 24
local TAB_PADDING = 8
local TAB_BG = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 }
local TAB_ACTIVE = { red = 0.3, green = 0.5, blue = 0.8, alpha = 1 }
local TAB_INACTIVE = { red = 0.25, green = 0.25, blue = 0.25, alpha = 1 }
local TAB_TEXT = { red = 1, green = 1, blue = 1, alpha = 1 }
local TAB_TEXT_INACTIVE = { red = 0.7, green = 0.7, blue = 0.7, alpha = 1 }

--- Get app name for window
local function getAppName(win)
	if not win then return "?" end
	local app = win:application()
	return app and app:name() or "?"
end

--- Update tab bar UI
local function updateTabBar()
	-- Remove existing canvas
	if tabCanvas then
		tabCanvas:delete()
		tabCanvas = nil
	end

	-- Don't show if no windows
	if #currentGroup < 1 or not groupFrame then
		return
	end

	-- Tab bar inside window (overlay at top)
	local win = currentGroup[groupIndex]
	if not win or not win:id() then return end

	local frame = win:frame()
	local barFrame = {
		x = frame.x,
		y = frame.y,
		w = frame.w,
		h = TAB_HEIGHT,
	}

	-- Create canvas
	tabCanvas = hs.canvas.new(barFrame)

	-- Background
	tabCanvas[1] = {
		type = "rectangle",
		fillColor = TAB_BG,
		strokeColor = { red = 0.3, green = 0.3, blue = 0.3, alpha = 1 },
		strokeWidth = 1,
		roundedRectRadii = { xRadius = 4, yRadius = 4 },
	}

	-- Calculate tab width
	local tabCount = #currentGroup
	local totalPadding = TAB_PADDING * (tabCount + 1)
	local tabWidth = (frame.w - totalPadding) / tabCount

	-- Draw tabs
	for i, win in ipairs(currentGroup) do
		local isActive = (i == groupIndex)
		local tabX = TAB_PADDING + (i - 1) * (tabWidth + TAB_PADDING)

		-- Tab background
		tabCanvas[#tabCanvas + 1] = {
			type = "rectangle",
			frame = {
				x = tabX,
				y = 4,
				w = tabWidth,
				h = TAB_HEIGHT - 8,
			},
			fillColor = isActive and TAB_ACTIVE or TAB_INACTIVE,
			roundedRectRadii = { xRadius = 3, yRadius = 3 },
		}

		-- Tab text
		local appName = getAppName(win)
		-- Truncate if too long
		if #appName > 15 then
			appName = appName:sub(1, 12) .. "..."
		end

		tabCanvas[#tabCanvas + 1] = {
			type = "text",
			frame = {
				x = tabX,
				y = 5,
				w = tabWidth,
				h = TAB_HEIGHT - 8,
			},
			text = appName,
			textAlignment = "center",
			textColor = isActive and TAB_TEXT or TAB_TEXT_INACTIVE,
			textSize = 11,
		}
	end

	-- Show canvas
	tabCanvas:level(hs.canvas.windowLevels.floating)
	tabCanvas:show()
end

--- Hide tab bar
local function hideTabBar()
	if tabCanvas then
		tabCanvas:delete()
		tabCanvas = nil
	end
end

--- Check if window is in current group
local function findInGroup(win)
	if not win then return nil end
	local winId = win:id()
	for i, w in ipairs(currentGroup) do
		if w:id() == winId then
			return i
		end
	end
	return nil
end

--- Add or remove current window from group (toggle)
local function toggleWindowInGroup()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No window", 0.5)
		return
	end

	local appName = getAppName(win)
	local idx = findInGroup(win)

	if idx then
		-- Remove from group
		table.remove(currentGroup, idx)
		if groupIndex > #currentGroup then
			groupIndex = math.max(1, #currentGroup)
		end

		if #currentGroup == 0 then
			-- Clear group
			groupFrame = nil
			hideTabBar()
			hs.alert.show("Group cleared", 0.5)
		else
			-- Update tab bar (keeps showing even with 1 window)
			hs.alert.show("Removed: " .. appName, 0.5)
			updateTabBar()
		end
	else
		-- Add to group
		if #currentGroup == 0 then
			-- First window - save frame as group frame
			groupFrame = win:frame()
		else
			-- Additional windows - match group frame
			win:setFrame(groupFrame)
		end

		table.insert(currentGroup, win)
		groupIndex = #currentGroup

		-- Show tab bar (overlays window)
		updateTabBar()

		hs.alert.show("Added: " .. appName .. " (#" .. #currentGroup .. ")", 0.5)
	end
end

--- Focus a window reliably
local function focusWindow(win)
	if not win or not win:id() then return false end

	local app = win:application()
	if app then
		app:activate()
	end
	win:raise()
	win:focus()
	return true
end

--- Cycle to next window in group
local function cycleNext()
	if #currentGroup < 2 then return end

	groupIndex = groupIndex % #currentGroup + 1
	local win = currentGroup[groupIndex]

	if focusWindow(win) then
		hs.timer.doAfter(0, updateTabBar)
	else
		-- Window closed, remove and retry
		table.remove(currentGroup, groupIndex)
		groupIndex = math.max(1, math.min(groupIndex, #currentGroup))
		if #currentGroup >= 2 then
			cycleNext()
		end
	end
end

--- Cycle to previous window in group
local function cyclePrev()
	if #currentGroup < 2 then return end

	groupIndex = (groupIndex - 2) % #currentGroup + 1
	local win = currentGroup[groupIndex]

	if focusWindow(win) then
		hs.timer.doAfter(0, updateTabBar)
	else
		-- Window closed, remove and retry
		table.remove(currentGroup, groupIndex)
		groupIndex = math.max(1, math.min(groupIndex, #currentGroup))
		if #currentGroup >= 2 then
			cyclePrev()
		end
	end
end

--- Initialize group module
function groups.init(config, helpers)
	local hyper = config.hyper
	local groupConfig = config.groups or {}

	if groupConfig.enabled == false then return end

	local keys = groupConfig.keys or { toggle = "g", next = ".", prev = "," }

	hs.hotkey.bind(hyper, keys.toggle, toggleWindowInGroup)
	hs.hotkey.bind(hyper, keys.next, cycleNext)
	hs.hotkey.bind(hyper, keys.prev, cyclePrev)
end

return groups
