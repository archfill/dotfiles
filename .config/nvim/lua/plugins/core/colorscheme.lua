-- ================================================================
-- CORE: Colorschemes - Priority 1000 (Highest)
-- ================================================================

return {
	-- 🎨 Catppuccin: 2025年最トレンドの美しいカラースキーム
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = false, -- 美しいグラデーション維持
			show_end_of_buffer = false,
			term_colors = true,
			dim_inactive = {
				enabled = true, -- 非アクティブウィンドウを暗く
				shade = "dark",
				percentage = 0.15,
			},
			no_italic = false, -- 美しいイタリック維持
			no_bold = false,
			no_underline = false,
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = {},
				functions = { "bold" },
				keywords = { "bold" },
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = { "bold" },
				operators = {},
			},
			color_overrides = {},
			custom_highlights = function(colors)
				return {
					-- カスタムハイライト for 最高の見た目
					Comment = { fg = colors.overlay1, style = { "italic" } },
					LineNr = { fg = colors.overlay0 },
					CursorLineNr = { fg = colors.blue, style = { "bold" } },
					-- Neo-tree美化
					NeoTreeDirectoryIcon = { fg = colors.blue },
					NeoTreeDirectoryName = { fg = colors.text },
					NeoTreeFloatBorder = { fg = colors.blue, bg = colors.mantle },
					-- Telescope美化
					TelescopeBorder = { fg = colors.blue, bg = colors.mantle },
					TelescopePromptBorder = { fg = colors.pink, bg = colors.mantle },
					-- Dashboard美化
					AlphaHeader = { fg = colors.blue },
					AlphaButtons = { fg = colors.text },
					AlphaShortcut = { fg = colors.pink },
					AlphaFooter = { fg = colors.overlay1, style = { "italic" } },
				}
			end,
			integrations = {
				-- 全主要プラグインとの美しい統合
				cmp = true,
				gitsigns = true,
				nvimtree = false, -- neo-tree使用のため
				neotree = true,
				treesitter = true,
				notify = false, -- snacks.notifier使用のため
				mini = {
					enabled = true,
					indentscope_color = "lavender",
				},
				telescope = {
					enabled = true,
					style = "nvchad", -- 最も美しいスタイル
				},
				lsp_trouble = true,
				which_key = true,
				barbecue = {
					dim_dirname = true,
					bold_basename = true,
					dim_context = false,
					alt_background = false,
				},
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
				mason = true,
				noice = true,
				semantic_tokens = true,
				treesitter_context = true,
				rainbow_delimiters = true,
				-- snacks.nvim統合
				snacks = true,
				indent_blankline = {
					enabled = false, -- snacks.indent使用のため
				},
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)

			-- Terminal Colors
			vim.opt.termguicolors = true

			-- 美しいCatppuccin適用
			vim.cmd.colorscheme("catppuccin")

			-- 追加の美化設定
			vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89b4fa", bg = "#1e1e2e" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e" })
			vim.api.nvim_set_hl(0, "Pmenu", { bg = "#1e1e2e" })
			vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#313244", fg = "#cdd6f4" })

			-- Cursor形状の美化
			vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor"
		end,
	},
}

