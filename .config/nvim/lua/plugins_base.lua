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

	-- Telescope: ファジーファインダー
	{
		"nvim-telescope/telescope.nvim",
		keys = plugin_keymaps.get_plugin_keys("telescope"),
		cmd = { "Telescope" },
		dependencies = { "nvim-lua/plenary.nvim" },
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

	-- Notify: 通知管理
	{
		"rcarriga/nvim-notify",
		keys = plugin_keymaps.get_plugin_keys("nvim_notify"),
		event = "VeryLazy",
		config = function()
			require("pluginconfig.tools.nvim-notify")
		end,
	},

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

	-- nvim-cmp: 複雑な条件分岐とコンテキスト依存のため設定ファイルが最適
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			require("pluginconfig.editor.nvim-cmp")
		end,
	},

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

	-- Start screen
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.ui.alpha")
		end,
	},

	-- Modern UI for messages, cmdline, and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.ui.noice")
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},

	-- ================================================================
	-- EDITOR ENHANCEMENTS
	-- ================================================================

	-- Perfect indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufReadPost",
		config = function()
			require("pluginconfig.editor.ibl")
		end,
	},

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
}

return common_plugins