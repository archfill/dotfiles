local wezterm = require("wezterm")
-- local act = wezterm.action
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nightfox"]
-- local gpus = wezterm.gui.enumerate_gpus()
require("on")

-- /etc/ssh/sshd_config
-- AcceptEnv TERM_PROGRAM_VERSION COLORTERM TERM TERM_PROGRAM WEZTERM_REMOTE_PANE
-- sudo systemctl reload sshd

-- x86_64-pc-windows-msvc - Windows
-- x86_64-apple-darwin - macOS (Intel)
-- aarch64-apple-darwin - macOS (Apple Silicon)
--  - Linux

--- target_triple
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- Configs for Windows only
  -- font_dirs = {
  --     'C:\\Users\\whoami\\.dotfiles\\.fonts'
  -- }
  --DEFAULT_PROG = {'wsl.exe', '~', '-d', 'Ubuntu'}
  DEFAULT_PROG = {'wsl.exe', '~', '-d', 'Arch'}
  FONT_SIZE = 12.0

	LOCAL_CONFIG = {}
end

if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
	-- Configs for OSX only
	-- font_dirs    = { '$HOME/.dotfiles/.fonts' }
	FONT_SIZE = 16.0

	--- load local_config
	-- Write settings you don't want to make public, such as ssh_domains
	package.path = os.getenv("HOME") .. "/.local/share/wezterm/?.lua;" .. package.path
	local function load_local_config(module)
		local m = package.searchpath(module, package.path)
		if m == nil then
			return {}
		end
		return dofile(m)
	end

	LOCAL_CONFIG = load_local_config("local")
end

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	-- Configs for Linux only
	-- font_dirs    = { '$HOME/.dotfiles/.fonts' }
	FONT_SIZE = 12.0

	--- load local_config
	-- Write settings you don't want to make public, such as ssh_domains
	package.path = os.getenv("HOME") .. "/.local/share/wezterm/?.lua;" .. package.path
	local function load_local_config(module)
		local m = package.searchpath(module, package.path)
		if m == nil then
			return {}
		end
		return dofile(m)
	end

	LOCAL_CONFIG = load_local_config("local")
end

---------------------------------------------------------------
--- functions
---------------------------------------------------------------
local function enable_wayland()
	local wayland = os.getenv("XDG_SESSION_TYPE")
	if wayland == "wayland" then
		return true
	end
	return false
end

---------------------------------------------------------------
--- Merge the Config
---------------------------------------------------------------
local function create_ssh_domain_from_ssh_config(ssh_domains)
	if ssh_domains == nil then
		ssh_domains = {}
	end
	for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
		table.insert(ssh_domains, {
			name = host,
			remote_address = config.hostname .. ":" .. config.port,
			username = config.user,
			multiplexing = "None",
			assume_shell = "Posix",
		})
	end
	return { ssh_domains = ssh_domains }
end

---------------------------------------------------------------
--- Config
---------------------------------------------------------------
local config = {
	font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono", weight = "Regular", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } },
		{ family = "HackGen Console NF", weight = "Regular" },
		{ family = "UDEV Gothic 35NFLG" },
	}),
	font_size = FONT_SIZE,
	-- Font rendering improvements (using modern freetype settings)
	check_for_updates = false,
	use_ime = true,
	-- ime_preedit_rendering = "System",
	use_dead_keys = false,
	warn_about_missing_glyphs = false,
	-- enable_kitty_graphics = false,
	-- animation_fps = 1,
	-- Modern cursor
	default_cursor_style = "BlinkingBlock",
	cursor_blink_ease_in = "EaseIn",
	cursor_blink_ease_out = "EaseOut",
	cursor_blink_rate = 800,
	enable_wayland = enable_wayland(),
	-- https://github.com/wez/wezterm/issues/1772
	-- enable_wayland = false,
	-- Modern color scheme
	color_scheme = "Catppuccin Mocha",
	-- hide_tab_bar_if_only_one_tab = false, -- moved below
	adjust_window_size_when_changing_font_size = false,
	selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%",
	window_padding = {
		left = 20,
		right = 20,
		top = 20,
		bottom = 20,
	},
	use_fancy_tab_bar = true,
	tab_bar_at_bottom = false,
	show_new_tab_button_in_tab_bar = false,
	colors = {
		-- Modern color overrides for Catppuccin Mocha
		foreground = "#CDD6F4",
		background = "#1E1E2E",
		cursor_bg = "#F5E0DC",
		cursor_fg = "#1E1E2E",
		cursor_border = "#F5E0DC",
		selection_fg = "#1E1E2E",
		selection_bg = "#F5E0DC",
		scrollbar_thumb = "#585B70",
		split = "#6C7086",
		
		ansi = {
			"#45475A", -- black
			"#F38BA8", -- red
			"#A6E3A1", -- green
			"#F9E2AF", -- yellow
			"#89B4FA", -- blue
			"#F5C2E7", -- magenta
			"#94E2D5", -- cyan
			"#BAC2DE", -- white
		},
		brights = {
			"#585B70", -- bright black
			"#F38BA8", -- bright red
			"#A6E3A1", -- bright green
			"#F9E2AF", -- bright yellow
			"#89B4FA", -- bright blue
			"#F5C2E7", -- bright magenta
			"#94E2D5", -- bright cyan
			"#A6ADC8", -- bright white
		},
		
		tab_bar = {
			background = "#11111B",
			active_tab = {
				bg_color = "#89B4FA",
				fg_color = "#1E1E2E",
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "#313244",
				fg_color = "#CDD6F4",
			},
			inactive_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
				intensity = "Bold",
			},
			new_tab = {
				bg_color = "#313244",
				fg_color = "#CDD6F4",
			},
			new_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
				intensity = "Bold",
			},
		},
	},
	-- exit_behavior = "CloseOnCleanExit",
	-- tab_bar_at_bottom = false,
	-- window_close_confirmation = "AlwaysPrompt",
	window_background_opacity = 0.95,
	macos_window_background_blur = 30,
	-- Modern window decorations
	window_decorations = "TITLE | RESIZE",
	window_close_confirmation = "NeverPrompt",
	-- Smooth animations
	animation_fps = 60,
	max_fps = 60,
	-- Additional modern effects
	text_background_opacity = 1.0,
	-- Enable ligatures and advanced font features
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	-- Improved text rendering
	freetype_load_target = "HorizontalLcd",
	freetype_render_target = "HorizontalLcd",
	disable_default_key_bindings = true,
	-- visual_bell = {
	-- 	fade_in_function = "EaseIn",
	-- 	fade_in_duration_ms = 150,
	-- 	fade_out_function = "EaseOut",
	-- 	fade_out_duration_ms = 150,
	-- },
	-- separate <Tab> <C-i>
	-- enable_csi_u_key_encoding = true,
	-- Disable leader key to avoid conflicts with tmux
	-- leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = keybinds.create_keybinds(),
	key_tables = keybinds.key_tables,
	mouse_bindings = keybinds.mouse_bindings,
	-- https://github.com/wez/wezterm/issues/2756
	-- webgpu_preferred_adapter = gpus[1],
	-- front_end = "WebGpu",
	default_prog = DEFAULT_PROG,
	-- Disable built-in multiplexer to use tmux
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	unix_domains = {},
	-- Disable multiplexing completely
	mux_server_port = nil,
}

local merged_config = utils.merge_tables(config, LOCAL_CONFIG)
return utils.merge_tables(merged_config, create_ssh_domain_from_ssh_config(merged_config.ssh_domains))
