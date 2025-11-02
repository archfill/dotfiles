-- ================================================================
-- EDITOR: Treesitter - Priority 500
-- ================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		priority = 500,
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			-- 安全なTree-sitter設定ロード
			local has_treesitter, treesitter_configs = pcall(require, "nvim-treesitter.configs")
			if not has_treesitter then
				vim.notify("Tree-sitter: プラグインがロードされていません。", vim.log.levels.WARN)
				return
			end

			local function ts_disable(_, bufnr)
				-- nvim-treesitterのバグ対策: bufnrがnilの場合がある
				if not bufnr then
					bufnr = 0 -- カレントバッファを使用
				end

				-- ファイルサイズベースの早期チェック（500KB以上で無効化）
				local filename = vim.api.nvim_buf_get_name(bufnr)
				if filename ~= "" then
					local ok, stats = pcall(vim.loop.fs_stat, filename)
					if ok and stats and stats.size > 500000 then
						return true
					end
				end

				-- 行数ベースのチェック（5000行以上で無効化）
				local lines = vim.api.nvim_buf_line_count(bufnr)
				return lines > 5000
			end

			-- Tree-sitter設定
			treesitter_configs.setup({
				-- 主要言語パーサーを自動インストール
				ensure_installed = {
					-- 基本・必須
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",

					-- Web開発
					"javascript",
					"typescript",
					"html",
					"css",
					"json",
					"yaml",

					-- システム・アプリ開発
					"python",
					"rust",
					"go",
					"cpp",
					"java",

					-- スクリプト・設定
					"bash",
					"markdown",
					"dockerfile",
					"toml",

					-- Flutter/Dart（既存）
					"dart",

					-- Tier1言語追加
					"php",
					"ruby",
					"sql",
					"hcl",
					"kotlin",
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
					disable = { "python", "yaml" }, -- 特定言語のみ無効化
				},
			})

			-- 大規模ファイルでTreeSitterを自動停止
			-- 複数のイベントで確実にチェック
			local ts_group = vim.api.nvim_create_augroup("TreeSitterAutoDisable", { clear = true })

			local function check_and_disable_ts(bufnr)
				bufnr = bufnr or vim.api.nvim_get_current_buf()

				-- バッファの有効性チェック
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				-- ファイルサイズチェック
				local filename = vim.api.nvim_buf_get_name(bufnr)
				if filename ~= "" then
					local ok, stats = pcall(vim.loop.fs_stat, filename)
					if ok and stats and stats.size > 500000 then
						vim.treesitter.stop(bufnr)
						vim.notify(
							string.format(
								"TreeSitter: Disabled for large file (%s, %.1fMB)",
								vim.fn.fnamemodify(filename, ":t"),
								stats.size / 1024 / 1024
							),
							vim.log.levels.INFO
						)
						return
					end
				end

				-- 行数チェック
				local lines = vim.api.nvim_buf_line_count(bufnr)
				if lines > 5000 then
					vim.treesitter.stop(bufnr)
					vim.notify(
						string.format("TreeSitter: Disabled for large file (%d lines)", lines),
						vim.log.levels.INFO
					)
				end
			end

			-- ファイル読み込み時にチェック
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
				group = ts_group,
				callback = function(args)
					-- 遅延実行で確実にTreeSitterが起動した後にチェック
					vim.defer_fn(function()
						check_and_disable_ts(args.buf)
					end, 100)
				end,
			})
		end,
	},
}
