-- which-key.nvim設定
-- リーダーキーとキーマップの視覚化

local which_key = require("which-key")

-- 基本設定
which_key.setup({
	window = {
		border = "rounded",
		position = "bottom",
	},
})

-- キーマップ登録
which_key.add({
	{ "<leader>f", group = "Files" },
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	
	{ "<leader>g", group = "Git" },
	{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
	{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
	
	{ "<leader>e", "<cmd>Neotree position=float reveal toggle<cr>", desc = "Toggle Explorer" },
	{ "<leader>q", "<cmd>nohlsearch<cr>", desc = "No Highlight" },
	
	{ "<leader>n", group = "Noice" },
	{ "<leader>nm", "<cmd>Noice<cr>", desc = "Messages" },
	{ "<leader>nl", "<cmd>Noice last<cr>", desc = "Last Message" },
	{ "<leader>ne", "<cmd>Noice errors<cr>", desc = "Errors" },
	{ "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss" },

	{ "<leader>b", group = "Buffers" },
	{ "<leader>bd", desc = "Delete Buffer" },
	{ "<leader>bo", desc = "Delete Other Buffers" },
	{ "<leader>1", desc = "Go to Buffer 1" },
	{ "<leader>2", desc = "Go to Buffer 2" },
	{ "<leader>3", desc = "Go to Buffer 3" },
	{ "<leader>4", desc = "Go to Buffer 4" },
	{ "<leader>5", desc = "Go to Buffer 5" },
	{ "<leader>6", desc = "Go to Buffer 6" },
	{ "<leader>7", desc = "Go to Buffer 7" },
	{ "<leader>8", desc = "Go to Buffer 8" },
	{ "<leader>9", desc = "Go to Buffer 9" },

	{ "H", desc = "Previous Buffer" },
	{ "L", desc = "Next Buffer" },
	{ "x", desc = "Delete Buffer" },
})

vim.notify("⌨️ Which-key ready! Press <leader> to see mappings", vim.log.levels.INFO)