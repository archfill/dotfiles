-- Utility Functions
-- Reusable helper functions for Hammerspoon

local helpers = {}

--------------------------------------------------------------------------------
-- Application Helpers
--------------------------------------------------------------------------------

--- Position a window based on position setting
--- @param win hs.window The window to position
--- @param position string Position: "right", "left", "maximize"
local function positionWindow(win, position)
	local screen = win:screen()
	local frame = screen:frame()
	if position == "right" then
		win:setFrame({
			x = frame.x + frame.w / 2,
			y = frame.y,
			w = frame.w / 2,
			h = frame.h,
		})
	elseif position == "left" then
		win:setFrame({
			x = frame.x,
			y = frame.y,
			w = frame.w / 2,
			h = frame.h,
		})
	elseif position == "maximize" then
		win:maximize()
	end
end

--- Toggle application: launch, focus, or hide
--- @param appName string The name of the application
--- @param position string|nil Optional position when opening new window: "right", "left", "maximize"
function helpers.toggleApp(appName, position)
	local app = hs.application.get(appName)
	local hasWindows = app and #app:allWindows() > 0

	if not hasWindows then
		-- No windows: launch app and position the new window
		hs.application.launchOrFocus("/Applications/" .. appName .. ".app")
		if position then
			-- Use window filter to detect window creation instantly
			local wf = hs.window.filter.new(false):setAppFilter(appName)
			wf:subscribe(hs.window.filter.windowCreated, function(win)
				positionWindow(win, position)
				-- Unsubscribe after first window
				wf:unsubscribeAll()
			end)
			-- Timeout fallback: clean up filter after 5 seconds
			hs.timer.doAfter(5, function()
				wf:unsubscribeAll()
			end)
		end
	elseif app:isFrontmost() then
		app:hide()
	else
		hs.application.launchOrFocus("/Applications/" .. appName .. ".app")
	end
end

--------------------------------------------------------------------------------
-- Window Helpers
--------------------------------------------------------------------------------

--- Move focused window to left half of screen
function helpers.windowLeftHalf()
	local win = hs.window.focusedWindow()
	if win then
		win:moveToUnit(hs.layout.left50)
	end
end

--- Move focused window to right half of screen
function helpers.windowRightHalf()
	local win = hs.window.focusedWindow()
	if win then
		win:moveToUnit(hs.layout.right50)
	end
end

--- Maximize focused window
function helpers.windowMaximize()
	local win = hs.window.focusedWindow()
	if win then
		win:maximize()
	end
end

--- Center focused window
function helpers.windowCenter()
	local win = hs.window.focusedWindow()
	if win then
		win:centerOnScreen()
	end
end

--------------------------------------------------------------------------------
-- Notification Helpers
--------------------------------------------------------------------------------

--- Show alert with default duration
--- @param message string The message to display
--- @param duration number|nil Duration in seconds (default: 1)
function helpers.alert(message, duration)
	hs.alert.show(message, duration or 1)
end

return helpers
