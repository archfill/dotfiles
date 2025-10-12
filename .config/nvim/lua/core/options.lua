-- ================================================================
-- CORE: Neovim Options Configuration
-- ================================================================
-- Fundamental Neovim settings and platform-specific configurations

-- VSCode環境検出
vim.g.vscode_mode = vim.g.vscode or false

-- ================================================================
-- エラー・警告ログキャプチャ（デバッグ用）
-- ================================================================
-- 全ての通知をファイルに記録（:EditErrorLog で確認可能）
local error_log_file = vim.fn.stdpath("state") .. "/error-log.txt"
local original_notify = vim.notify

vim.notify = function(msg, level, opts)
	-- ファイルサイズチェック（1MB制限）
	local stat = vim.loop.fs_stat(error_log_file)
	if stat and stat.size > 1024 * 1024 then
		-- 古いログをバックアップして新規作成
		os.rename(error_log_file, error_log_file .. ".old")
	end

	-- ファイルに記録
	local log_entry = string.format(
		"[%s] [%s] %s\n",
		os.date("%Y-%m-%d %H:%M:%S"),
		level == vim.log.levels.ERROR and "ERROR"
			or level == vim.log.levels.WARN and "WARN"
			or level == vim.log.levels.INFO and "INFO"
			or "DEBUG",
		msg
	)

	local file = io.open(error_log_file, "a")
	if file then
		file:write(log_entry)
		file:close()
	end

	-- 元の通知を実行
	return original_notify(msg, level, opts)
end

-- エラーログを開くコマンド
vim.api.nvim_create_user_command("EditErrorLog", function()
	vim.cmd("edit " .. error_log_file)
end, { desc = "Open error log file" })

-- Shell設定
vim.o.sh = "zsh"

-- フォント設定
vim.o.guifont = "HackGen Console NF:h14"

-- ================================================================
-- 基本設定
-- ================================================================

-- 文字コードをUFT-8に設定
vim.o.fenc = "utf-8"
vim.o.encoding = "utf-8"
vim.o.fileencodings = "utf-8,sjis,iso-2022-jp,euc-jp"
vim.o.fileformats = "unix,dos,mac"

-- ファイル管理
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.autoread = true
vim.o.hidden = true

-- コマンド表示
vim.o.showcmd = true

-- ================================================================
-- 表示設定
-- ================================================================

-- 行番号表示
vim.o.number = true
vim.o.relativenumber = true

-- カーソル設定
vim.o.cursorline = false
vim.o.virtualedit = "onemore"

-- インデント設定
vim.o.smartindent = true

-- 表示改善
vim.o.visualbell = true
vim.o.showmatch = true
vim.o.wildmode = "list:longest"
vim.o.wildignore = vim.o.wildignore .. "node_modules/**,.git/**"
vim.o.display = "lastline"
vim.o.showmode = false
vim.o.matchtime = 1
vim.o.wrap = true

-- ステータス設定
vim.o.statuscolumn = "%=%{&nu ? v:relnum ? v:relnum : v:lnum : ''} %s%C"
vim.o.signcolumn = "yes"

-- ================================================================
-- Tab・インデント設定
-- ================================================================

-- 不可視文字表示
vim.o.list = true
vim.o.listchars = "tab:▸-"

-- Tab設定
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- ================================================================
-- 検索設定
-- ================================================================

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.wrapscan = true
vim.o.hlsearch = true

-- ================================================================
-- システム設定
-- ================================================================

-- クリップボード設定
vim.opt.clipboard:append({ "unnamedplus" })

-- ファイルタイプ検出
vim.cmd("filetype plugin indent on")

-- ================================================================
-- Node.js設定（遅延実行）
-- ================================================================
vim.defer_fn(function()
	if vim.fn.executable("volta") == 1 then
		vim.g.node_host_prog = vim.call("system", 'volta which neovim-node-host | tr -d "\n"')
	end
end, 100)

-- ================================================================
-- プラットフォーム固有設定
-- ================================================================
if vim.fn.has("wsl") == 1 then
	require("core.platform")
end

