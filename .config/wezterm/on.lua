local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nightfox"]
local act = wezterm.action
local mux = wezterm.mux

local function create_tab_title(tab, tabs, panes, config, hover, max_width)
	local user_title = tab.active_pane.user_vars.panetitle
	if user_title ~= nil and #user_title > 0 then
		return tab.tab_index + 1 .. " " .. user_title
	end

	-- プロセス名を取得
	local process_name = utils.basename(tab.active_pane.foreground_process_name)

	-- プロセス名に応じたアイコン選択
	local process_icons = {
		["nvim"] = wezterm.nerdfonts.custom_vim,
		["vim"] = wezterm.nerdfonts.dev_vim,
		["zsh"] = wezterm.nerdfonts.dev_terminal,
		["bash"] = wezterm.nerdfonts.cod_terminal_bash,
		["fish"] = wezterm.nerdfonts.md_fish,
		["git"] = wezterm.nerdfonts.dev_git,
		["node"] = wezterm.nerdfonts.md_nodejs,
		["python"] = wezterm.nerdfonts.dev_python,
		["docker"] = wezterm.nerdfonts.linux_docker,
		["cargo"] = wezterm.nerdfonts.dev_rust,
		["go"] = wezterm.nerdfonts.seti_go,
		["ruby"] = wezterm.nerdfonts.cod_ruby,
		["npm"] = wezterm.nerdfonts.md_npm,
		["ssh"] = wezterm.nerdfonts.md_ssh,
	}

	local icon = process_icons[process_name] or wezterm.nerdfonts.cod_terminal
	local title = wezterm.truncate_right(process_name, max_width - 10)

	if title == "" then
		local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)]", "%2")
		dir = utils.convert_useful_path(dir)
		title = wezterm.truncate_right(dir, max_width - 10)
		icon = wezterm.nerdfonts.md_folder
	end

	-- コピーモード等の表示
	local copy_mode, n = string.gsub(tab.active_pane.title, "(.+) mode: .*", "%1", 1)
	local mode_prefix = ""
	if copy_mode ~= nil and n ~= 0 then
		mode_prefix = wezterm.nerdfonts.fa_copy .. " "
	end

	-- ペイン数表示（複数ある場合）
	local pane_count = ""
	if #tab.panes > 1 then
		pane_count = " " .. wezterm.nerdfonts.md_tab .. #tab.panes
	end

	return string.format("%s%s %d %s%s", mode_prefix, icon, tab.tab_index + 1, title, pane_count)
end

---------------------------------------------------------------
--- wezterm on
---------------------------------------------------------------
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = create_tab_title(tab, tabs, panes, config, hover, max_width)

	-- Slant Powerline セパレーター（より洗練されたスタイル）
	local SLANT_LEFT = utf8.char(0xe0bc)   --
	local SLANT_RIGHT = utf8.char(0xe0ba)  --

	-- Catppuccin Mocha カラーパレット
	local colors = {
		base = "#1E1E2E",        -- 背景
		mantle = "#181825",      -- さらに暗い背景
		surface0 = "#313244",    -- 非アクティブタブ
		surface1 = "#45475A",    -- ホバー時
		blue = "#89B4FA",        -- アクティブタブ
		text = "#CDD6F4",        -- テキスト
		subtext0 = "#A6ADC8",    -- 非アクティブテキスト
	}

	local background
	local foreground
	local edge_background = colors.mantle

	if tab.is_active then
		-- アクティブタブ: 明るい青背景 + 暗いテキスト
		background = colors.blue
		foreground = colors.base
	elseif hover then
		-- ホバー時: ライトグレー背景
		background = colors.surface1
		foreground = colors.text
	else
		-- 非アクティブタブ: ダークグレー背景
		background = colors.surface0
		foreground = colors.subtext0
	end

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = background } },
		{ Text = SLANT_RIGHT },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = background } },
		{ Text = SLANT_LEFT },
		{ Attribute = { Intensity = "Normal" } },
	}
end)

-- https://github.com/wez/wezterm/issues/1680
local function update_window_background(window, pane)
	local overrides = window:get_config_overrides() or {}
	-- If there's no foreground process, assume that we are "wezterm connect" or "wezterm ssh"
	-- and use a different background color
	-- if pane:get_foreground_process_name() == nil then
	-- 	-- overrides.colors = { background = "blue" }
	-- 	overrides.color_scheme = "Red Alert"
	-- end

	if overrides.color_scheme == nil then
		return
	end
	if pane:get_user_vars().production == "1" then
		overrides.color_scheme = "OneHalfDark"
	end
	window:set_config_overrides(overrides)
end

local function update_tmux_style_tab(window, pane)
	local cwd_uri = pane:get_current_working_dir()
	local hostname, cwd = utils.split_from_url(cwd_uri)
	return {
		{ Attribute = { Underline = "Single" } },
		{ Attribute = { Italic = true } },
		{ Text = hostname },
	}
end

local function update_ssh_status(window, pane)
	local text = pane:get_domain_name()
	if text == "local" then
		text = ""
	end
	return {
		{ Attribute = { Italic = true } },
		{ Text = text .. " " },
	}
end

local function display_ime_on_right_status(window, pane)
	local compose = window:composition_status()
	if compose then
		compose = "COMPOSING: " .. compose
	end
	window:set_right_status(compose)
end

local function display_copy_mode(window)
	local results = {}
	local name = window:active_key_table()
	if name then
		-- アイコン付きモード表示
		local mode_icons = {
			copy_mode = wezterm.nerdfonts.fa_copy,
			search_mode = wezterm.nerdfonts.fa_search,
			resize_pane = wezterm.nerdfonts.md_resize,
		}
		local icon = mode_icons[name] or wezterm.nerdfonts.cod_terminal
		name = icon .. " " .. name
	else
		name = wezterm.nerdfonts.cod_terminal .. " default"
	end
	table.insert(results, name)
	return results
end

local function display_leader_status(window)
	local results = {}
	if window:leader_is_active() then
		-- スタイリッシュなLeader Keyインジケーター
		table.insert(results, wezterm.nerdfonts.fa_rocket .. " LEADER")
	end
	return results
end

local function get_current_working_dir_status(pane)
	local results = {}
	local cwd_url_object = pane:get_current_working_dir()

	if cwd_url_object then
		local cwd_path = cwd_url_object.path -- Urlオブジェクトのpathプロパティから文字列を取得
		if #cwd_path >= 8 then -- 文字列の長さをチェック
			local slash = cwd_path:find("/")
			local cwd = ""
			local hostname = ""
			if slash then
				hostname = cwd_path:sub(1, slash - 1)
				-- Remove the domain name portion of the hostname
				local dot = hostname:find("[.]")
				if dot then
					hostname = hostname:sub(1, dot - 1)
				end
				-- and extract the cwd from the uri
				cwd = cwd_path:sub(slash)

				if hostname then
					hostname = wezterm.hostname()
				end

				-- アイコン付きディレクトリ表示
				table.insert(results, wezterm.nerdfonts.md_folder .. " " .. cwd)
				table.insert(results, wezterm.nerdfonts.md_laptop .. " " .. hostname)
			end
		end
	end
	return results
end

local function get_datetime_status()
	local results = {}
	local date = wezterm.strftime("%Y-%m-%d %H:%M")
	-- アイコン付き日時表示
	table.insert(results, wezterm.nerdfonts.md_calendar_clock .. " " .. date)
	return results
end

local function get_battery_status()
	local results = {}
	for _, b in ipairs(wezterm.battery_info()) do
		if b.state ~= "Empty" then
			-- 充電状態に応じたアイコン選択
			local battery_icon
			local charge = b.state_of_charge * 100

			if b.state == "Charging" then
				battery_icon = wezterm.nerdfonts.md_battery_charging
			elseif charge > 80 then
				battery_icon = wezterm.nerdfonts.md_battery
			elseif charge > 50 then
				battery_icon = wezterm.nerdfonts.md_battery_60
			elseif charge > 20 then
				battery_icon = wezterm.nerdfonts.md_battery_40
			else
				battery_icon = wezterm.nerdfonts.md_battery_20
			end

			table.insert(results, string.format("%s %.0f%%", battery_icon, charge))
		end
	end
	return results
end

wezterm.on("update-status", function(window, pane)
	-- local tmux = update_tmux_style_tab(window, pane)
	local ssh = update_ssh_status(window, pane)
	update_window_background(window, pane)
	-- wezterm.log_error(status)
	-- window:set_right_status(wezterm.format(status))

	-- Each element holds the text for a cell in a "powerline" style << fade
	local cells = {}
	cells = utils.merge_lists(cells, display_leader_status(window))  -- Leader Key indicator (Windows only)
	cells = utils.merge_lists(cells, display_copy_mode(window))
	cells = utils.merge_lists(cells, get_current_working_dir_status(pane))
	cells = utils.merge_lists(cells, get_datetime_status())
	cells = utils.merge_lists(cells, get_battery_status())

	-- Slant Powerline セパレーター（タブと統一）
	local SLANT_LEFT = utf8.char(0xe0bc)

	-- Catppuccin Mocha Color Palette - モダンで洗練されたグラデーション
	local colors = {
		"#89B4FA", -- Blue (Leader Key - 目立つ色)
		"#CBA6F7", -- Mauve (Mode indicator)
		"#313244", -- Surface0 (Working directory)
		"#45475A", -- Surface1 (Date/Time)
		"#585B70", -- Surface2 (Battery)
	}

	-- テキスト色: Catppuccin Mocha Text
	local text_fg = "#CDD6F4"

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements with improved styling
	local function push(text, is_last)
		local cell_no = num_cells + 1

		-- Leader KeyとModeには高コントラストなテキスト色を使用
		local fg_color = text_fg
		if cell_no == 1 or cell_no == 2 then
			fg_color = "#1E1E2E" -- Catppuccin Base (dark) - 高コントラスト
		end

		-- セルの内容を描画
		table.insert(elements, { Foreground = { Color = fg_color } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } }) -- Bold text
		table.insert(elements, { Text = " " .. text .. " " })
		table.insert(elements, { Attribute = { Intensity = "Normal" } })

		-- セパレーター（セルの後に描画）
		if not is_last then
			-- 前景色：現在のセルの背景色、背景色：次のセルの背景色
			table.insert(elements, { Foreground = { Color = colors[cell_no] } })
			table.insert(elements, { Background = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SLANT_LEFT })
		end

		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	-- wezterm.log_error(elements)
	window:set_right_status(wezterm.format(elements))
end)

---@diagnostic disable-next-line: unused-local
wezterm.on("toggle-tmux-keybinds", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.95
		overrides.keys = keybinds.default_keybinds
	else
		overrides.window_background_opacity = nil
		overrides.keys = utils.merge_lists(keybinds.default_keybinds, keybinds.tmux_keybinds)
	end
	window:set_config_overrides(overrides)
end)

local io = require("io")
local os = require("os")

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
	local scrollback = pane:get_lines_as_text()
	local name = os.tmpname()
	local f = io.open(name, "w+")
	if f ~= nil then
		f:write(scrollback)
		f:flush()
		f:close()
		window:perform_action(
			act({
				SpawnCommandInNewTab = {
					args = { "nvim", name },
				},
			}),
			pane
		)
		wezterm.sleep_ms(1000)
		os.remove(name)
	end
end)
