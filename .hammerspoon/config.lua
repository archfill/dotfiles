-- Hammerspoon Configuration Values
-- All settings are defined here for easy modification

local config = {}

--------------------------------------------------------------------------------
-- Key Modifiers
--------------------------------------------------------------------------------

-- Hyper key: Caps Lock remapped via Karabiner-Elements
config.hyper = { "ctrl", "cmd", "alt", "shift" }

--------------------------------------------------------------------------------
-- Application Launchers
--------------------------------------------------------------------------------

-- Add new apps here: { key = "x", app = "AppName" }
config.appLaunchers = {
	{ key = "e", app = "Ghostty" },
	-- Examples:
	-- { key = "b", app = "Arc" },
	-- { key = "t", app = "WezTerm" },
	-- { key = "s", app = "Slack" },
}

-- Cycle through running apps (Hyper + key)
config.appCycleKey = "c"

--------------------------------------------------------------------------------
-- Window Management
--------------------------------------------------------------------------------

config.windows = {
	-- Enable temporary maximize toggle (Hyper + F)
	enableMaximizeToggle = true,
	maximizeToggleKey = "f",

	-- Enable window positioning (Hyper + Arrow keys)
	-- Set to true to use Hammerspoon instead of Rectangle
	enablePositioning = false,
}

--------------------------------------------------------------------------------
-- General Settings
--------------------------------------------------------------------------------

config.settings = {
	-- Show alert on config reload
	showReloadAlert = true,
	-- Alert duration in seconds
	alertDuration = 1,
	-- Enable auto-reload on config file changes
	autoReload = false,
	-- Manual reload hotkey (Hyper + key), set to nil to disable
	reloadKey = "r",
}

return config
