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
-- Optional: position = "right" | "left" | "maximize" (applied on first launch only)
config.appLaunchers = {
	{ key = "e", app = "Ghostty", position = "left" },
	-- Examples:
	-- { key = "b", app = "Arc" },
	-- { key = "t", app = "WezTerm", position = "left" },
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
-- dアニメ再生ポップアップの自動退避
--------------------------------------------------------------------------------

config.pipAvoidance = {
	-- Enable the feature. The target is not moved until it is registered or
	-- auto-detected.
	enabled = true,

	-- Register or unregister the focused playback window (Hyper + O).
	-- Hyper + P is already used by window groups.
	registerKey = "o",

	-- Temporarily enable/disable automatic repositioning (Hyper + I).
	toggleKey = "i",

	-- Try to detect newly-created browser popups by app and title.
	-- Manual registration with Hyper + O remains the reliable fallback.
	autoDetect = true,
	browserApps = {
		"Safari",
		"Safari Technology Preview",
		"Google Chrome",
		"Brave Browser",
		"Microsoft Edge",
		"Firefox",
		"Arc",
		"Vivaldi",
	},
	titlePatterns = {
		"dアニメストア",
		"dアニメ",
		"animestore",
	},

	-- Layout and movement behavior.
	inset = 16,
	-- Keep all four corners as candidates. When candidates are equally good,
	-- prefer the configured row: "top" or "bottom".
	preferredVerticalPosition = "bottom",
	debounce = 0.5,
	animationDuration = 0.2,
	-- Do not move for a small amount of overlap.
	minOverlapRatio = 0.08,
	-- Avoid noisy moves when a new corner is only marginally better.
	minImprovementRatio = 0.05,
	-- Raise the playback window without focusing it after a reposition event.
	-- This improves visibility on the current Space but is not a universal
	-- always-on-top guarantee for normal browser windows.
	raiseTarget = true,

	-- Draw a visible outline around the registered playback window.
	border = {
		enabled = true,
		color = { red = 0.15, green = 0.85, blue = 1.0, alpha = 0.95 },
		width = 3,
		inset = 2,
		radius = 6,
		level = "floating",
		syncInterval = 1 / 30,
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
