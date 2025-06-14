-- ===== NIGHTLY VERSION EXPERIMENTAL PLUGINS =====
-- Nightly版専用の実験的プラグイン設定
-- 最新機能のテストと評価用
-- ===================================================

local nightly_plugins = {
	-- ===== 実験的プラグイン =====
	{
		-- AI コード補完（実験的）
		"supermaven-inc/supermaven-nvim",
		event = "VeryLazy",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = {}, 
				color = {
					suggestion_color = "#ffffff",
					cterm = 244,
				},
				log_level = "info",
				disable_inline_completion = false,
				disable_keymaps = false
			})
		end,
	},
	{
		-- バッファ内検索の強化（実験的）
		"kevinhwang91/nvim-hlslens",
		event = "VeryLazy",
		config = function()
			require('hlslens').setup()
		end,
	},
	{
		-- ファイル内関数・変数ジャンプの強化
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
			
			vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
			vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
			vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end)
			vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end)
			vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end)
			vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end)
		end,
	},
}

return nightly_plugins