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

-- ================================================================
-- LEADER KEY CONFIGURATION
-- ================================================================
vim.g.mapleader = " "

-- Custom leader keys for legacy compatibility
LK_LSP = ","
LK_COMMENT = ","

-- ================================================================
-- BASIC EDITOR OPERATIONS
-- ================================================================

-- Command mode keymaps
-- HHKB用
-- vim.keymap.set('n', ';', ':', { noremap = true, silent = false })
-- vim.keymap.set('n', ':', ';', { noremap = true, silent = false })
-- cocot36plus(30% keyborad)
vim.keymap.set("n", "-", ":", { noremap = true, silent = false, desc = "Enter command mode" })
vim.keymap.set("n", ":", "-", { noremap = true, silent = false, desc = "Reverse mapping" })

-- Movement improvements
-- 折り返し時に表示行単位での移動できるようにする
vim.keymap.set("n", "j", "gj", { noremap = true, silent = false, desc = "Move down by display line" })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = false, desc = "Move up by display line" })

-- Insert mode escape
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = false, desc = "Exit insert mode" })

-- Search and highlight management
-- ESC連打でハイライト解除 (競合解決: qからhに変更)
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR><Esc>", { noremap = false, silent = true, desc = "Clear search highlight" })