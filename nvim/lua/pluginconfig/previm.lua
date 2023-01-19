-- nnoremap [previm] <Nop>
-- nmap <Space>p [previm]
-- nnoremap <silent> [previm]o :<C-u>PrevimOpen<CR>
-- nnoremap <silent> [previm]r :call previm#refresh()<CR>

vim.g.previm_open_cmd = ""
vim.keymap.set({ "n" }, "<Space>po", "<Cmd>PrevimOpen<CR>", { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Space>pr", "<Cmd>call previm#refresh()<CR>", { noremap = true, silent = true })
