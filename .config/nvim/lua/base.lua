-- local os = require("os")

-- if vim.fn.has('mac') == 1 then
-- -- Mac の共通設定
-- local fzfExists = vim.fn.getftype('/opt/homebrew/opt/fzf')
-- if fzfExists ~= ''
-- vim.o.rtp = vim.o.rtp .. '/opt/homebrew/opt/fzf'
-- else
-- vim.o.rtp = vim.o.rtp .. '/usr/local/opt/fzf' end
-- end

-- volta config
if vim.fn.executable("volta") == 1 then
	-- vim.g.node_host_prog = os.getenv("HOME") .. "/.volta/tools/image/packages/neovim/lib/node_modules/neovim/bin/cli.js"
	-- vim.g.node_host_prog = os.getenv("HOME") .. "/.volta/bin/neovim-node-host"
	vim.g.node_host_prog = vim.call("system", 'volta which neovim-node-host | tr -d "\n"')
	-- vim.g.node_host_prog = vim.call("system", 'volta which node | tr -d "\n"')
end

vim.o.sh = "zsh"

-- vim.o.printfont = "HackGen Console NF:h14"
vim.o.guifont = "HackGen Console NF:h14"

-- setting
-- 文字コードをUFT-8に設定
vim.o.fenc = "utf-8"
vim.o.encoding = "utf-8"
vim.o.fileencodings = "utf-8,sjis,iso-2022-jp,euc-jp"
vim.o.fileformats = "unix,dos,mac"
-- " バックアップファイルを作らない
vim.o.backup = false
vim.o.writebackup = false
-- " スワップファイルを作らない
vim.o.swapfile = false
-- " 編集中のファイルが変更されたら自動で読み直す
vim.o.autoread = true
-- " バッファが編集中でもその他のファイルを開けるように
vim.o.hidden = true
-- " 入力中のコマンドをステータスに表示する
vim.o.showcmd = true

-- " 見た目系
-- " 行番号を表示
vim.o.number = true
vim.o.relativenumber = true
-- " 現在の行を強調表示
vim.o.cursorline = false
-- " 行末の1文字先までカーソルを移動できるように
vim.o.virtualedit = "onemore"
-- インデントはスマートインデント
vim.o.smartindent = true
-- " ビープ音を可視化
vim.o.visualbell = true
-- " 括弧入力時の対応する括弧を表示
vim.o.showmatch = true
-- " ステータスラインを常に表示
-- vim.o.laststatus = 2
-- " コマンドラインの補完
vim.o.wildmode = "list:longest"
vim.o.wildignore = vim.o.wildignore .. "node_modules/**,.git/**"

vim.o.display = "lastline" -- 長い行は 1 行に収まります
vim.o.showmode = false
vim.o.matchtime = 1 -- 括弧のペアを見つけるまでのミリ秒数
vim.o.wrap = true -- 画面幅で折り返す
-- vim.o.title = false -- タイトルを書き換えません
-- vim.o.scrolloff = 5
-- vim.o.sidescrolloff = 5
-- vim.o.pumheight = 10 -- 表示する補完候補の数
vim.o.statuscolumn = "%=%{&nu ? v:relnum ? v:relnum : v:lnum : ''} %s%C"
vim.o.signcolumn = "yes"

-- " Tab系
-- 不可視文字を可視化(タブが「▸-」と表示される)
vim.o.list = true
vim.o.listchars = "tab:▸-"
-- " Tab文字を半角スペースにする
vim.o.expandtab = true
-- " 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.o.tabstop = 2
-- " 行頭でのTab文字の表示幅
vim.o.shiftwidth = 2

-- " 検索系
-- " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.o.shiftwidth = 2
-- " 検索文字列に大文字が含まれている場合は区別して検索する
vim.o.smartcase = true
-- " 検索文字列入力時に順次対象文字列にヒットさせる
vim.o.incsearch = true
-- " 検索時に最後まで行ったら最初に戻る
vim.o.wrapscan = true
-- " 検索語をハイライト表示
vim.o.hlsearch = true

vim.opt.clipboard:append({ "unnamedplus" })

if vim.fn.has("wsl") then
	require("wsl-config")
end
