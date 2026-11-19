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
