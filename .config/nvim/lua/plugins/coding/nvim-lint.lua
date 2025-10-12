-- ================================================================
-- CODING: Nvim Lint
-- ================================================================

return {
	-- nvim-lint: 軽量リンティング
	{
		"mfussenegger/nvim-lint",
		keys = {
			{
				"<leader>l",
				function()
					require("lint").try_lint()
				end,
				desc = "Trigger linting",
			},
		},
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				python = { "ruff" },
				javascript = { "eslint_d" }, -- eslint_dの方が高速
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				lua = { "luacheck" },
				sh = { "shellcheck" },
				dockerfile = { "hadolint" },
			}

			-- Auto-lint on events
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}

