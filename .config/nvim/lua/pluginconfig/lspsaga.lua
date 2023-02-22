local lspsaga = require("lspsaga")
lspsaga.setup({ -- defaults ...
	-- border_style = "single",
	-- saga_winblend = 0,
	-- move_in_saga = { prev = "<C-p>", next = "<C-n>" },
	-- diagnostic_header = { " ", " ", " ", "ﴞ" },
	-- max_preview_lines = 10,
	-- code_action_icon = " ",
	-- code_action_num_shortcut = true,
	-- code_action_lightbulb = {
	-- 	enable = true,
	-- 	sign = true,
	-- 	sign_priority = 20,
	-- 	virtual_text = true,
	-- },
	-- finder_icons = {
	-- 	def = "  ",
	-- 	ref = "諭 ",
	-- 	link = "  ",
	-- },
	-- finder_action_keys = {
	-- 	open = "o",
	-- 	vsplit = "s",
	-- 	split = "i",
	-- 	tabe = "t",
	-- 	quit = "q",
	-- 	scroll_down = "<C-f>",
	-- 	scroll_up = "<C-b>", -- quit can be a table
	-- },
	-- code_action = {
	-- 	num_shortcut = true,
	-- 	show_server_name = false,
	-- 	extend_gitsigns = true,
	-- 	keys = {
	-- 		-- string | table type
	-- 		quit = "q",
	-- 		exec = "<CR>",
	-- 	},
	-- },
	-- rename_action_quit = "<C-c>",
	-- ui = {
	-- 	code_action = "",
	-- 	diagnostic = "",
	-- },
	lightbulb = {
		virtual_text = false,
	},
	-- finder = {
	-- 	scroll_down = "<C-f>",
	-- 	scroll_up = "<C-b>", -- quit can be a table
	-- 	quit = { "q", "<ESC>" },
	-- },
	symbol_in_winbar = {
		-- in_custom = false,
		enable = false,
		-- separator = " ",
		show_file = false,
		-- click_support = false,
	},
	-- show_outline = {
	-- 	win_position = "right",
	-- 	--set special filetype win that outline window split.like NvimTree neotree
	-- 	-- defx, db_ui
	-- 	win_with = "",
	-- 	win_width = 30,
	-- 	auto_enter = true,
	-- 	auto_preview = true,
	-- 	virt_text = "┃",
	-- 	jump_key = "o",
	-- 	-- auto refresh when change buffer
	-- 	auto_refresh = true,
	-- },
	-- server_filetype_map = {},
})

--- In lsp attach function
-- local map = vim.api.nvim_buf_set_keymap
-- map(0, "n", "<space>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
-- map(0, "n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- map(0, "x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- map(0, "n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
-- map(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- map(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- map(0, "n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
-- map(0, "n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
vim.keymap.set("n", "<space>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
vim.keymap.set("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { silent = true, noremap = true })

-- vim.keymap.set("n", "[_Lsp]r", "<cmd>Lspsaga rename ++project<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "M", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("x", "M", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "?", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]j", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]k", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]f", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]s", "<Cmd>Lspsaga signature_help<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]d", "<cmd>Lspsaga preview_definition<CR>", { silent = true })
-- vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true, noremap = true })
-- -- vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
-- vim.keymap.set("n", "[_Lsp]l", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]c", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]b", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[E", function()
-- 	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", "]E", function()
-- 	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]I", "<cmd>Lspsaga incoming_calls<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[_Lsp]O", "<cmd>Lspsaga outgoing_calls<CR>", { silent = true, noremap = true })
