local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["Catppuccin Mocha"]
local act = wezterm.action
local mux = wezterm.mux

local function create_tab_title(tab, tabs, panes, config, hover, max_width)
	-- タブ番号を表示
	local tab_index = tab.tab_index + 1
	
	-- ユーザー定義のタイトルがある場合
	local user_title = tab.active_pane.user_vars.panetitle
	if user_title ~= nil and #user_title > 0 then
		return tab_index .. ":" .. user_title
	end

	-- プロセス名を取得
	local process_name = utils.basename(tab.active_pane.foreground_process_name or "")
	
	-- プロセス名がない場合、ディレクトリ名を使用
	if process_name == "" then
		local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)]", "%2")
		dir = utils.convert_useful_path(dir)
		process_name = wezterm.truncate_right(dir, max_width - 3)
	else
		process_name = wezterm.truncate_right(process_name, max_width - 3)
	end

	-- コピーモード等の特殊状態を検出
	local copy_mode, n = string.gsub(tab.active_pane.title, "(.+) mode: .*", "%1", 1)
	if copy_mode ~= nil and n > 0 then
		return copy_mode .. " " .. tab_index .. ":" .. process_name
	end
	
	-- SSH接続の場合、ホスト名を表示
	local domain_name = tab.active_pane.domain_name
	if domain_name ~= "local" and domain_name ~= nil then
		return tab_index .. ":" .. domain_name .. "/" .. process_name
	end
	
	return tab_index .. ":" .. process_name
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

	-- Catppuccin Mocha colors
	local colors = {
		base = "#1e1e2e",
		mantle = "#181825", 
		crust = "#11111b",
		text = "#cdd6f4",
		subtext1 = "#bac2de",
		subtext0 = "#a6adc8",
		overlay2 = "#9399b2",
		overlay1 = "#7f849c",
		overlay0 = "#6c7086",
		surface2 = "#585b70",
		surface1 = "#45475a",
		surface0 = "#313244",
		blue = "#89b4fa",
		sapphire = "#74c7ec",
		sky = "#89dceb",
		teal = "#94e2d5",
		green = "#a6e3a1",
		yellow = "#f9e2af",
		peach = "#fab387",
		maroon = "#eba0ac",
		red = "#f38ba8",
		mauve = "#cba6f7",
		pink = "#f5c2e7",
		flamingo = "#f2cdcd",
		rosewater = "#f5e0dc",
	}

	-- Tab formatting with modern rounded corners
	local left_arrow = utf8.char(0xe0b6)
	local right_arrow = utf8.char(0xe0b4)
	
	local background = colors.surface0
	local foreground = colors.subtext1
	local edge_background = colors.crust

	if tab.is_active then
		background = colors.blue
		foreground = colors.crust
	elseif hover then
		background = colors.surface1
		foreground = colors.text
	end

	return {
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = background } },
		{ Text = left_arrow },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = background } },
		{ Text = right_arrow },
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
		name = "Mode: " .. name
	else
		name = "Mode: default"
	end
	table.insert(results, name)
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

				table.insert(results, cwd)
				table.insert(results, hostname)
			end
		end
	end
	return results
end

local function get_datetime_status()
	local results = {}
	local date = wezterm.strftime("%Y-%m-%d %H:%M")
	table.insert(results, date)
	return results
end

local function get_battery_status()
	local results = {}
	for _, b in ipairs(wezterm.battery_info()) do
		if not b.state == "Empty" then
			table.insert(results, string.format("%.0f%%", b.state_of_charge * 100))
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
	cells = utils.merge_lists(cells, display_copy_mode(window))
	cells = utils.merge_lists(cells, get_current_working_dir_status(pane))
	cells = utils.merge_lists(cells, get_datetime_status())
	cells = utils.merge_lists(cells, get_battery_status())

	-- The powerline < symbol
	-- local LEFT_ARROW = utf8.char(0xe0b3)
	-- The filled in variant of the < symbol
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	-- local SYMBOL = "|"

	-- Color palette for the backgrounds of each cell
	--
	-- nightfox
	-- black   = Shade.new("#393b44", 0.15, -0.15),
	-- red     = Shade.new("#c94f6d", 0.15, -0.15),
	-- green   = Shade.new("#81b29a", 0.10, -0.15),
	-- yellow  = Shade.new("#dbc074", 0.15, -0.15),
	-- blue    = Shade.new("#719cd6", 0.15, -0.15),
	-- magenta = Shade.new("#9d79d6", 0.30, -0.15),
	-- cyan    = Shade.new("#63cdcf", 0.15, -0.15),
	-- white   = Shade.new("#dfdfe0", 0.15, -0.15),
	-- orange  = Shade.new("#f4a261", 0.15, -0.15),
	-- pink    = Shade.new("#d67ad2", 0.15, -0.15),
	--
	-- comment = "#738091",
	--
	-- bg0     = "#131a24", -- Dark bg (status line and float)
	-- bg1     = "#192330", -- Default bg
	-- bg2     = "#212e3f", -- Lighter bg (colorcolm folds)
	-- bg3     = "#29394f", -- Lighter bg (cursor line)
	-- bg4     = "#39506d", -- Conceal, border fg
	--
	-- fg0     = "#d6d6d7", -- Lighter fg
	-- fg1     = "#cdcecf", -- Default fg
	-- fg2     = "#aeafb0", -- Darker fg (status line)
	-- fg3     = "#71839b", -- Darker fg (line numbers, fold colums)
	--
	-- sel0    = "#2b3b51", -- Popup bg, visual selection bg
	-- sel1    = "#3c5372", -- Popup sel bg, search bg
	local colors = {
		"#131a24",
		"#192330",
		"#212e3f",
		"#29394f",
		"#39506d",
	}

	-- Foreground color for the text across the fade
	-- local text_fg = "#c0c0c0"
	local text_fg = "#aeafb0"

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements
	local function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
			-- table.insert(elements, { Text = SYMBOL })
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
					args = { os.getenv("HOME") .. "/.local/share/zsh/zinit/polaris/bin/nvim", name },
				},
			}),
			pane
		)
		wezterm.sleep_ms(1000)
		os.remove(name)
	end
end)
