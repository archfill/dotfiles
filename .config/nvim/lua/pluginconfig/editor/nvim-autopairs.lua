-- nvim-autopairs設定
-- 高性能自動ペア補完

local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then
	return
end

npairs.setup({
	check_ts = true, -- treesitterと連携
	ts_config = {
		lua = { "string", "source" },
		javascript = { "string", "template_string" },
		java = false, -- Javaでは無効
	},
	disable_filetype = { "TelescopePrompt", "spectre_panel" },
	disable_in_macro = true, -- マクロ記録中は無効
	disable_in_visualblock = false,
	disable_in_replace_mode = true,
	ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
	enable_moveright = true,
	enable_afterquote = true,
	enable_check_bracket_line = true,
	enable_bracket_in_quote = true,
	enable_abbr = false, -- abbreviation無効（パフォーマンス）
	break_undo = true, -- undo履歴を分割
	check_comma = true,
	map_cr = true,
	map_bs = true, -- backspace mapping
	map_c_h = false, -- Ctrl+h mapping無効
	map_c_w = false, -- Ctrl+w mapping無効
})

-- nvim-cmpとの統合
local cmp_status_ok, cmp = pcall(require, "cmp")
if cmp_status_ok then
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

-- カスタムルール追加
local Rule = require("nvim-autopairs.rule")
local ts_conds = require("nvim-autopairs.ts-conds")

-- スペース付きペア
npairs.add_rules({
	Rule(" ", " ")
		:with_pair(function(opts)
			local pair = opts.line:sub(opts.col - 1, opts.col)
			return vim.tbl_contains({ "()", "[]", "{}" }, pair)
		end),
	Rule("( ", " )")
		:with_pair(function()
			return false
		end)
		:with_move(function(opts)
			return opts.prev_char:match(".%)") ~= nil
		end)
		:use_key(")"),
	Rule("{ ", " }")
		:with_pair(function()
			return false
		end)
		:with_move(function(opts)
			return opts.prev_char:match(".%}") ~= nil
		end)
		:use_key("}"),
	Rule("[ ", " ]")
		:with_pair(function()
			return false
		end)
		:with_move(function(opts)
			return opts.prev_char:match(".%]") ~= nil
		end)
		:use_key("]"),
})

-- 言語固有ルール
npairs.add_rules({
	-- Arrow function
	Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript", "javascriptreact" })
		:use_regex(true)
		:set_end_pair_length(2),
})

-- treesitter条件付きルール
npairs.add_rules({
	Rule("=", "")
		:with_pair(ts_conds.is_ts_node({ "assignment_expression", "variable_declaration" }))
		:with_pair(ts_conds.is_not_ts_node({ "arguments" })),
})