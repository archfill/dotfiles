-- vim.o.timeout = true
-- vim.o.timeoutlen = 300
require("which-key").setup({
	triggers = "auto",
	-- triggers = { "<leader>" },
})

vim.api.nvim_set_keymap("n", ",<CR>", "<Cmd>WhichKey ,<CR>", { noremap = true })
