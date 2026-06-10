local wezterm = require("wezterm")
-- local act = wezterm.action
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nightfox"]
local gpus = wezterm.gui.enumerate_gpus()
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
  font_dirs = {
    'C:\\Windows\\Fonts',
    'C:\\Users\\' .. os.getenv("USERNAME") .. '\\AppData\\Local\\Microsoft\\Windows\\Fonts',
    'C:\\Users\\' .. os.getenv("USERNAME") .. '\\.dotfiles\\.fonts'
  }

  -- WSL Startup Optimization: defaulting to archlinux directly
  -- to avoid the overhead of `wsl --status` and `wsl --list` checks.
  DEFAULT_PROG = { 'wsl.exe', '--cd', '~', '-d', 'archlinux' }
  FONT_SIZE = 12.0

	-- Windows専用: Leader Key廃止 (Altベースに変更)
	LEADER_CONFIG = nil

	-- Windows固有のローカル設定
	LOCAL_CONFIG = {
		-- Windows専用: ステータスバーを常に表示（Leader Keyインジケーター表示のため）
		hide_tab_bar_if_only_one_tab = false,
		-- IME設定強化
		ime_preedit_rendering = "System",
		-- Windows固有のキーバインド
		send_composed_key_when_left_alt_is_pressed = false,
		send_composed_key_when_right_alt_is_pressed = true,
		-- Windows GPU設定
		-- 注意: WebGpuでは window_background_opacity（透過）が動作しない
		-- 透過を使用する場合はOpenGLを使用すること
		-- webgpu_preferred_adapter = gpus and gpus[1] or nil,
		webgpu_preferred_adapter = gpus and gpus[1] or nil,
		front_end = "WebGpu",
		-- front_end = "OpenGL",
		-- Windows最適化：DirectWriteレンダリング
		freetype_load_target = "Normal",
		freetype_render_target = "Normal",
		-- Windows最適化：EGLを使用（OpenGLのパフォーマンス向上）
		prefer_egl = true,
		-- ハイパフォーマンスGPUを優先使用
		webgpu_power_preference = "HighPerformance",
		-- WebGpu使用時は透過を無効化（パフォーマンス優先）
		window_background_opacity = 1.0,
		-- WSLエラー対応：プロセス終了動作の最適化
		exit_behavior = "Close",
		-- WSL最適化設定
		allow_win32_input_mode = true,
		-- WSL環境での入力遅延削減
		canonicalize_pasted_newlines = "None",
		-- WSL用ターミナル設定
		term = "xterm-256color",
		-- WSL環境でのスクロール最適化
		alternate_buffer_wheel_scroll_speed = 3,
	}
end

if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
	-- Configs for OSX only
	-- font_dirs    = { '$HOME/.dotfiles/.fonts' }
	FONT_SIZE = 16.0

	-- macOS: 外部tmuxを使用するためLeader Keyは無効
	LEADER_CONFIG = nil

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
	-- macOS用フォントレンダリング最適化
	LOCAL_CONFIG.freetype_load_target = "HorizontalLcd"
	LOCAL_CONFIG.freetype_render_target = "HorizontalLcd"
end

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	-- Configs for Linux only
	-- font_dirs    = { '$HOME/.dotfiles/.fonts' }
	FONT_SIZE = 12.0

	-- Linux: 外部tmuxを使用するためLeader Keyは無効
	LEADER_CONFIG = nil

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
	-- Linux用フォントレンダリング最適化
	LOCAL_CONFIG.freetype_load_target = "HorizontalLcd"
	LOCAL_CONFIG.freetype_render_target = "HorizontalLcd"
	-- Linux + Wayland + NVIDIA: ウィンドウが表示されない問題の対策（X11モードで動作）
	LOCAL_CONFIG.front_end = "WebGpu"
	LOCAL_CONFIG.enable_wayland = false
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
		{ family = "Moralerspace Argon", weight = "Regular" },
		{ family = "JetBrainsMono Nerd Font", weight = "Regular", harfbuzz_features = { "calt=1", "clig=1", "liga=1" } },
		{ family = "HackGen Console NF" }, -- 旧資産との互換用 fallback
		"Noto Color Emoji",  -- 絵文字用
		"Segoe UI Emoji",    -- Windows標準フォールバック
	}),
	font_size = FONT_SIZE,
	-- Font rendering improvements (using modern freetype settings)
	check_for_updates = false,
	use_ime = true,
	-- ime_preedit_rendering = "System",
	use_dead_keys = false,
	warn_about_missing_glyphs = false,
	-- Modern cursor
	default_cursor_style = "BlinkingBlock",
	cursor_blink_ease_in = "EaseIn",
	cursor_blink_ease_out = "EaseOut",
	cursor_blink_rate = 800,
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
	use_fancy_tab_bar = false,  -- Retroスタイル（カスタマイズ性が高い）
	tab_bar_at_bottom = false,
	show_new_tab_button_in_tab_bar = false,
	tab_max_width = 32,  -- タブの最大幅を設定
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
			-- Retroスタイル用: より深い背景色でコントラスト向上
			background = "#181825",  -- Catppuccin Mantle
			active_tab = {
				bg_color = "#89B4FA",  -- Blue - アクティブタブ
				fg_color = "#1E1E2E",  -- Base - 暗いテキストで高コントラスト
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "#313244",  -- Surface0 - 非アクティブ
				fg_color = "#A6ADC8",  -- Subtext0 - 少し暗めのテキスト
			},
			inactive_tab_hover = {
				bg_color = "#45475A",  -- Surface1 - ホバー時
				fg_color = "#CDD6F4",  -- Text - 明るいテキスト
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
	window_background_opacity = 0.90,  -- グローバル透過設定（全OS共通）
	macos_window_background_blur = 30,
	-- ウィンドウ装飾（OS別で上書き）
	window_decorations = "TITLE | RESIZE",
	window_close_confirmation = "NeverPrompt",
	-- 全OS共通：パフォーマンス設定
	animation_fps = 120,
	max_fps = 120,
	-- 全OS共通：スクロールパフォーマンス
	scrollback_lines = 30000,
	-- 入力遅延最適化：最小限の効果的設定
	native_macos_fullscreen_mode = false,
	automatically_reload_config = true,
	-- 最も効果的な入力最適化
	skip_close_confirmation_for_processes_named = {"nvim", "vim", "nano"},
	-- レンダリング最適化
	enable_kitty_graphics = false,
	enable_wayland = enable_wayland(),
	-- Additional modern effects
	text_background_opacity = 1.0,
	-- Enable ligatures and advanced font features
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	disable_default_key_bindings = true,
	-- Leader key (Windows専用: tmux風操作, macOS/Linux: 外部tmux使用)
	leader = LEADER_CONFIG,
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
	-- GPU設定（デフォルト無効、OS別で最適化）
	-- webgpu_preferred_adapter = gpus and gpus[1] or nil,
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
