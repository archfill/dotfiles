-- if vim.fn.has('mac') == 1 then
  -- -- Mac の共通設定
  -- local fzfExists = vim.fn.getftype('/opt/homebrew/opt/fzf')
  -- if fzfExists ~= ''
    -- vim.o.rtp = vim.o.rtp .. '/opt/homebrew/opt/fzf'
  -- else
    -- vim.o.rtp = vim.o.rtp .. '/usr/local/opt/fzf'
  -- end
-- end

vim.o.sh = 'zsh'

---------------------------------------------------------------------------------------------------+
-- Commands \ Modes | Normal | Insert | Command | Visual | Select | Operator | Terminal | Lang-Arg |
-- ================================================================================================+
-- map  / noremap   |    @   |   -    |    -    |   @    |   @    |    @     |    -     |    -     |
-- nmap / nnoremap  |    @   |   -    |    -    |   -    |   -    |    -     |    -     |    -     |
-- map! / noremap!  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    -     |
-- imap / inoremap  |    -   |   @    |    -    |   -    |   -    |    -     |    -     |    -     |
-- cmap / cnoremap  |    -   |   -    |    @    |   -    |   -    |    -     |    -     |    -     |
-- vmap / vnoremap  |    -   |   -    |    -    |   @    |   @    |    -     |    -     |    -     |
-- xmap / xnoremap  |    -   |   -    |    -    |   @    |   -    |    -     |    -     |    -     |
-- smap / snoremap  |    -   |   -    |    -    |   -    |   @    |    -     |    -     |    -     |
-- omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    @     |    -     |    -     |
-- tmap / tnoremap  |    -   |   -    |    -    |   -    |   -    |    -     |    @     |    -     |
-- lmap / lnoremap  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    @     |
---------------------------------------------------------------------------------------------------+

vim.keymap.set('n', ';', ':', { noremap = true, silent = true })
vim.keymap.set('n', ':', ';', { noremap = true, silent = true })
vim.keymap.set('n', '<F3>', ':noh<CR>', { noremap = true, silent = true })
-- " 折り返し時に表示行単位での移動できるようにする
vim.keymap.set('n', 'j', 'gj', { noremap = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true, silent = true })
vim.keymap.set('n', 'jj', '<ESC>', { noremap = true, silent = true })
-- " ESC連打でハイライト解除
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { noremap = false, silent = true })

vim.o.printfont = 'HackGenNerd:h12'

-- setting
-- 文字コードをUFT-8に設定
vim.o.fenc = 'utf-8'
vim.o.encoding = 'utf-8'
vim.o.fileencodings = 'utf-8,sjis,iso-2022-jp,euc-jp'
vim.o.fileformats = 'unix,dos,mac'
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
-- " 現在の行を強調表示
vim.o.cursorline = true
-- " 行末の1文字先までカーソルを移動できるように
vim.o.virtualedit = 'onemore'
 -- インデントはスマートインデント
vim.o.smartindent = true
-- " ビープ音を可視化
vim.o.visualbell = true
-- " 括弧入力時の対応する括弧を表示
vim.o.showmatch = true
-- " ステータスラインを常に表示
vim.o.laststatus = 2
-- " コマンドラインの補完
vim.o.wildmode = 'list:longest'
vim.o.wildignore = vim.o.wildignore .. 'node_modules/**,.git/**'

-- " Tab系
 -- 不可視文字を可視化(タブが「▸-」と表示される)
vim.o.list = true
vim.o.listchars = 'tab:▸-'
-- " Tab文字を半角スペースにする
vim.o.expandtab = true
-- " 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.o.tabstop=2
-- " 行頭でのTab文字の表示幅
vim.o.shiftwidth=2


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

