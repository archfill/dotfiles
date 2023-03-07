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

-- leader key
-- vim.keymap.set("n", "<Space>", "", {})
-- vim.g.mapleader = " "

-- コマンドモード関連
-- HHKB用
-- vim.keymap.set('n', ';', ':', { noremap = true, silent = false })
-- vim.keymap.set('n', ':', ';', { noremap = true, silent = false })
-- cocot36plus(30% keyborad)
vim.keymap.set("n", "-", ":", { noremap = true, silent = false })
vim.keymap.set("n", ":", "-", { noremap = true, silent = false })
-- vim.keymap.set('n', '<F3>', ':noh<CR>', { noremap = true, silent = true })
-- " 折り返し時に表示行単位での移動できるようにする
vim.keymap.set("n", "j", "gj", { noremap = true, silent = false })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = false })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = false })
-- " ESC連打でハイライト解除
vim.keymap.set("n", "<leader>q", ":nohlsearch<CR><Esc>", { noremap = false, silent = true })
