-- ================================================================
-- CORE: Neovim Options Configuration  
-- ================================================================
-- Fundamental Neovim settings and platform-specific configurations

-- VSCode環境検出
vim.g.vscode_mode = vim.g.vscode or false

-- ================================================================
-- 廃止API互換性レイヤー (vim.tbl_flatten deprecation warning suppression)
-- ================================================================
-- vim.tbl_flattenの廃止警告を抑制（プラグイン互換性のため）
-- lualine.nvim等のプラグインが更新されるまでの一時的措置
vim.defer_fn(function()
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    -- vim.tbl_flattenの廃止警告を無効化
    if type(msg) == "string" and msg:match("vim%.tbl_flatten.*deprecated") then
      return
    end
    return original_notify(msg, level, opts)
  end
end, 0)

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