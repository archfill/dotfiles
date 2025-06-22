-- ===== NEOVIM PERFORMANCE-OPTIMIZED PLUGIN CONFIGURATION =====
-- パフォーマンス最優先でプラグイン別にキーマップを最適化
-- Category A: keys設定（完全遅延読み込み）
-- Category B: 設定ファイル管理（複雑な処理）
-- Category C: ハイブリッド（基本はkeys、複雑部分は設定ファイル）
-- ===================================================

-- グローバルキーマップを読み込み
require("core.global-keymap")

-- プラグイン別キーマップを取得
local plugin_keymaps = require("keymap.plugins")

local common_plugins = {
	-- ================================================================
	-- CATEGORY A: FULL KEYS OPTIMIZATION (完全遅延読み込み)
	-- ================================================================

	-- Neo-tree: ファイルエクスプローラー
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = plugin_keymaps.get_plugin_keys("neo_tree"),
		cmd = { "Neotree" },
		branch = "main",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("pluginconfig.tools.neo-tree")
		end,
	},

	-- Telescope: ファジーファインダー + 高性能拡張
	{
		"nvim-telescope/telescope.nvim",
		keys = plugin_keymaps.get_plugin_keys("telescope"),
		cmd = { "Telescope" },
		dependencies = { 
			"nvim-lua/plenary.nvim",
			-- ===== CORE EXTENSIONS =====
			-- 高性能ソーター拡張
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable "make" == 1
				end,
			},
			-- ファイルブラウザー拡張
			"nvim-telescope/telescope-file-browser.nvim",
			-- UI統合拡張
			"nvim-telescope/telescope-ui-select.nvim",
			-- 記号・絵文字検索
			"nvim-telescope/telescope-symbols.nvim",
			-- プロジェクト管理
			{
				"nvim-telescope/telescope-project.nvim",
				dependencies = { "nvim-telescope/telescope-file-browser.nvim" },
			},
			-- 最近使用ファイル
			"smartpde/telescope-recent-files",
			-- アンドゥツリー
			"debugloop/telescope-undo.nvim",
			-- 見出し検索
			"crispgm/telescope-heading.nvim",
			-- Git競合解決
			"Snikimonkd/telescope-git-conflicts.nvim",
			-- セッション管理
			"HUAHUAI23/telescope-session.nvim",

			-- ===== HIGH PRIORITY ADDITIONS =====
			-- Frecency: 学習機能付きファイル検索
			{
				"nvim-telescope/telescope-frecency.nvim",
				dependencies = {
					{ "kkharji/sqlite.lua" },
				},
			},
			-- Yanky: ヤンク履歴管理
			{
				"gbprod/yanky.nvim",
				opts = {},
			},
			-- Media Files: 画像・PDF・動画プレビュー
			{
				"nvim-telescope/telescope-media-files.nvim",
				dependencies = {
					"nvim-lua/popup.nvim",
				},
			},
			-- Tabs: タブ管理強化
			"LukasPietzschmann/telescope-tabs",
			-- Command Line: フローティングコマンドライン
			"jonarrien/telescope-cmdline.nvim",
		},
		config = function()
			require("pluginconfig.tools.telescope")
		end,
	},

	-- Conform: フォーマッター
	{
		"stevearc/conform.nvim",
		keys = plugin_keymaps.get_plugin_keys("conform"),
		event = { "BufWritePre" },
		config = function()
			require("pluginconfig.lsp.conform")
		end,
	},

	-- Notify: 通知管理 - MIGRATED to snacks.notifier
	-- {
	-- 	"rcarriga/nvim-notify",
	-- 	keys = plugin_keymaps.get_plugin_keys("nvim_notify"),
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("pluginconfig.tools.nvim-notify")
	-- 	end,
	-- },

	-- Possession: セッション管理
	{
		"jedrzejboczar/possession.nvim",
		keys = plugin_keymaps.get_plugin_keys("possession"),
		cmd = { "PossessionSave", "PossessionLoad", "PossessionDelete", "PossessionClose" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("pluginconfig.editor.possession")
		end,
	},

	-- ================================================================
	-- LIBRARIES & DEPENDENCIES
	-- ================================================================
	{ "nvim-lua/plenary.nvim" },
	{ "MunifTanjim/nui.nvim", lazy = false, priority = 500 },

	-- ================================================================
	-- CATEGORY B: CONFIG FILE OPTIMIZATION (設定ファイルで管理)
	-- ================================================================

	-- blink.cmp: Modern Rust-based completion plugin for better performance
	{
		"saghen/blink.cmp",
		version = "1.*", -- use release version for stability
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"rafamadriz/friendly-snippets", -- snippets collection
		},
		config = function()
			require("pluginconfig.editor.blink-cmp")
		end,
	},

	-- nvim-cmp: MIGRATED to blink.cmp - keeping as reference for now
	-- {
	-- 	"hrsh7th/nvim-cmp",
	-- 	event = { "InsertEnter", "CmdlineEnter" },
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"hrsh7th/cmp-buffer",
	-- 		"hrsh7th/cmp-path",
	-- 		"hrsh7th/cmp-cmdline",
	-- 	},
	-- 	config = function()
	-- 		require("pluginconfig.editor.nvim-cmp")
	-- 	end,
	-- },

	-- nvim-treesitter: 初期化とハイライト設定が必要なため設定ファイルが最適
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("pluginconfig.editor.nvim-treesitter")
		end,
	},

	-- Comment.nvim: treesitter連携と複雑な判定処理のため設定ファイルが最適
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("pluginconfig.editor.Comment")
		end,
	},

	-- ================================================================
	-- CATEGORY C: HYBRID OPTIMIZATION (ハイブリッド)
	-- ================================================================

	-- LSP: 基本操作は keys、複雑な設定は初期化後
	{
		"williamboman/mason-lspconfig.nvim",
		keys = plugin_keymaps.get_plugin_keys("lspconfig_basic"),
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("pluginconfig.lsp.mason-lspconfig")
		end,
	},

	-- lspsaga: 美しいLSP UI拡張（Category A - keys最適化）
	{
		"nvimdev/lspsaga.nvim",
		keys = plugin_keymaps.get_plugin_keys("lspsaga"),
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("pluginconfig.lsp.lspsaga")
		end,
	},

	-- nvim-lint: 軽量リンティング
	{
		"mfussenegger/nvim-lint",
		keys = {
			{ "<leader>l", function() require("lint").try_lint() end, desc = "Trigger linting" },
		},
		event = { "BufWritePost", "BufReadPost", "InsertLeave" },
		config = function()
			require("pluginconfig.lsp.nvim-lint")
		end,
	},

	-- nvim-cokeline: 基本バッファ操作は keys、複雑な表示設定は初期化後
	{
		"willothy/nvim-cokeline",
		keys = plugin_keymaps.get_plugin_keys("nvim_cokeline_basic"),
		event = "BufReadPost",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("pluginconfig.ui.nvim-cokeline")
		end,
	},

	-- which-key: 説明表示のみなので設定ファイルが最適
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.ui.which-key")
		end,
	},

	-- ================================================================
	-- ESSENTIAL PLUGINS (起動時必須)
	-- ================================================================
	
	-- Package Manager
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
		event = "VeryLazy",
		config = function()
			require("pluginconfig.lsp.mason")
		end,
	},

	-- ================================================================
	-- UI & VISUAL ENHANCEMENTS
	-- ================================================================
	
	-- Snacks.nvim: Modern UI components collection
	-- Replaces: alpha-nvim, nvim-notify, indent-blankline.nvim
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		keys = vim.list_extend(
			plugin_keymaps.get_plugin_keys("snacks_notifier"),
			plugin_keymaps.get_plugin_keys("snacks_dashboard")
		),
		config = function()
			require("pluginconfig.ui.snacks")
		end,
	},
	
	-- Color scheme
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },

	-- Icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = false,
		config = function()
			require("pluginconfig.ui.nvim-web-devicons")
		end,
	},

	-- Beautiful statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("pluginconfig.ui.lualine")
		end,
	},

	-- Start screen - MIGRATED to snacks.dashboard
	-- {
	-- 	"goolord/alpha-nvim",
	-- 	event = "VimEnter",
	-- 	config = function()
	-- 		require("pluginconfig.ui.alpha")
	-- 	end,
	-- },

	-- Modern UI for messages, cmdline, and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.ui.noice")
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"folke/snacks.nvim", -- Using snacks.notifier instead of nvim-notify
		},
	},

	-- ================================================================
	-- EDITOR ENHANCEMENTS
	-- ================================================================

	-- Perfect indent guides - MIGRATED to snacks.indent
	-- {
	-- 	"lukas-reineke/indent-blankline.nvim",
	-- 	event = "BufReadPost",
	-- 	config = function()
	-- 		require("pluginconfig.editor.ibl")
	-- 	end,
	-- },

	-- High-performance color highlighting
	{
		"norcalli/nvim-colorizer.lua",
		event = "BufReadPost",
		config = function()
			require("pluginconfig.editor.nvim-colorizer")
		end,
	},

	-- Smart cursor word highlighting
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		config = function()
			require("pluginconfig.editor.vim-illuminate")
		end,
	},

	-- 高機能末尾空白処理
	{
		"ntpeters/vim-better-whitespace",
		event = "BufReadPost",
		config = function()
			require("pluginconfig.editor.vim-better-whitespace")
		end,
	},

	-- Fast autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "nvim-cmp" },
		config = function()
			require("pluginconfig.editor.nvim-autopairs")
		end,
	},

	-- denops
	{ "vim-denops/denops.vim", event = "VeryLazy" },

	-- ================================================================
	-- FLUTTER & DART DEVELOPMENT
	-- ================================================================

	-- Flutter統合開発ツール
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = { "dart" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim",
		},
		keys = plugin_keymaps.get_plugin_keys("flutter_tools"),
		config = function()
			require("pluginconfig.language.flutter-tools")
		end,
	},

	-- Dart基本サポート
	{
		"dart-lang/dart-vim-plugin",
		ft = { "dart" },
		config = function()
			require("pluginconfig.language.dart-vim")
		end,
	},


	-- pubspec.yaml管理
	{
		"nvim-flutter/pubspec-assist.nvim",
		ft = { "yaml" },
		config = function()
			require("pluginconfig.language.pubspec")
		end,
	},

	-- デバッグアダプター（Category A - keys最適化）
	{
		"mfussenegger/nvim-dap",
		keys = plugin_keymaps.get_plugin_keys("nvim_dap"),
		dependencies = {
			-- デバッグUI
			"rcarriga/nvim-dap-ui",
			-- 仮想テキスト
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			require("pluginconfig.debug.nvim-dap")
		end,
	},

	-- ===== AI DEVELOPMENT TOOLS =====
	-- Claude Code Integration
	{
		"greggh/claude-code.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = plugin_keymaps.get_plugin_keys("claude_code"),
		cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeVerbose", "ClaudeCodeResume" },
		config = function()
			require("pluginconfig.tools.claude-code")
		end,
	},
}

return common_plugins