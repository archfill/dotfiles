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

	-- Enable directional focus (Hyper + H/J/K/L)
	-- Like yabai/hyprland/i3 mod+hjkl
	enableDirectionalFocus = true,
	-- Customize keys: { key = "direction" }
	-- directionalFocusKeys = { h = "west", j = "south", k = "north", l = "east" },
}

--------------------------------------------------------------------------------
-- FZF Window Switcher
--------------------------------------------------------------------------------

config.fzf = {
	-- Enable fzf-powered window switcher
	enabled = true,
	-- Hotkey to show window switcher (Hyper + key)
	hotkey = "w",
	-- Path to fzf binary (auto-detected if not set)
	-- fzfPath = "/opt/homebrew/bin/fzf",
	-- Search window titles in addition to app names
	searchWindowTitles = true,
	-- Immediately switch if there's only one match
	quickSwitchEnabled = true,
	-- Maximum length for window titles in UI
	maxTitleLength = 50,
}

--------------------------------------------------------------------------------
-- Window Groups (Hyprland-style stacking)
--------------------------------------------------------------------------------

config.groups = {
	-- Enable window grouping
	enabled = true,
	-- Keybindings
	keys = {
		toggle = "g", -- Create group / exit add mode / dissolve group
		next = "n",   -- Next window in group
		prev = "p",   -- Previous window in group
	},
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
