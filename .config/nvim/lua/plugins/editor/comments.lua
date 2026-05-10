-- ================================================================
-- EDITOR: Comments - Priority 300
-- ================================================================

return {
	{
		"numToStr/Comment.nvim",
		priority = 300,
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = {
			padding = true,
			sticky = true,
			ignore = "^$",
			toggler = {
				line = "gcc",
				block = "gbc",
			},
			opleader = {
				line = "gc",
				block = "gb",
			},
			extra = {
				above = "gcO",
				below = "gco",
				eol = "gcA",
			},
			mappings = {
				basic = true,
				extra = true,
			},
		},
		config = function(_, opts)
			local pre_hook_ok, ts_pre_comment = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
			if pre_hook_ok and ts_pre_comment then
				opts.pre_hook = ts_pre_comment.create_pre_hook()
			end
			require("Comment").setup(opts)
		end,
	},
}
