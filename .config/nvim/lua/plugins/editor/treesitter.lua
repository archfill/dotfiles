-- ================================================================
-- EDITOR: Treesitter
-- ================================================================

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- main ブランチは遅延読み込み非対応
		build = ":TSUpdate",
		config = function()
			local uv = vim.uv or vim.loop

			-- 主要言語パーサーを自動インストール（非同期・インストール済みなら no-op）
			require("nvim-treesitter").install({
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
			})

			-- 大きなファイルかどうか判定する。該当時は (true, 説明文字列) を返す
			local function ts_disable(bufnr)
				-- ファイルサイズベースの早期チェック（500KB以上で無効化）
				local filename = vim.api.nvim_buf_get_name(bufnr)
				if filename ~= "" then
					local ok, stats = pcall(uv.fs_stat, filename)
					if ok and stats and stats.size > 500000 then
						return true,
							string.format(
								"%s, %.1fMB",
								vim.fn.fnamemodify(filename, ":t"),
								stats.size / 1024 / 1024
							)
					end
				end

				-- 行数ベースのチェック（5000行以上で無効化）
				local lines = vim.api.nvim_buf_line_count(bufnr)
				if lines > 5000 then
					return true, string.format("%d lines", lines)
				end
				return false
			end

			-- FileType ごとにハイライト・インデントを有効化
			local ts_group = vim.api.nvim_create_augroup("TreeSitterSetup", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = ts_group,
				callback = function(args)
					local buf = args.buf
					local ft = args.match

					-- 大規模ファイルでは起動しない
					local disabled, reason = ts_disable(buf)
					if disabled then
						vim.b[buf].treesitter_auto_disabled = true
						vim.notify(string.format("TreeSitter: Disabled for large file (%s)", reason), vim.log.levels.INFO)
						return
					end

					-- パーサーが無ければ何もしない
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang then
						return
					end
					local ok = pcall(vim.treesitter.start, buf, lang)
					if not ok then
						return
					end

					-- インデント（python / yaml は無効化）
					if ft ~= "python" and ft ~= "yaml" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end

					-- vim script のみ regex ハイライト併用
					if ft == "vim" then
						vim.bo[buf].syntax = "ON"
					end
				end,
			})

			-- 選択範囲の拡大縮小は Neovim 0.12 標準の visual mode an / in / ]n / [n を使う
		end,
	},
}
