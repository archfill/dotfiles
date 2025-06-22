-- ===== DART-VIM-PLUGIN CONFIGURATION =====
-- Dart言語基本サポートの設定
-- ========================================

-- ===== DART GLOBAL SETTINGS =====
-- Dart実行ファイルパス設定
vim.g.dart_html_in_string = true
vim.g.dart_corelib_highlight = false

-- Dartファイルタイプ設定
vim.g.dart_format_on_save = true
vim.g.dart_style_guide = 2  -- 2スペースインデント

-- ===== FILE TYPE SETTINGS =====
vim.api.nvim_create_augroup("DartSettings", { clear = true })

-- Dartファイル用の設定
vim.api.nvim_create_autocmd("FileType", {
	group = "DartSettings",
	pattern = "dart",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local opts = { buffer = bufnr, noremap = true, silent = true }
		
		-- ===== BUFFER SPECIFIC SETTINGS =====
		-- インデント設定
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		
		-- 自動インデント
		vim.bo.autoindent = true
		vim.bo.smartindent = true
		
		-- 行番号表示
		vim.wo.number = true
		vim.wo.relativenumber = true
		
		-- 折り畳み設定
		vim.wo.foldmethod = "syntax"
		vim.wo.foldlevel = 99
		
		-- テキスト幅
		vim.bo.textwidth = 80
		vim.wo.colorcolumn = "80"
		
		-- ===== DART SPECIFIC KEYMAPS =====
		-- ファイル実行
		vim.keymap.set('n', '<leader>Dr', function()
			local file = vim.fn.expand('%:p')
			vim.cmd('terminal dart run ' .. file)
		end, vim.tbl_extend('force', opts, { desc = "Run Dart file" }))
		
		-- Dart分析
		vim.keymap.set('n', '<leader>Da', function()
			vim.cmd('terminal dart analyze')
		end, vim.tbl_extend('force', opts, { desc = "Dart analyze" }))
		
		-- Dartフォーマット
		vim.keymap.set('n', '<leader>Df', function()
			local file = vim.fn.expand('%:p')
			vim.cmd('!dart format ' .. file)
			vim.cmd('edit!')  -- ファイルを再読み込み
		end, vim.tbl_extend('force', opts, { desc = "Format Dart file" }))
		
		-- Dartテスト実行
		vim.keymap.set('n', '<leader>Dt', function()
			vim.cmd('terminal dart test')
		end, vim.tbl_extend('force', opts, { desc = "Run Dart tests" }))
		
		-- Dart pub get
		vim.keymap.set('n', '<leader>Dp', function()
			vim.cmd('terminal dart pub get')
		end, vim.tbl_extend('force', opts, { desc = "Dart pub get" }))
		
		-- ===== DART SNIPPETS =====
		-- 基本的なDartスニペットを設定
		local function insert_dart_snippet(snippet)
			local pos = vim.api.nvim_win_get_cursor(0)
			vim.api.nvim_put({snippet}, 'l', true, true)
			vim.api.nvim_win_set_cursor(0, {pos[1] + 1, 0})
		end
		
		-- クラス作成
		vim.keymap.set('n', '<leader>Dc', function()
			local class_name = vim.fn.input("Class name: ")
			if class_name and class_name ~= "" then
				local snippet = string.format("class %s {\n  %s();\n}", class_name, class_name)
				insert_dart_snippet(snippet)
			end
		end, vim.tbl_extend('force', opts, { desc = "Create Dart class" }))
		
		-- メソッド作成
		vim.keymap.set('n', '<leader>Dm', function()
			local method_name = vim.fn.input("Method name: ")
			if method_name and method_name ~= "" then
				local snippet = string.format("void %s() {\n  // TODO: implement %s\n}", method_name, method_name)
				insert_dart_snippet(snippet)
			end
		end, vim.tbl_extend('force', opts, { desc = "Create Dart method" }))
	end,
})

-- ===== DART SYNTAX HIGHLIGHTING =====
-- 拡張構文ハイライト設定
vim.api.nvim_create_autocmd("Syntax", {
	group = "DartSettings", 
	pattern = "dart",
	callback = function()
		-- カスタムハイライトグループ
		vim.cmd([[
			highlight dartKeyword guifg=#569CD6 gui=bold
			highlight dartType guifg=#4EC9B0
			highlight dartString guifg=#CE9178
			highlight dartNumber guifg=#B5CEA8
			highlight dartComment guifg=#6A9955 gui=italic
			highlight dartAnnotation guifg=#DCDCAA
		]])
		
		-- 追加のマッチング
		vim.cmd([[
			syntax match dartAnnotation "@\w\+"
			syntax match dartPrivate "_\w\+"
			syntax keyword dartKeyword async await yield
			syntax keyword dartKeyword factory const final
		]])
	end,
})

-- ===== DART LINTING =====
-- Dart linterとの統合
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "DartSettings",
	pattern = "*.dart",
	callback = function()
		-- 保存時にDart analyze実行（非同期）
		vim.fn.jobstart({'dart', 'analyze', vim.fn.expand('%:p')}, {
			on_stdout = function(_, data)
				if data and #data > 1 then
					for _, line in ipairs(data) do
						if line and line ~= "" then
							vim.notify(line, vim.log.levels.WARN)
						end
					end
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 1 then
					for _, line in ipairs(data) do
						if line and line ~= "" then
							vim.notify(line, vim.log.levels.ERROR)
						end
					end
				end
			end,
		})
	end,
})

-- ===== DART UTILITY FUNCTIONS =====
-- Dartプロジェクト検出
local function is_dart_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

-- Dart SDK検出
local function get_dart_sdk()
	local dart_sdk = vim.fn.getenv("DART_SDK")
	if dart_sdk and dart_sdk ~= vim.NIL then
		return dart_sdk
	end
	
	-- dart コマンドから推測
	local dart_cmd = vim.fn.system("which dart"):gsub("\n", "")
	if dart_cmd and dart_cmd ~= "" then
		local dart_path = vim.fn.fnamemodify(dart_cmd, ":h:h")
		if vim.fn.isdirectory(dart_path) == 1 then
			return dart_path
		end
	end
	
	return nil
end

-- Dart バージョン表示
local function show_dart_version()
	local dart_version = vim.fn.system("dart --version 2>&1"):gsub("\n", "")
	vim.notify("Dart: " .. dart_version, vim.log.levels.INFO)
end

-- ===== GLOBAL FUNCTIONS =====
_G.is_dart_project = is_dart_project
_G.get_dart_sdk = get_dart_sdk
_G.show_dart_version = show_dart_version

-- ===== DART COMMANDS =====
-- カスタムコマンド定義
vim.api.nvim_create_user_command("DartVersion", show_dart_version, {
	desc = "Show Dart version",
})

vim.api.nvim_create_user_command("DartFormat", function()
	if vim.bo.filetype == "dart" then
		local file = vim.fn.expand('%:p')
		vim.cmd('!dart format ' .. file)
		vim.cmd('edit!')
	else
		vim.notify("Not a Dart file", vim.log.levels.WARN)
	end
end, {
	desc = "Format current Dart file",
})

vim.api.nvim_create_user_command("DartAnalyze", function()
	if is_dart_project() then
		vim.cmd('terminal dart analyze')
	else
		vim.notify("Not a Dart project", vim.log.levels.WARN)
	end
end, {
	desc = "Analyze Dart project",
})

-- ===== INTEGRATION =====
-- ステータスライン用のDart情報
function _G.get_dart_status()
	if vim.bo.filetype == "dart" then
		if is_dart_project() then
			return "🎯 Dart Project"
		else
			return "🎯 Dart"
		end
	end
	return ""
end