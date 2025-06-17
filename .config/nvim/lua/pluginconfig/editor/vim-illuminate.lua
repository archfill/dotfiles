-- vim-illuminate設定
-- スマートなカーソルワードハイライト

local status_ok, illuminate = pcall(require, "illuminate")
if not status_ok then
	return
end

illuminate.configure({
	-- プロバイダー優先順位（LSP > treesitter > regex）
	providers = {
		"lsp",
		"treesitter",
		"regex",
	},
	-- 遅延時間（ms）
	delay = 100,
	-- ファイルタイプ別設定
	filetypes_denylist = {
		"dirvish",
		"fugitive",
		"alpha",
		"NvimTree",
		"neo-tree",
		"lazy",
		"neogitstatus",
		"Trouble",
		"lir",
		"Outline",
		"spectre_panel",
		"toggleterm",
		"DressingSelect",
		"TelescopePrompt",
	},
	-- バッファタイプ別設定
	filetypes_allowlist = {},
	-- モード別設定
	modes_denylist = {},
	modes_allowlist = {},
	-- プロバイダー別設定
	providers_regex_syntax_denylist = {},
	providers_regex_syntax_allowlist = {},
	-- 大きなファイルの設定
	under_cursor = true,
	large_file_cutoff = 2000, -- 大きなファイルでのカットオフ
	large_file_overrides = {
		providers = { "lsp" }, -- 大きなファイルではLSPのみ使用
	},
	-- 最小一致長
	min_count_to_highlight = 1,
	-- 大文字小文字を区別するか
	case_insensitive_regex = false,
})

-- キーマップ設定
vim.keymap.set("n", "<a-n>", function()
	require("illuminate").goto_next_reference(false)
end, { desc = "Move to next reference" })

vim.keymap.set("n", "<a-p>", function()
	require("illuminate").goto_prev_reference(false)
end, { desc = "Move to previous reference" })

-- ハイライトグループのカスタマイズ
vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })