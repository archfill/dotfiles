-- ================================================================
-- CORE: Neovim Options Configuration
-- ================================================================
-- Fundamental Neovim settings and platform-specific configurations

-- VSCode環境検出
vim.g.vscode_mode = vim.g.vscode or false

-- Shell設定
vim.o.sh = "zsh"

-- フォント設定
vim.o.guifont = "Moralerspace Argon:h14"

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
vim.o.relativenumber = false -- デフォルト無効（大規模ファイル対応）

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

-- パフォーマンス最適化
vim.o.updatetime = 250 -- デフォルト4000ms → 250ms（LSP診断の反応速度向上）

-- ================================================================
-- Node.js設定（遅延実行）
-- ================================================================
vim.defer_fn(function()
	-- mise経由でneovim-node-hostを検索
	if vim.fn.executable("mise") == 1 then
		local node_host = vim.fn.system('mise which neovim-node-host 2>/dev/null | tr -d "\n"')
		if node_host ~= "" and vim.fn.filereadable(node_host) == 1 then
			vim.g.node_host_prog = node_host
		end
	end
end, 100)

-- ================================================================
-- プラットフォーム固有設定
-- ================================================================
if vim.fn.has("wsl") == 1 then
	require("core.platform")
end

