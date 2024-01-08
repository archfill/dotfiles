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
	font = wezterm.font("HackGen Console NF", { weight = "Regular", stretch = "Normal", italic = false }),
	-- font = wezterm.font("UDEV Gothic 35NFLG"),
	font_size = FONT_SIZE,
	check_for_updates = false,
	use_ime = true,
	-- ime_preedit_rendering = "System",
	use_dead_keys = false,
	warn_about_missing_glyphs = false,
	-- enable_kitty_graphics = false,
	-- animation_fps = 1,
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 0,
	enable_wayland = enable_wayland(),
	-- https://github.com/wez/wezterm/issues/1772
	-- enable_wayland = false,
	-- color_scheme = "nightfox",
	color_scheme = "tokyonight_night",
	hide_tab_bar_if_only_one_tab = false,
	adjust_window_size_when_changing_font_size = false,
	selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	use_fancy_tab_bar = false,
	colors = {
		tab_bar = {
			background = scheme.background,
			new_tab = { bg_color = "#2e3440", fg_color = scheme.ansi[8], intensity = "Bold" },
			new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.brights[8], intensity = "Bold" },
			-- format-tab-title
			-- active_tab = { bg_color = "#121212", fg_color = "#FCE8C3" },
			-- inactive_tab = { bg_color = scheme.background, fg_color = "#FCE8C3" },
			-- inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = "#FCE8C3" },
		},
	},
	-- exit_behavior = "CloseOnCleanExit",
	-- tab_bar_at_bottom = false,
	-- window_close_confirmation = "AlwaysPrompt",
	window_background_opacity = 0.9,
	disable_default_key_bindings = true,
	-- visual_bell = {
	-- 	fade_in_function = "EaseIn",
	-- 	fade_in_duration_ms = 150,
	-- 	fade_out_function = "EaseOut",
	-- 	fade_out_duration_ms = 150,
	-- },
	-- separate <Tab> <C-i>
	-- enable_csi_u_key_encoding = true,
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = keybinds.create_keybinds(),
	key_tables = keybinds.key_tables,
	mouse_bindings = keybinds.mouse_bindings,
	-- https://github.com/wez/wezterm/issues/2756
	-- webgpu_preferred_adapter = gpus[1],
	-- front_end = "WebGpu",
	default_prog = DEFAULT_PROG,
}

local merged_config = utils.merge_tables(config, LOCAL_CONFIG)
return utils.merge_tables(merged_config, create_ssh_domain_from_ssh_config(merged_config.ssh_domains))
