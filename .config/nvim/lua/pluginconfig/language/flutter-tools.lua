-- ===== FLUTTER-TOOLS.NVIM CONFIGURATION =====
-- Flutter開発統合ツールの包括的設定
-- =============================================

local flutter_tools = require("flutter-tools")

-- Flutter SDK自動検出
local function get_flutter_sdk()
	local flutter_sdk = vim.fn.getenv("FLUTTER_SDK")
	if flutter_sdk and flutter_sdk ~= vim.NIL then
		return flutter_sdk
	end
	
	-- 一般的なパスをチェック
	local common_paths = {
		vim.fn.expand("~/flutter"),
		vim.fn.expand("~/Development/flutter"),
		vim.fn.expand("~/fvm/default"),
		"/usr/local/flutter",
		"/opt/flutter",
	}
	
	for _, path in ipairs(common_paths) do
		if vim.fn.isdirectory(path) == 1 then
			return path
		end
	end
	
	-- flutter コマンドから推測
	local flutter_cmd = vim.fn.system("which flutter"):gsub("\n", "")
	if flutter_cmd and flutter_cmd ~= "" then
		local flutter_path = vim.fn.fnamemodify(flutter_cmd, ":h:h")
		if vim.fn.isdirectory(flutter_path) == 1 then
			return flutter_path
		end
	end
	
	return nil
end

-- Dart SDK自動検出
local function get_dart_sdk()
	local dart_sdk = vim.fn.getenv("DART_SDK")
	if dart_sdk and dart_sdk ~= vim.NIL then
		return dart_sdk
	end
	
	-- Flutter SDKからDart SDKを推測
	local flutter_sdk = get_flutter_sdk()
	if flutter_sdk then
		local dart_path = flutter_sdk .. "/bin/cache/dart-sdk"
		if vim.fn.isdirectory(dart_path) == 1 then
			return dart_path
		end
	end
	
	return nil
end

-- プロジェクトルート検出
local function get_project_root()
	return vim.fn.getcwd()
end

-- ===== FLUTTER-TOOLS SETUP =====
flutter_tools.setup({
	-- UI設定
	ui = {
		border = "rounded",
		notification_style = "nvim-notify",
	},

	-- 装飾設定
	decorations = {
		statusline = {
			app_version = true,
			device = true,
			project_config = true,
		},
	},

	-- デバッガー設定
	debugger = {
		enabled = true,
		run_via_dap = true,
		exception_breakpoints = {},
		register_configurations = function(_)
			require("dap").configurations.dart = {}
			require("dap.ext.vscode").load_launchjs()
		end,
	},

	-- Flutter実行設定
	flutter_path = get_flutter_sdk() and (get_flutter_sdk() .. "/bin/flutter") or "flutter",
	flutter_lookup_cmd = "whereis flutter",
	
	-- FVM（Flutter Version Management）サポート
	fvm = true,
	
	-- Widget guides設定
	widget_guides = {
		enabled = true,
	},

	-- 終了時の動作
	closing_tags = {
		highlight = "Comment",
		prefix = "// ",
		enabled = true,
	},

	-- Developer tools設定
	dev_tools = {
		autostart = false,
		auto_open_browser = false,
	},

	-- ホットリロード設定
	hot_restart = {
		enabled = true,
	},

	-- アウトライン設定
	outline = {
		open_cmd = "30vnew",
		auto_open = false,
	},

	-- LSP設定
	lsp = {
		color = {
			enabled = true,
			background = false,
			background_color = nil,
			foreground = false,
			virtual_text = true,
			virtual_text_str = "■",
		},
		
		-- LSPハンドラーのカスタマイズ
		on_attach = function(client, bufnr)
			-- LSP共通設定があれば適用
			if vim.g.lsp_on_attach then
				vim.g.lsp_on_attach(client, bufnr)
			end
			
			-- Flutter特有のキーマップ
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			vim.keymap.set('n', '<leader>Fr', '<cmd>FlutterRun<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fh', '<cmd>FlutterReload<cr>', bufopts)
			vim.keymap.set('n', '<leader>FR', '<cmd>FlutterRestart<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fq', '<cmd>FlutterQuit<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fd', '<cmd>FlutterDebug<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fo', '<cmd>FlutterOutlineToggle<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fw', '<cmd>FlutterReloadWidgets<cr>', bufopts)
			vim.keymap.set('n', '<leader>Ft', '<cmd>FlutterDevTools<cr>', bufopts)
			vim.keymap.set('n', '<leader>Fc', '<cmd>FlutterLogClear<cr>', bufopts)
		end,
		
		-- Dart LSP設定
		settings = {
			dart = {
				analysisExcludedFolders = {
					vim.fn.expand("~/.pub-cache"),
					vim.fn.expand("~/.flutter"),
				},
				updateImportsOnRename = true,
				completeFunctionCalls = true,
				showTodos = true,
			},
		},
	},
})

-- ===== FLUTTER コマンド拡張 =====
-- Flutter プロジェクト検出
local function is_flutter_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

-- Flutter デバイス選択
local function flutter_device_selector()
	if not is_flutter_project() then
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
		return
	end
	
	vim.cmd("FlutterDevices")
end

-- Flutter エミュレーター起動
local function flutter_emulator_launcher()
	vim.cmd("FlutterEmulators")
end

-- Flutter プロジェクト作成
local function flutter_create_project()
	local project_name = vim.fn.input("Project name: ")
	if project_name and project_name ~= "" then
		local cmd = string.format("!flutter create %s", project_name)
		vim.cmd(cmd)
	end
end

-- ===== GLOBAL FUNCTIONS =====
-- グローバル関数として登録
_G.flutter_device_selector = flutter_device_selector
_G.flutter_emulator_launcher = flutter_emulator_launcher
_G.flutter_create_project = flutter_create_project

-- ===== AUTO COMMANDS =====
vim.api.nvim_create_augroup("FlutterTools", { clear = true })

-- Dartファイル保存時のホットリロード
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "FlutterTools",
	pattern = "*.dart",
	callback = function()
		if is_flutter_project() then
			-- Flutter実行中の場合のみホットリロード
			vim.cmd("silent! FlutterReload")
		end
	end,
})

-- Flutter プロジェクト検出時の初期化
vim.api.nvim_create_autocmd("VimEnter", {
	group = "FlutterTools",
	callback = function()
		if is_flutter_project() then
			vim.notify("Flutter project detected", vim.log.levels.INFO)
			-- 必要に応じて自動的にLSPを開始
		end
	end,
})

-- ===== STATUS LINE INTEGRATION =====
-- ステータスラインでFlutter情報表示
vim.g.flutter_show_log_on_run = "tab"
vim.g.flutter_show_log_on_attach = "tab"

-- Flutter ステータス取得関数
function _G.get_flutter_status()
	if is_flutter_project() then
		return "🎯 Flutter"
	end
	return ""
end