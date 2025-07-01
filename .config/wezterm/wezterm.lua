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
	
	-- Wayland-specific optimizations
	if enable_wayland() then
		local wayland_env = detect_wayland_environment()
		
		-- GPU acceleration optimizations for Wayland
		LOCAL_CONFIG.front_end = "WebGpu"
		LOCAL_CONFIG.webgpu_power_preference = "HighPerformance"
		LOCAL_CONFIG.webgpu_preferred_adapter = {
			backend = "Vulkan",  -- Most stable on Wayland
			device_type = "DiscreteGpu"
		}
		
		-- Wayland-specific rendering settings
		LOCAL_CONFIG.prefer_egl = true
		LOCAL_CONFIG.enable_wayland = true
		
		-- IME optimizations for Wayland
		LOCAL_CONFIG.ime_preedit_rendering = "Builtin"  -- Better for Wayland
		LOCAL_CONFIG.use_dead_keys = false  -- Improve IME responsiveness
		
		-- Detect Japanese IME systems
		local ime_programs = { "fcitx", "fcitx5", "ibus", "mozc" }
		for _, ime in ipairs(ime_programs) do
			local handle = io.popen("pgrep " .. ime .. " 2>/dev/null")
			if handle then
				local result = handle:read("*l")
				handle:close()
				if result and result ~= "" then
					-- Found IME, set specific optimizations
					LOCAL_CONFIG.xim_im_name = ime
					if ime == "fcitx5" then
						LOCAL_CONFIG.bypass_mouse_reporting_modifiers = "SHIFT"
					end
					break
				end
			end
		end
		
		-- Fractional scaling and font rendering optimizations
		LOCAL_CONFIG.dpi = nil  -- Auto-detect DPI
		LOCAL_CONFIG.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
		LOCAL_CONFIG.custom_block_glyphs = false
		
		-- Enhanced font rendering for Wayland
		LOCAL_CONFIG.freetype_load_flags = "NO_HINTING"
		LOCAL_CONFIG.freetype_load_target = "Normal"
		LOCAL_CONFIG.freetype_render_target = "Normal"
		LOCAL_CONFIG.font_shaper = "Harfbuzz"  -- Recommended for Wayland
		
		-- High DPI optimizations
		LOCAL_CONFIG.assume_emoji_presentation = true
		LOCAL_CONFIG.warn_about_missing_glyphs = false
		
		-- Performance optimizations for Wayland
		LOCAL_CONFIG.animation_fps = 60
		LOCAL_CONFIG.max_fps = 60
		LOCAL_CONFIG.cursor_blink_rate = 500  -- Lighter for Wayland
		LOCAL_CONFIG.cursor_thickness = 1.0
		
		-- Memory optimizations
		LOCAL_CONFIG.scrollback_lines = 5000  -- Reduced for Wayland performance
		
		-- Input optimizations
		LOCAL_CONFIG.enable_csi_u_key_encoding = false  -- Disabled for Wayland stability
		LOCAL_CONFIG.send_composed_key_when_left_alt_is_pressed = false
		LOCAL_CONFIG.mouse_wheel_scrolls_tabs = false
		LOCAL_CONFIG.enable_scroll_bar = false
		
		-- Compositor-specific optimizations
		if wayland_env.is_sway then
			-- Sway optimizations
			LOCAL_CONFIG.window_background_opacity = 0.95
		elseif wayland_env.is_gnome then
			-- GNOME Shell optimizations
			LOCAL_CONFIG.integrated_title_button_style = "Gnome"
		elseif wayland_env.is_kde then
			-- KDE Plasma optimizations
			LOCAL_CONFIG.integrated_title_button_style = "Windows"
		elseif wayland_env.is_hyprland then
			-- Hyprland optimizations
			LOCAL_CONFIG.window_background_opacity = 0.90
		end
	end
end

---------------------------------------------------------------
--- functions
---------------------------------------------------------------
local function detect_wayland_environment()
	local session_type = os.getenv("XDG_SESSION_TYPE")
	local wayland_display = os.getenv("WAYLAND_DISPLAY")
	local compositor = os.getenv("XDG_CURRENT_DESKTOP")
	local session_desktop = os.getenv("XDG_SESSION_DESKTOP")
	
	local is_wayland = session_type == "wayland" or wayland_display ~= nil
	
	return {
		is_wayland = is_wayland,
		session_type = session_type,
		display = wayland_display,
		compositor = compositor,
		session_desktop = session_desktop,
		-- 詳細なコンポジター検出
		is_sway = compositor == "sway" or session_desktop == "sway",
		is_gnome = compositor == "GNOME" or string.find(compositor or "", "gnome"),
		is_kde = compositor == "KDE" or string.find(compositor or "", "plasma"),
		is_hyprland = compositor == "Hyprland" or session_desktop == "Hyprland",
	}
end

local function enable_wayland()
	return detect_wayland_environment().is_wayland
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
	-- Enhanced IME support for all platforms
	use_ime = true,
	-- Wayland-specific IME improvements  
	wayland_enable_ime = true,
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
	show_new_tab_button_in_tab_bar = true,
	new_tab_hover_bg_color = "#45475A",
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
				italic = false,
			},
			inactive_tab = {
				bg_color = "#313244",
				fg_color = "#CDD6F4",
				intensity = "Normal",
				italic = false,
			},
			inactive_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
				intensity = "Bold",
				italic = false,
			},
			new_tab = {
				bg_color = "#313244",
				fg_color = "#CDD6F4",
				intensity = "Normal",
			},
			new_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
				intensity = "Bold",
			},
			-- Enhanced tab bar styling
			inactive_tab_edge = "#585B70",
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
	-- Enhanced tab bar configuration
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	show_tab_index_in_tab_bar = true,
	tab_max_width = 32,
	unix_domains = {},
	-- Disable multiplexing completely
	mux_server_port = nil,
}

local merged_config = utils.merge_tables(config, LOCAL_CONFIG)
return utils.merge_tables(merged_config, create_ssh_domain_from_ssh_config(merged_config.ssh_domains))
