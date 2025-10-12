-- ================================================================
-- UTIL: Smart Splits - Neovim/Tmux Navigation & Resizing
-- ================================================================

return {
	{
		"mrjones2014/smart-splits.nvim",
		-- tmux統合のため遅延ロードしない（@pane-is-vim変数設定が必要）
		lazy = false,
		priority = 900,
		config = function()
			-- 手動セットアップでエラー回避
			require("smart-splits").setup({
				ignored_filetypes = {
					"nofile",
					"quickfix",
					"qf",
					"prompt",
				},
			})
		end,
		keys = {
			-- ===== ナビゲーション (Ctrl+h/j/k/l) - Normalモードのみ =====
			-- insertモードではSKK/補完を優先
			{
				"<C-h>",
				function()
					require("smart-splits").move_cursor_left()
				end,
				mode = "n",
				desc = "Move to left split",
			},
			{
				"<C-j>",
				function()
					require("smart-splits").move_cursor_down()
				end,
				mode = "n",
				desc = "Move to below split",
			},
			{
				"<C-k>",
				function()
					require("smart-splits").move_cursor_up()
				end,
				mode = "n",
				desc = "Move to above split",
			},
			{
				"<C-l>",
				function()
					require("smart-splits").move_cursor_right()
				end,
				mode = "n",
				desc = "Move to right split",
			},

			-- ===== リサイズ (Alt+h/j/k/l) =====
			{
				"<A-h>",
				function()
					require("smart-splits").resize_left()
				end,
				desc = "Resize split left",
			},
			{
				"<A-j>",
				function()
					require("smart-splits").resize_down()
				end,
				desc = "Resize split down",
			},
			{
				"<A-k>",
				function()
					require("smart-splits").resize_up()
				end,
				desc = "Resize split up",
			},
			{
				"<A-l>",
				function()
					require("smart-splits").resize_right()
				end,
				desc = "Resize split right",
			},

			-- ===== バッファスワップ (Leader+h/j/k/l) =====
			{
				"<leader>wh",
				function()
					require("smart-splits").swap_buf_left()
				end,
				desc = "Swap buffer left",
			},
			{
				"<leader>wj",
				function()
					require("smart-splits").swap_buf_down()
				end,
				desc = "Swap buffer down",
			},
			{
				"<leader>wk",
				function()
					require("smart-splits").swap_buf_up()
				end,
				desc = "Swap buffer up",
			},
			{
				"<leader>wl",
				function()
					require("smart-splits").swap_buf_right()
				end,
				desc = "Swap buffer right",
			},
		},
	},
}
