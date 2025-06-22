-- ===== NVIM-DAP CONFIGURATION =====
-- デバッグアダプタープロトコル統合設定
-- Flutter/Dart専用デバッグ環境
-- ===================================

local dap = require("dap")
local dapui = require("dapui")
local dap_virtual_text = require("nvim-dap-virtual-text")

-- ===== DAP UI SETUP =====
dapui.setup({
	-- UI設定
	icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
	mappings = {
		-- DAP UI内でのキーマップ
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	
	-- レイアウト設定
	layouts = {
		{
			elements = {
				-- サイドバー要素
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				-- ボトム要素
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 0.25,
			position = "bottom",
		},
	},
	
	-- ウィンドウ設定
	controls = {
		enabled = true,
		element = "repl",
		icons = {
			pause = "",
			play = "",
			step_into = "",
			step_over = "",
			step_out = "",
			step_back = "",
			run_last = "↻",
			terminate = "□",
		},
	},
	
	-- フローティングウィンドウ設定
	floating = {
		max_height = nil,
		max_width = nil,
		border = "rounded",
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	
	-- ウィンドウ設定
	windows = { indent = 1 },
	
	-- レンダリング設定
	render = {
		max_type_length = nil,
		max_value_lines = 100,
	},
})

-- ===== VIRTUAL TEXT SETUP =====
dap_virtual_text.setup({
	enabled = true,
	enabled_commands = true,
	highlight_changed_variables = true,
	highlight_new_as_changed = false,
	show_stop_reason = true,
	commented = false,
	only_first_definition = true,
	all_references = false,
	
	-- 仮想テキストフォーマット
	display_callback = function(variable, buf, stackframe, node, options)
		if options.virt_text_pos == 'inline' then
			return ' = ' .. variable.value
		else
			return variable.name .. ' = ' .. variable.value
		end
	end,
	
	-- フィルタリング
	virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
	
	-- アイコン設定
	all_frames = false,
	virt_lines = false,
	virt_text_win_col = nil,
})

-- ===== DART/FLUTTER DAP CONFIGURATION =====
-- Dart デバッガー設定
dap.adapters.dart = {
	type = 'executable',
	command = 'dart',
	args = { 'debug_adapter' },
}

-- Flutter デバッガー設定
dap.adapters.flutter = {
	type = 'executable',
	command = 'flutter',
	args = { 'debug_adapter' },
}

-- Dart設定
dap.configurations.dart = {
	{
		type = "dart",
		request = "launch",
		name = "Launch Dart",
		dartSdkPath = vim.fn.system("which dart"):gsub("\n", ""):gsub("/bin/dart", ""),
		flutterSdkPath = vim.fn.system("which flutter"):gsub("\n", ""):gsub("/bin/flutter", ""),
		program = "${workspaceFolder}/lib/main.dart",
		cwd = "${workspaceFolder}",
	},
	{
		type = "dart",
		request = "attach",
		name = "Attach to Dart",
		dartSdkPath = vim.fn.system("which dart"):gsub("\n", ""):gsub("/bin/dart", ""),
		flutterSdkPath = vim.fn.system("which flutter"):gsub("\n", ""):gsub("/bin/flutter", ""),
		cwd = "${workspaceFolder}",
	},
}

-- ===== DAP EVENT HANDLERS =====
-- デバッグセッション開始時にUI表示
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

-- デバッグセッション終了時にUI非表示
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

-- デバッグプロセス終了時にUI非表示
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- ===== KEYMAP MANAGEMENT =====
-- キーマップは keymap/plugins.lua で一元管理されています
-- 以下は参考用のコメント（実際のキーマップは keymap/plugins.lua を参照）
--
-- <leader>dc: Debug Continue
-- <leader>dn: Debug Step Over  
-- <leader>di: Debug Step Into
-- <leader>do: Debug Step Out
-- <leader>db: Toggle Breakpoint
-- <leader>dB: Conditional Breakpoint
-- <leader>dl: Log Point
-- <leader>dC: Clear All Breakpoints
-- <leader>dq: Debug Quit
-- <leader>dr: Debug Restart
-- <leader>d.: Debug Run Last
-- <leader>du: Debug Toggle UI
-- <leader>dR: Debug Toggle REPL
-- <leader>dh: Debug Hover/Eval
-- <leader>dw: Debug Watch Expression (visual mode)
-- <leader>Fd: Flutter Debug (dart files)

-- ===== DAP SIGNS =====
-- デバッグ用のサイン設定
vim.fn.sign_define('DapBreakpoint', {
	text = '🔴',
	texthl = 'DiagnosticError',
	linehl = '',
	numhl = 'DiagnosticError'
})

vim.fn.sign_define('DapBreakpointCondition', {
	text = '🟡',
	texthl = 'DiagnosticWarn',
	linehl = '',
	numhl = 'DiagnosticWarn'
})

vim.fn.sign_define('DapLogPoint', {
	text = '🔵',
	texthl = 'DiagnosticInfo',
	linehl = '',
	numhl = 'DiagnosticInfo'
})

vim.fn.sign_define('DapStopped', {
	text = '▶️',
	texthl = 'DiagnosticHint',
	linehl = 'CursorLine',
	numhl = 'DiagnosticHint'
})

vim.fn.sign_define('DapBreakpointRejected', {
	text = '❌',
	texthl = 'DiagnosticError',
	linehl = '',
	numhl = 'DiagnosticError'
})

-- ===== DAP COMMANDS =====
-- カスタムコマンド定義
vim.api.nvim_create_user_command("DapUIToggle", function()
	dapui.toggle()
end, {
	desc = "Toggle DAP UI",
})

vim.api.nvim_create_user_command("DapUIOpen", function()
	dapui.open()
end, {
	desc = "Open DAP UI",
})

vim.api.nvim_create_user_command("DapUIClose", function()
	dapui.close()
end, {
	desc = "Close DAP UI",
})

-- ===== UTILITY FUNCTIONS =====
-- Flutter プロジェクト用のデバッグ設定
local function setup_flutter_debug()
	local pubspec_path = vim.fn.getcwd() .. "/pubspec.yaml"
	if vim.fn.filereadable(pubspec_path) == 0 then
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
		return
	end
	
	-- Flutter専用の設定を適用
	dap.configurations.dart = vim.list_extend(dap.configurations.dart or {}, {
		{
			type = "flutter",
			request = "launch",
			name = "Launch Flutter (Debug)",
			dartSdkPath = vim.fn.system("which dart"):gsub("\n", ""):gsub("/bin/dart", ""),
			flutterSdkPath = vim.fn.system("which flutter"):gsub("\n", ""):gsub("/bin/flutter", ""),
			program = "${workspaceFolder}/lib/main.dart",
			cwd = "${workspaceFolder}",
			flutterMode = "debug",
			args = {},
		},
		{
			type = "flutter",
			request = "launch",
			name = "Launch Flutter (Profile)",
			dartSdkPath = vim.fn.system("which dart"):gsub("\n", ""):gsub("/bin/dart", ""),
			flutterSdkPath = vim.fn.system("which flutter"):gsub("\n", ""):gsub("/bin/flutter", ""),
			program = "${workspaceFolder}/lib/main.dart",
			cwd = "${workspaceFolder}",
			flutterMode = "profile",
			args = {},
		}
	})
end

-- デバッグセッション情報表示
local function show_debug_info()
	local session = dap.session()
	if session then
		vim.notify("Debug session active: " .. (session.config.name or "Unknown"), vim.log.levels.INFO)
	else
		vim.notify("No active debug session", vim.log.levels.WARN)
	end
end

-- ===== GLOBAL FUNCTIONS =====
_G.setup_flutter_debug = setup_flutter_debug
_G.show_debug_info = show_debug_info

-- ===== AUTO COMMANDS =====
vim.api.nvim_create_augroup("DapSettings", { clear = true })

-- Flutter プロジェクト検出時にFlutter デバッグ設定適用
vim.api.nvim_create_autocmd("VimEnter", {
	group = "DapSettings",
	callback = function()
		vim.defer_fn(setup_flutter_debug, 1000)
	end,
})

-- Dartファイル開いた時のデバッグ設定
vim.api.nvim_create_autocmd("FileType", {
	group = "DapSettings",
	pattern = "dart",
	callback = function()
		-- Dart特有のデバッグ設定があれば適用
		vim.notify("Dart debug environment loaded", vim.log.levels.INFO)
	end,
})

-- ===== STATUS LINE INTEGRATION =====
function _G.get_dap_status()
	local session = dap.session()
	if session then
		return "🐛 Debug"
	end
	return ""
end