local M = {}
local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

--- target_triple
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Configs for Windows only
  osKey = "CTRL|SHIFT"
end

if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  -- Configs for OSX only
  osKey = "SUPER"
end

if wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
  -- Configs for Linux only
  osKey = "CTRL|SHIFT"
end

---------------------------------------------------------------
--- keybinds
---------------------------------------------------------------
-- Disabled tmux_keybinds to use external tmux
-- M.tmux_keybinds = {}

M.default_keybinds = {
	-- Basic clipboard operations
	{ key = "c", mods = osKey, action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = osKey, action = act({ PasteFrom = "Clipboard" }) },
	{ key = "Insert", mods = "SHIFT", action = act({ PasteFrom = "PrimarySelection" }) },
	-- Font size controls
	{ key = "=", mods = "CTRL", action = "ResetFontSize" },
	{ key = "+", mods = "CTRL", action = "IncreaseFontSize" },
	{ key = "-", mods = "CTRL", action = "DecreaseFontSize" },
	-- Configuration reload (using different key combination to avoid tmux conflict)
	{ key = "F5", mods = "NONE", action = "ReloadConfiguration" },
	-- Copy mode activation (using different key combination)
	{
		key = "c",
		mods = "CTRL|SHIFT|ALT",
		action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.ActivateCopyMode, act.ClearSelection }),
	},
	-- Window management
	{ key = "Enter", mods = osKey, action = "ToggleFullScreen" },
	{ key = "F11", mods = "NONE", action = "ToggleFullScreen" },
	-- Tab operations (unified for all platforms)
	{ key = "LeftArrow", mods = osKey, action = act.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = osKey, action = act.ActivateTabRelative(1) },
	{ key = "t", mods = osKey, action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = osKey, action = act.CloseCurrentTab({ confirm = false }) },
	-- Tab direct access with numbers
	{ key = "1", mods = osKey, action = act.ActivateTab(0) },
	{ key = "2", mods = osKey, action = act.ActivateTab(1) },
	{ key = "3", mods = osKey, action = act.ActivateTab(2) },
	{ key = "4", mods = osKey, action = act.ActivateTab(3) },
	{ key = "5", mods = osKey, action = act.ActivateTab(4) },
	{ key = "6", mods = osKey, action = act.ActivateTab(5) },
	{ key = "7", mods = osKey, action = act.ActivateTab(6) },
	{ key = "8", mods = osKey, action = act.ActivateTab(7) },
	{ key = "9", mods = osKey, action = act.ActivateTab(8) },
	-- Advanced tab management
	{ key = "LeftArrow", mods = osKey .. "|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = osKey .. "|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "LeftArrow", mods = osKey .. "|ALT", action = act.ActivateTab(0) },
	{ key = "RightArrow", mods = osKey .. "|ALT", action = act.ActivateTab(-1) },
}

function M.create_keybinds()
	-- Return only default keybinds since tmux_keybinds is disabled
	return M.default_keybinds
end

M.key_tables = {
	-- Removed resize_pane table to avoid conflicts with tmux
	copy_mode = {
		{
			key = "Escape",
			mods = "NONE",
			action = act.Multiple({
				act.ClearSelection,
				act.CopyMode("ClearPattern"),
				act.CopyMode("Close"),
			}),
		},
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		-- move cursor
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		-- move word
		{ key = "RightArrow", mods = "SUPER", action = act.CopyMode("MoveForwardWord") },
		{ key = "f", mods = "SUPER", action = act.CopyMode("MoveForwardWord") },
		{ key = "\t", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "LeftArrow", mods = "SUPER", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "SUPER", action = act.CopyMode("MoveBackwardWord") },
		{ key = "\t", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{
			key = "e",
			mods = "NONE",
			action = act({
				Multiple = {
					act.CopyMode("MoveRight"),
					act.CopyMode("MoveForwardWord"),
					act.CopyMode("MoveLeft"),
				},
			}),
		},
		-- move start/end
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "\n", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "e", mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "m", mods = "SUPER", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "a", mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },
		-- select
		{ key = " ", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{
			key = "v",
			mods = "SHIFT",
			action = act({
				Multiple = {
					act.CopyMode("MoveToStartOfLineContent"),
					act.CopyMode({ SetSelectionMode = "Cell" }),
					act.CopyMode("MoveToEndOfLineContent"),
				},
			}),
		},
		-- copy
		{
			key = "y",
			mods = "NONE",
			action = act({
				Multiple = {
					act({ CopyTo = "ClipboardAndPrimarySelection" }),
					act.CopyMode("Close"),
				},
			}),
		},
		{
			key = "y",
			mods = "SHIFT",
			action = act({
				Multiple = {
					act.CopyMode({ SetSelectionMode = "Cell" }),
					act.CopyMode("MoveToEndOfLineContent"),
					act({ CopyTo = "ClipboardAndPrimarySelection" }),
					act.CopyMode("Close"),
				},
			}),
		},
		-- scroll
		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{
			key = "Enter",
			mods = "NONE",
			action = act.CopyMode("ClearSelectionMode"),
		},
		-- search
		{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
		{
			key = "n",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("NextMatch"),
				act.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = act.Multiple({
				act.CopyMode("PriorMatch"),
				act.CopyMode("ClearSelectionMode"),
			}),
		},
	},
	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{
			key = "Enter",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearSelectionMode"),
				act.ActivateCopyMode,
			}),
		},
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "/", mods = "NONE", action = act.CopyMode("ClearPattern") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},
}

M.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act({ CompleteSelection = "PrimarySelection" }),
	},
	{
		event = { Up = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act({ CompleteSelection = "Clipboard" }),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = "OpenLinkAtMouseCursor",
	},
}

return M
