-- Utility Functions
-- Reusable helper functions for Hammerspoon

local helpers = {}

--------------------------------------------------------------------------------
-- Application Helpers
--------------------------------------------------------------------------------

--- Toggle application: launch, focus, or hide
--- @param appName string The name of the application
function helpers.toggleApp(appName)
	local app = hs.application.get(appName)
	if app == nil then
		hs.application.launchOrFocus("/Applications/" .. appName .. ".app")
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
