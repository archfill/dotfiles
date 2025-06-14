local lspsaga = require("lspsaga")
lspsaga.setup({
	ui = {
		code_action = "󰌵",
	},
	lightbulb = {
		virtual_text = false,
	},
	finder = {
		scroll_down = "<C-j>",
		scroll_up = "<C-k>",
		quit = { "q", "<ESC>" },
	},
	symbol_in_winbar = {
		enable = false,
		show_file = false,
	},
})

--- In lsp attach function
-- local map = vim.api.nvim_buf_set_keymap
-- map(0, "n", "<leader>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
-- map(0, "n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- map(0, "x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- map(0, "n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
-- map(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- map(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- map(0, "n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
-- map(0, "n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
vim.keymap.set("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { silent = true, noremap = true })

-- vim.keymap.set("n", LK_LSP.."r", "<cmd>Lspsaga rename ++project<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "M", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("x", "M", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "?", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."j", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."k", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."f", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."s", "<Cmd>Lspsaga signature_help<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."d", "<cmd>Lspsaga preview_definition<CR>", { silent = true })
-- vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true, noremap = true })
-- -- vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
-- vim.keymap.set("n", LK_LSP.."l", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."c", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."b", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[E", function()
-- 	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", "]E", function()
-- 	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."I", "<cmd>Lspsaga incoming_calls<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."O", "<cmd>Lspsaga outgoing_calls<CR>", { silent = true, noremap = true })
