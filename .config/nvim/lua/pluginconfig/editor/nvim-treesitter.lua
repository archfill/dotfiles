-- nvim-treesitter設定
-- シンタックスハイライト、インクリメンタル選択、インデント機能

-- 安全なTree-sitter設定ロード
local has_treesitter, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not has_treesitter then
	vim.notify("Tree-sitter: プラグインがロードされていません。", vim.log.levels.WARN)
	return
end

local function ts_disable(_, bufnr)
	return vim.api.nvim_buf_line_count(bufnr) > 5000
end

-- Tree-sitter設定
treesitter_configs.setup({
	-- 基本的なパーサーを自動インストール
	ensure_installed = {
		"c", "lua", "vim", "vimdoc", "query", 
		"javascript", "typescript", "python", 
		"html", "css", "json", "yaml", "markdown"
	},
	
	-- 自動インストールを無効化
	auto_install = false,
	
	highlight = {
		enable = true,
		disable = function(lang, bufnr)
			-- 大きなファイルでは無効化
			if ts_disable(lang, bufnr) then
				return true
			end
			-- vim.vバージョンでもfallback
			if lang == "vim" and vim.version().minor < 10 then
				return true
			end
			return false
		end,
		additional_vim_regex_highlighting = { "vim" }, -- vim scriptのみregex併用
	},
	
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn", 
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	
	indent = { 
		enable = true,
		disable = { "python", "yaml" } -- 特定言語のみ無効化
	},
	
	-- Tree-sitter textobjects（一時的に無効化）
	-- textobjects = {
	-- 	select = {
	-- 		enable = true,
	-- 		lookahead = true,
	-- 		keymaps = {
	-- 			["af"] = "@function.outer",
	-- 			["if"] = "@function.inner",
	-- 			["ac"] = "@class.outer",
	-- 			["ic"] = "@class.inner",
	-- 		},
	-- 	},
	-- },
})

-- インストール済みパーサーの状態をログ出力
vim.defer_fn(function()
	local installed_parsers = require("nvim-treesitter.info").installed_parsers()
	vim.notify(
		string.format("Tree-sitter loaded with %d parsers", #installed_parsers),
		vim.log.levels.INFO
	)
end, 1000)