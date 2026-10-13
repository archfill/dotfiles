-- Window Management Module
-- Provides window manipulation features: temporary maximize toggle, ultrawide
-- layouts (70/30), directional focus.
-- Modifier + drag move/resize is done by BetterTouchTool: Control + click does
-- not reach Hammerspoon's eventtap (it is handled earlier as a secondary click).

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

--- Get or create window filter for current space
--- @return hs.window.filter
local function getWindowFilter()
	if not windowFilter then
		-- Create filter: current space only, exclude problematic windows
		windowFilter = hs.window.filter.new()
			:setCurrentSpace(true)
			:setDefaultFilter({})
			:rejectApp("Finder") -- Exclude Finder (often has invisible desktop window)
	end
	return windowFilter
end

--- Focus window in direction (like yabai/hyprland)
--- Uses hs.window.filter for better performance and filtering
--- @param direction string Direction: "west", "east", "north", "south"
local function focusDirection(direction)
	local wf = getWindowFilter()

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

	-- Use window filter's focus methods
	local success = false
	if direction == "west" then
		success = wf:focusWindowWest(win, false, false)
	elseif direction == "east" then
		success = wf:focusWindowEast(win, false, false)
	elseif direction == "north" then
		success = wf:focusWindowNorth(win, false, false)
	elseif direction == "south" then
		success = wf:focusWindowSouth(win, false, false)
	end

	return success
end

--- Initialize window management hotkeys
--- @param config table Configuration table with hyper key and window settings
--- @param helpers table Helper functions
function windows.init(config, helpers)
	local hyper = config.hyper
	local windowConfig = config.windows or {}

	-- Temporary maximize toggle
	if windowConfig.enableMaximizeToggle ~= false then
		local key = windowConfig.maximizeToggleKey or "f"
		hs.hotkey.bind(hyper, key, toggleMaximize)
	end

	-- Window positioning (left/right half, etc.)
	if windowConfig.enablePositioning then
		-- Left half
		hs.hotkey.bind(hyper, "left", function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(hs.layout.left50)
			end
		end)

		-- Right half
		hs.hotkey.bind(hyper, "right", function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(hs.layout.right50)
			end
		end)

		-- Top half
		hs.hotkey.bind(hyper, "up", function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit({ x = 0, y = 0, w = 1, h = 0.5 })
			end
		end)

		-- Bottom half
		hs.hotkey.bind(hyper, "down", function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit({ x = 0, y = 0.5, w = 1, h = 0.5 })
			end
		end)
	end

	-- Ultrawide layouts (e.g. 70/30)
	for key, unit in pairs(windowConfig.layouts or {}) do
		hs.hotkey.bind(hyper, key, function()
			local win = hs.window.focusedWindow()
			if win then
				win:moveToUnit(unit, 0)
			end
		end)
	end

	-- Directional focus (like yabai/hyprland mod+hjkl)
	if windowConfig.enableDirectionalFocus ~= false then
		local keys = windowConfig.directionalFocusKeys or { h = "west", j = "south", k = "north", l = "east" }
		for key, direction in pairs(keys) do
			hs.hotkey.bind(hyper, key, function()
				focusDirection(direction)
			end)
		end
	end
end

return windows
