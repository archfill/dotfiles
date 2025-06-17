-- Comment.nvim設定
-- 高速コメント切り替え

local status_ok, comment = pcall(require, "Comment")
if not status_ok then
	return
end

comment.setup({
	-- パディング設定
	padding = true,
	-- ポジション設定（左端に配置）
	sticky = true,
	-- 無視するパターン
	ignore = "^$",
	-- LHS（左辺）マッピング
	toggler = {
		line = "gcc", -- 行コメント切り替え
		block = "gbc", -- ブロックコメント切り替え
	},
	-- LHS（左辺）オペレーターペンディングマッピング
	opleader = {
		line = "gc", -- 行コメント
		block = "gb", -- ブロックコメント
	},
	-- LHS（左辺）エクストラマッピング
	extra = {
		above = "gcO", -- カーソル上にコメント追加
		below = "gco", -- カーソル下にコメント追加
		eol = "gcA", -- 行末にコメント追加
	},
	-- マッピング有効化
	mappings = {
		basic = true, -- 基本マッピング（gcc, gbc, gc[count]{motion}）
		extra = true, -- エクストラマッピング（gco, gcO, gcA）
	},
	-- treesitter統合のための前処理（一時無効化）
	-- pre_hook = function(ctx)
	-- 	-- treesitter-context-commentstring統合
	-- 	local ts_utils_ok, ts_utils = pcall(require, "ts_context_commentstring.utils")
	-- 	if ts_utils_ok then
	-- 		return ts_utils.calculate_commentstring({
	-- 			key = ctx.ctype == require("Comment.utils").ctype.linewise and "__default" or "__multiline",
	-- 			location = ts_utils.get_cursor_location(),
	-- 		})
	-- 	end
	-- end,
	-- 後処理（オプション）
	post_hook = nil,
})

-- Visualモードでのマッピング強化
local api = require("Comment.api")
vim.keymap.set("x", "gc", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	api.toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment linewise (visual)" })

vim.keymap.set("x", "gb", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	api.toggle.blockwise(vim.fn.visualmode())
end, { desc = "Toggle comment blockwise (visual)" })

-- フォーカス時の自動設定（パフォーマンス向上）
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		-- 大きなファイルではコメント機能を制限
		local lines = vim.api.nvim_buf_line_count(0)
		if lines > 5000 then
			-- 大きなファイルでは基本機能のみ有効
			vim.b.comment_config = { ignore = "^%s*$" }
		end
	end,
})