-- Window Management Module
-- Provides window manipulation features including temporary maximize toggle

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
end

return windows
