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

  -- WSL自動検出とデフォルト設定（改善版）
  local function get_wsl_default()
    -- まず標準的なWSLコマンドでデフォルトディストリビューションを確認
    local handle = io.popen('wsl --status 2>nul')
    if handle then
      handle:close()
    end

    -- 利用可能なディストリビューション一覧を取得
    local distro_handle = io.popen('wsl --list --quiet 2>nul')
    if distro_handle then
      local result = distro_handle:read('*a')
      distro_handle:close()

      if result and result ~= '' then
        -- BOMや特殊文字を除去し、クリーンアップ
        result = result:gsub('\239\187\191', '') -- UTF-8 BOM除去
        result = result:gsub('\0', '') -- NULL文字除去

        local distros = {}
        for line in result:gmatch('[^\r\n]+') do
          local clean_line = line:gsub('^%s*', ''):gsub('%s*$', '') -- 前後の空白除去
          if clean_line and clean_line ~= '' then
            -- デフォルトマーク(*)を除去してディストリビューション名を取得
            local distro_name = clean_line:gsub('^%*%s*', ''):gsub('%s.*$', '')
            if distro_name and distro_name ~= '' then
              table.insert(distros, distro_name)
            end
          end
        end

        -- 利用可能なディストリビューションがある場合
        if #distros > 0 then
          -- 優先順位：Arch > Ubuntu > その他の最初のもの
          for _, distro in ipairs(distros) do
            if distro:lower():find('arch') then
              return {'wsl.exe', '-d', distro}
            end
          end
          for _, distro in ipairs(distros) do
            if distro:lower():find('ubuntu') then
              return {'wsl.exe', '-d', distro}
            end
          end
          -- どちらもない場合は最初のディストリビューション
          return {'wsl.exe', '-d', distros[1]}
        end
      end
    end

    -- WSLが利用できない場合の最終フォールバック
    return {'cmd.exe'}
  end

  DEFAULT_PROG = get_wsl_default()
  FONT_SIZE = 12.0

	-- Windows固有のローカル設定
	LOCAL_CONFIG = {
		-- Windows Terminal統合最適化
		win32_system_backdrop = "Auto",
		-- IME設定強化
		ime_preedit_rendering = "System",
		-- Windows固有のキーバインド
		send_composed_key_when_left_alt_is_pressed = false,
		send_composed_key_when_right_alt_is_pressed = true,
		-- Windows GPU最適化設定
		webgpu_preferred_adapter = gpus and gpus[1] or nil,
		front_end = "WebGpu",
		-- Windows最適化：DirectWriteレンダリング
		freetype_load_target = "Normal",
		freetype_render_target = "Normal",
		-- WSLエラー対応：プロセス終了動作の最適化
		exit_behavior = "Close",
	}
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
	-- Windows最適化：ウィンドウ装飾
	window_decorations = "TITLE | RESIZE",
	window_close_confirmation = "NeverPrompt",
	-- 全OS共通：パフォーマンス設定
	animation_fps = 120,
	max_fps = 120,
	-- 全OS共通：スクロールパフォーマンス
	scrollback_lines = 10000,
	-- Additional modern effects
	text_background_opacity = 1.0,
	-- Enable ligatures and advanced font features
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	-- フォントレンダリング（macOS/Linux用デフォルト）
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
