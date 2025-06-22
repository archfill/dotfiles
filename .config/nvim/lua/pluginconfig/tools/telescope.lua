-- ===== TELESCOPE COMPREHENSIVE CONFIGURATION =====
-- 高度なカスタマイズ・拡張・パフォーマンス最適化
-- =====================================================

local telescope = require("telescope")
local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local utils = require("telescope.utils")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local Path = require("plenary.path")

-- ===== EXTENSION LOADING SYSTEM =====
-- 安全な拡張機能読み込みシステム
local function safe_load_extension(extension_name)
	local ok, _ = pcall(telescope.load_extension, extension_name)
	if not ok then
		-- 警告レベル以下の通知は表示しない（静寂モード）
		-- vim.notify("Telescope extension '" .. extension_name .. "' not available", vim.log.levels.WARN)
	end
	-- 成功時の通知も無効化（静寂モード）
	-- vim.notify("Loaded telescope extension: " .. extension_name, vim.log.levels.INFO)
	return ok
end

-- 必須拡張機能の読み込み
local extensions_loaded = {
	-- Core extensions
	fzf = safe_load_extension("fzf"),
	file_browser = safe_load_extension("file_browser"),
	ui_select = safe_load_extension("ui-select"),
	symbols = safe_load_extension("symbols"),
	project = safe_load_extension("project"),
	recent_files = safe_load_extension("recent_files"),
	undo = safe_load_extension("undo"),
	heading = safe_load_extension("heading"),
	flutter = safe_load_extension("flutter"),
	
	-- High priority additions
	frecency = safe_load_extension("frecency"),
	yanky = safe_load_extension("yanky"),
	media_files = safe_load_extension("media_files"),
	conflicts = safe_load_extension("conflicts"),
	tabs = safe_load_extension("tabs"),
	cmdline = safe_load_extension("cmdline"),
	xray23 = safe_load_extension("xray23"),
}

-- ===== PERFORMANCE-OPTIMIZED DEFAULTS =====
local telescope_opts = {
	defaults = {
		-- 高速ソーター設定
		file_sorter = extensions_loaded.fzf and telescope.extensions.fzf.native_fzf_sorter() or nil,
		generic_sorter = extensions_loaded.fzf and telescope.extensions.fzf.native_fzf_sorter() or nil,

		-- パフォーマンス最適化
		cache_picker = {
			num_pickers = 10,
			limit_entries = 1000,
		},

		-- ファイル除外パターン
		file_ignore_patterns = {
			"node_modules/*",
			".git/*",
			"%.class",
			"%.pdf",
			"%.mkv",
			"%.mp4",
			"%.zip",
			"target/*",
			"build/*",
			"dist/*",
		},

		-- 美しいUI設定
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" },

		-- プレビュー最適化
		preview = {
			timeout = 250,
			highlight_limit = 1, -- 1MB以上はハイライト無し
			treesitter = true,
			hide_on_startup = false,
		},

		-- パス表示最適化
		path_display = {
			"truncate", -- 長いパスは省略
			shorten = {
				len = 3,
				exclude = { 1, -1 }, -- 最初と最後のディレクトリは省略しない
			},
		},

		-- レイアウト設定
		layout_strategy = "flex",
		layout_config = {
			flex = {
				flip_columns = 120,
			},
			horizontal = {
				width = 0.9,
				height = 0.8,
				preview_width = 0.6,
			},
			vertical = {
				width = 0.9,
				height = 0.95,
				preview_height = 0.5,
			},
		},

		-- 高度なキーマップ
		mappings = {
			i = {
				-- 移動系
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				-- セレクション系
				["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
				["<C-a>"] = actions.select_all,
				["<C-l>"] = actions.complete_tag,

				-- quickfix系
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_to_qflist + actions.open_qflist,

				-- レイアウト系
				["<C-t>"] = action_layout.toggle_preview,
				["<C-h>"] = action_layout.toggle_prompt_position,
				["<C-s>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,

				-- スクロール系
				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<C-f>"] = actions.results_scrolling_up,
				["<C-b>"] = actions.results_scrolling_down,
			},
			n = {
				-- 基本移動
				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,

				-- セレクション
				["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,

				-- quickfix
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_to_qflist + actions.open_qflist,

				-- レイアウト
				["<C-t>"] = action_layout.toggle_preview,
				["<C-h>"] = action_layout.toggle_prompt_position,

				-- 閉じる
				["q"] = actions.close,
				["<Esc>"] = actions.close,
			},
		},
	},
	-- ===== BUILTIN PICKERS OPTIMIZATION =====
	pickers = {
		-- ファイル検索最適化
		find_files = {
			theme = "ivy",
			hidden = true,
			no_ignore = false,
			follow = true,
			layout_config = {
				height = 0.4,
				preview_cutoff = 120,
			},
		},

		-- ライブgrep最適化
		live_grep = {
			theme = "ivy",
			additional_args = function()
				return { "--hidden", "--glob", "!.git" }
			end,
			layout_config = {
				height = 0.4,
			},
		},

		-- バッファ検索最適化
		buffers = {
			theme = "dropdown",
			sort_mru = true,
			select_current = false,
			layout_config = {
				width = 0.7,
				height = 0.6,
			},
		},

		-- ヘルプ検索最適化
		help_tags = {
			theme = "ivy",
			lang = "ja",
			fallback = true,
		},

		-- 旧ファイル検索
		oldfiles = {
			theme = "ivy",
			only_cwd = true,
			layout_config = {
				height = 0.4,
			},
		},

		-- コマンド履歴
		command_history = {
			theme = "cursor",
			layout_config = {
				width = 0.6,
				height = 0.4,
			},
		},

		-- Gitファイル
		git_files = {
			theme = "ivy",
			show_untracked = true,
			recurse_submodules = false,
		},

		-- Gitコミット
		git_commits = {
			theme = "ivy",
			layout_config = {
				height = 0.6,
				preview_height = 0.5,
			},
		},

		-- Gitステータス
		git_status = {
			theme = "ivy",
			layout_config = {
				height = 0.5,
			},
		},

		-- カラースキーム
		colorscheme = {
			theme = "dropdown",
			enable_preview = true,
			layout_config = {
				width = 0.5,
				height = 0.6,
			},
		},

		-- レジスタ
		registers = {
			theme = "cursor",
			layout_config = {
				width = 0.5,
				height = 0.4,
			},
		},

		-- キーマップ
		keymaps = {
			theme = "ivy",
			layout_config = {
				height = 0.5,
			},
		},
	},
	-- ===== EXTENSIONS CONFIGURATION =====
	extensions = {
		-- FZFネイティブソーター
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},

		-- ファイルブラウザー
		file_browser = {
			theme = "ivy",
			hijack_netrw = true,
			mappings = {
				["i"] = {
					["<C-n>"] = require("telescope._extensions.file_browser.actions").create,
					["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
					["<C-d>"] = require("telescope._extensions.file_browser.actions").remove,
					["<C-m>"] = require("telescope._extensions.file_browser.actions").move,
					["<C-y>"] = require("telescope._extensions.file_browser.actions").copy,
					["<C-h>"] = require("telescope._extensions.file_browser.actions").toggle_hidden,
				},
				["n"] = {
					["n"] = require("telescope._extensions.file_browser.actions").create,
					["r"] = require("telescope._extensions.file_browser.actions").rename,
					["d"] = require("telescope._extensions.file_browser.actions").remove,
					["m"] = require("telescope._extensions.file_browser.actions").move,
					["y"] = require("telescope._extensions.file_browser.actions").copy,
					["h"] = require("telescope._extensions.file_browser.actions").toggle_hidden,
				},
			},
		},

		-- UI選択統合
		["ui-select"] = {
			themes.get_dropdown({
				winblend = 10,
				width = 0.5,
				height = 0.4,
				border = true,
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			}),
		},

		-- 記号・絵文字検索
		symbols = {
			sources = { "emoji", "kaomoji", "gitmoji", "julia", "math" },
		},

		-- プロジェクト管理
		project = {
			base_dirs = (function()
				local dirs = {}
				local function file_exists(fname)
					local stat = vim.loop.fs_stat(vim.fn.expand(fname))
					return (stat and stat.type) or false
				end

				-- 一般的な開発ディレクトリ
				local common_dirs = {
					{ "~/.ghq", max_depth = 5 },
					{ "~/Workspace", max_depth = 3 },
					{ "~/Projects", max_depth = 3 },
					{ "~/src", max_depth = 3 },
					{ "~/dev", max_depth = 3 },
					{ "~/dotfiles", max_depth = 2 },
				}

				for _, dir_config in ipairs(common_dirs) do
					if file_exists(dir_config[1]) then
						dirs[#dirs + 1] = dir_config
					end
				end

				-- フォールバック: カレントディレクトリ
				if #dirs == 0 then
					dirs[#dirs + 1] = { vim.fn.getcwd(), max_depth = 1 }
				end

				return dirs
			end)(),
			hidden_files = true,
			theme = "dropdown",
			order_by = "recent",
			search_by = "title",
		},

		-- 最近使用ファイル
		recent_files = {
			only_cwd = false,
			show_current_file = false,
		},

		-- アンドゥツリー
		undo = {
			use_delta = true,
			use_custom_command = nil,
			side_by_side = false,
			layout_strategy = "vertical",
			layout_config = {
				preview_height = 0.8,
			},
			mappings = {
				i = {
					["<C-cr>"] = require("telescope-undo.actions").yank_additions,
					["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
					["<C-r>"] = require("telescope-undo.actions").restore,
				},
				n = {
					["y"] = require("telescope-undo.actions").yank_additions,
					["Y"] = require("telescope-undo.actions").yank_deletions,
					["u"] = require("telescope-undo.actions").restore,
				},
			},
		},

		-- 見出し検索
		heading = {
			treesitter = true,
		},

		-- ===== HIGH PRIORITY EXTENSIONS =====
		-- Frecency: 学習機能付きファイル検索
		frecency = {
			show_scores = false,
			show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*" },
			disable_devicons = false,
			workspaces = {
				["config"] = vim.fn.expand("~/.config"),
				["nvim"] = vim.fn.stdpath("config"),
				["data"] = vim.fn.stdpath("data"),
				["projects"] = vim.fn.expand("~/Projects"),
				["dotfiles"] = vim.fn.expand("~/dotfiles"),
			},
		},

		-- Yanky: ヤンク履歴管理
		yanky = {
			ring = {
				history_length = 100,
				storage = "sqlite",
			},
			picker = {
				select = {
					action = nil,
				},
				telescope = {
					mappings = nil,
					use_default_mappings = true,
				},
			},
			system_clipboard = {
				sync_with_ring = true,
			},
		},

		-- Media Files: メディアプレビュー
		media_files = {
			filetypes = { "png", "webp", "jpg", "jpeg", "gif", "pdf", "mp4", "webm" },
			find_cmd = "rg",
		},

		-- Git Conflicts: Git競合解決
		conflicts = {
			layout_strategy = "horizontal",
			layout_config = {
				height = 0.7,
				width = 0.9,
				preview_width = 0.6,
			},
		},

		-- Tabs: タブ管理
		tabs = {
			theme = "dropdown",
			layout_config = {
				width = 0.8,
				height = 0.6,
			},
			show_preview = true,
			close_tab_shortcut_i = "<C-d>",
			close_tab_shortcut_n = "d",
		},

		-- Command Line: フローティングコマンドライン
		cmdline = {
			picker = {
				layout_config = {
					width = 120,
					height = 25,
				},
			},
			mappings = {
				complete = "<Tab>",
				run_selection = "<C-CR>",
				run_input = "<CR>",
			},
		},

		-- Session: セッション管理 (xray23)
		xray23 = {
			prompt_title = "Sessions",
			layout_config = {
				width = 0.6,
				height = 0.5,
			},
			sessionDir = vim.fn.stdpath("data") .. "/vimSession",
		},
	},
}

-- ===== TELESCOPE SETUP =====
telescope.setup(telescope_opts)

-- ===== CUSTOM PICKERS =====
-- モジュール用の関数をエクスポート
local M = {}

-- Dotfiles専用ピッカー
function M.find_dotfiles()
	local dotfiles_path = vim.fn.expand("~/.config")
	builtin.find_files({
		prompt_title = "< Dotfiles >",
		cwd = dotfiles_path,
		hidden = true,
		follow = true,
		file_ignore_patterns = { ".git/", "node_modules/" },
	})
end

-- Neovim設定専用ピッカー
function M.find_nvim_config()
	local nvim_config = vim.fn.stdpath("config")
	builtin.find_files({
		prompt_title = "< Neovim Config >",
		cwd = nvim_config,
		follow = true,
		file_ignore_patterns = { "lazy-lock.json" },
	})
end

-- プロジェクトTODO検索
function M.find_project_todos()
	builtin.live_grep({
		prompt_title = "< Project TODOs >",
		default_text = "TODO|FIXME|BUG|HACK|NOTE",
		additional_args = function()
			return { "--hidden", "--glob", "!.git", "--ignore-case" }
		end,
	})
end

-- 最近のファイルとoldfiles統合
function M.find_recent_files()
	if extensions_loaded.recent_files then
		telescope.extensions.recent_files.pick()
	else
		builtin.oldfiles()
	end
end

-- モジュールをエクスポート（他の設定ファイルから使用可能にする）
return M
