-- ===== PUBSPEC.NVIM CONFIGURATION =====
-- pubspec.yaml依存関係管理ツールの設定
-- =====================================

local pubspec = require("pubspec")

-- ===== PUBSPEC SETUP =====
pubspec.setup({
	-- Telescope統合設定
	telescope = {
		enable = true,
		theme = "dropdown",
		layout_config = {
			width = 0.8,
			height = 0.7,
		},
	},
	
	-- パッケージ情報表示設定
	package_info = {
		enable = true,
		hide_up_to_date = false,
		hide_unstable_versions = true,
	},
	
	-- 自動更新設定
	auto_update = {
		enable = false,  -- 手動更新を推奨
		interval = 3600, -- 1時間間隔
	},
	
	-- 通知設定
	notifications = {
		enable = true,
		level = "info",
	},
	
	-- キャッシュ設定
	cache = {
		enable = true,
		ttl = 300, -- 5分間キャッシュ
	},
})

-- ===== PUBSPEC AUTO COMMANDS =====
vim.api.nvim_create_augroup("PubspecSettings", { clear = true })

-- pubspec.yamlファイル用の設定
vim.api.nvim_create_autocmd("FileType", {
	group = "PubspecSettings",
	pattern = "yaml",
	callback = function()
		local filename = vim.fn.expand('%:t')
		if filename == "pubspec.yaml" then
			local bufnr = vim.api.nvim_get_current_buf()
			local opts = { buffer = bufnr, noremap = true, silent = true }
			
			-- ===== PUBSPEC SPECIFIC SETTINGS =====
			-- YAML設定
			vim.bo.expandtab = true
			vim.bo.shiftwidth = 2
			vim.bo.tabstop = 2
			vim.bo.softtabstop = 2
			
			-- 折り畳み設定
			vim.wo.foldmethod = "indent"
			vim.wo.foldlevel = 99
			
			-- ===== PUBSPEC KEYMAPS =====
			-- パッケージ情報表示
			vim.keymap.set('n', '<leader>Pp', function()
				require("pubspec").show_package_info()
			end, vim.tbl_extend('force', opts, { desc = "Show package info" }))
			
			-- パッケージ更新チェック
			vim.keymap.set('n', '<leader>Pu', function()
				require("pubspec").check_updates()
			end, vim.tbl_extend('force', opts, { desc = "Check package updates" }))
			
			-- 依存関係追加
			vim.keymap.set('n', '<leader>Pa', function()
				require("pubspec").add_dependency()
			end, vim.tbl_extend('force', opts, { desc = "Add dependency" }))
			
			-- 依存関係削除
			vim.keymap.set('n', '<leader>Pr', function()
				require("pubspec").remove_dependency()
			end, vim.tbl_extend('force', opts, { desc = "Remove dependency" }))
			
			-- パッケージ検索
			vim.keymap.set('n', '<leader>Ps', function()
				require("pubspec").search_packages()
			end, vim.tbl_extend('force', opts, { desc = "Search packages" }))
			
			-- pubspec.lock更新
			vim.keymap.set('n', '<leader>Pl', function()
				vim.cmd('terminal flutter pub get')
			end, vim.tbl_extend('force', opts, { desc = "Flutter pub get" }))
			
			-- 依存関係ツリー表示
			vim.keymap.set('n', '<leader>Pt', function()
				vim.cmd('terminal flutter pub deps')
			end, vim.tbl_extend('force', opts, { desc = "Show dependency tree" }))
			
			-- アウトデート依存関係表示
			vim.keymap.set('n', '<leader>Po', function()
				vim.cmd('terminal flutter pub outdated')
			end, vim.tbl_extend('force', opts, { desc = "Show outdated packages" }))
		end
	end,
})

-- pubspec.yamlファイル保存時の処理
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "PubspecSettings",
	pattern = "pubspec.yaml",
	callback = function()
		-- 保存時にパッケージ情報を更新
		vim.defer_fn(function()
			if pcall(require, "pubspec") then
				require("pubspec").refresh_cache()
				vim.notify("Pubspec cache refreshed", vim.log.levels.INFO)
			end
		end, 500)
	end,
})

-- ===== PUBSPEC UTILITY FUNCTIONS =====
-- Flutter プロジェクト検出
local function is_flutter_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

-- pubspec.yamlの内容を解析
local function parse_pubspec()
	local pubspec_path = vim.fn.getcwd() .. "/pubspec.yaml"
	if vim.fn.filereadable(pubspec_path) == 0 then
		return nil
	end
	
	local content = vim.fn.readfile(pubspec_path)
	local pubspec_data = {}
	local current_section = nil
	
	for _, line in ipairs(content) do
		local trimmed = vim.trim(line)
		if trimmed:match("^name:") then
			pubspec_data.name = trimmed:match("name:%s*(.+)")
		elseif trimmed:match("^version:") then
			pubspec_data.version = trimmed:match("version:%s*(.+)")
		elseif trimmed:match("^description:") then
			pubspec_data.description = trimmed:match("description:%s*(.+)")
		elseif trimmed:match("^dependencies:") then
			current_section = "dependencies"
			pubspec_data.dependencies = {}
		elseif trimmed:match("^dev_dependencies:") then
			current_section = "dev_dependencies"
			pubspec_data.dev_dependencies = {}
		elseif current_section and trimmed:match("^%s+%w+:") then
			local dep_name = trimmed:match("(%w+):")
			if dep_name then
				pubspec_data[current_section][dep_name] = true
			end
		end
	end
	
	return pubspec_data
end

-- プロジェクト情報表示
local function show_project_info()
	local pubspec_data = parse_pubspec()
	if not pubspec_data then
		vim.notify("No pubspec.yaml found", vim.log.levels.WARN)
		return
	end
	
	local info = string.format([[
Flutter Project: %s
Version: %s
Description: %s
Dependencies: %d
Dev Dependencies: %d
	]], 
		pubspec_data.name or "Unknown",
		pubspec_data.version or "Unknown", 
		pubspec_data.description or "No description",
		pubspec_data.dependencies and vim.tbl_count(pubspec_data.dependencies) or 0,
		pubspec_data.dev_dependencies and vim.tbl_count(pubspec_data.dev_dependencies) or 0
	)
	
	vim.notify(info, vim.log.levels.INFO)
end

-- Dart/Flutter バージョン確認
local function check_versions()
	local flutter_version = vim.fn.system("flutter --version"):match("Flutter ([%d%.]+)")
	local dart_version = vim.fn.system("dart --version 2>&1"):match("Dart SDK version: ([%d%.]+)")
	
	local info = string.format("Flutter: %s | Dart: %s", 
		flutter_version or "Not found", 
		dart_version or "Not found"
	)
	
	vim.notify(info, vim.log.levels.INFO)
end

-- ===== GLOBAL FUNCTIONS =====
_G.parse_pubspec = parse_pubspec
_G.show_project_info = show_project_info
_G.check_versions = check_versions

-- ===== PUBSPEC COMMANDS =====
-- カスタムコマンド定義
vim.api.nvim_create_user_command("PubspecInfo", show_project_info, {
	desc = "Show Flutter project info",
})

vim.api.nvim_create_user_command("FlutterVersions", check_versions, {
	desc = "Check Flutter and Dart versions",
})

vim.api.nvim_create_user_command("PubGet", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub get')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, {
	desc = "Run flutter pub get",
})

vim.api.nvim_create_user_command("PubUpgrade", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub upgrade')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, {
	desc = "Run flutter pub upgrade",
})

vim.api.nvim_create_user_command("PubOutdated", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub outdated')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, {
	desc = "Show outdated packages",
})

-- ===== TELESCOPE INTEGRATION =====
-- Telescopeでパッケージ検索
local function telescope_package_search()
	if not pcall(require, "telescope") then
		vim.notify("Telescope not available", vim.log.levels.WARN)
		return
	end
	
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	
	-- 人気のFlutterパッケージリスト
	local popular_packages = {
		"http", "provider", "riverpod", "bloc", "get", "dio", 
		"shared_preferences", "path_provider", "sqflite", "hive",
		"image_picker", "camera", "location", "permission_handler",
		"firebase_core", "firebase_auth", "cloud_firestore",
		"google_maps_flutter", "url_launcher", "webview_flutter",
		"flutter_launcher_icons", "flutter_native_splash",
		"json_annotation", "freezed", "build_runner",
	}
	
	pickers.new({}, {
		prompt_title = "Flutter Packages",
		finder = finders.new_table({
			results = popular_packages
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					local package_name = selection[1]
					vim.notify("Selected: " .. package_name, vim.log.levels.INFO)
					-- TODO: パッケージを実際にpubspec.yamlに追加
				end
			end)
			return true
		end,
	}):find()
end

_G.telescope_package_search = telescope_package_search

-- ===== STATUS LINE INTEGRATION =====
function _G.get_pubspec_status()
	if vim.fn.expand('%:t') == "pubspec.yaml" then
		local pubspec_data = parse_pubspec()
		if pubspec_data and pubspec_data.name then
			return "📦 " .. pubspec_data.name
		else
			return "📦 pubspec.yaml"
		end
	end
	return ""
end