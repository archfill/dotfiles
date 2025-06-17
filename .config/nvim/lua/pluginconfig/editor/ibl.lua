-- ibl.nvim設定
-- 美しいインデント表示（indent-blankline.nvim後継）

local status_ok, ibl = pcall(require, "ibl")
if not status_ok then
	return
end

-- カスタムハイライトグループ設定
local hooks = require("ibl.hooks")
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b4048" })
	vim.api.nvim_set_hl(0, "IblScope", { fg = "#61afef" })
	vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#2c313c" })
end)

ibl.setup({
	indent = {
		char = "▎", -- 美しいインデント文字
		smart_indent_cap = true,
		priority = 2,
	},
	whitespace = {
		highlight = { "IblWhitespace" },
		remove_blankline_trail = true,
	},
	scope = {
		enabled = true,
		show_start = true,
		show_end = true,
		show_exact_scope = true,
		injected_languages = true,
		highlight = { "IblScope" },
		priority = 1024,
	},
	exclude = {
		filetypes = {
			"help",
			"alpha",
			"dashboard",
			"neo-tree",
			"Trouble",
			"trouble",
			"lazy",
			"mason",
			"notify",
			"toggleterm",
			"lazyterm",
		},
		buftypes = {
			"terminal",
			"nofile",
			"quickfix",
			"prompt",
		},
	},
})

-- パフォーマンス最適化のための設定
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)