-- ===== NEOVIM COMMON CONFIGURATION BASE =====
-- このファイルはStable版とNightly版の共通プラグイン設定です
-- バージョン固有のプラグインは plugins_stable.lua / plugins_nightly.lua に定義
-- ===================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}, { text = true }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

----------------------------------------------------------------
---- Load local plugins
local function load_local_plugins()
	if vim.fn.filereadable(vim.fn.expand("~/.nvim_pluginlist_local.lua")) == 1 then
		return dofile(vim.fn.expand("~/.nvim_pluginlist_local.lua"))
	end
end
local local_plugins = load_local_plugins() or {}

-- 共通プラグイン定義
local common_plugins = {
	----------------------------------------------------------------
	-- Installer
	{ "folke/lazy.nvim" },

	-- External package Installer
	{
		"williamboman/mason.nvim",
		event = { "BufReadPre", "VimEnter" },
		config = function()
			require("mason").setup({})
		end,
	},

	--------------------------------
	-- Vim script Library
	{ "tpope/vim-repeat", event = "VimEnter" },

	--------------------------------
	-- Lua Library
	{ "nvim-lua/popup.nvim" },
	{ "nvim-lua/plenary.nvim" },
	{ "MunifTanjim/nui.nvim" },
	{ "tami5/sqlite.lua" },

	--------------------------------
	-- UI Library
	{
		"stevearc/dressing.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.ui.dressing")
		end,
	},

	--------------------------------
	-- denops
	{ "vim-denops/denops.vim", event = "VeryLazy" },

	--------------------------------
	-- Notify
	{
		"rcarriga/nvim-notify",
		event = "BufReadPre",
		config = function()
			require("pluginconfig.tools.nvim-notify")
		end,
	},

	-- color scheme
	{ "folke/tokyonight.nvim" },

	-- font
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("pluginconfig.ui.nvim-web-devicons")
		end,
	},

	--------------------------------
	-- Auto Completion
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			require("pluginconfig.editor.nvim-cmp")
		end,
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "hrsh7th/cmp-nvim-lsp-document-symbol" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-nvim-lua" },
			{
				"zbirenbaum/copilot-cmp",
				config = function()
					require("copilot_cmp").setup()
				end,
			},
			{ "hrsh7th/cmp-emoji" },
			{ "hrsh7th/cmp-calc" },
			{ "f3fora/cmp-spell" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "ray-x/cmp-treesitter" },
			{
				"onsails/lspkind.nvim",
				config = function()
					require("pluginconfig.tools.lspkind")
				end,
			},
			{
				"vim-skk/skkeleton",
				config = function()
					require("pluginconfig.language.skkeleton")
				end,
				dependencies = {
					{ "rinx/cmp-skkeleton", "vim-denops/denops.vim" },
				},
			},
			{
				"delphinus/skkeleton_indicator.nvim",
				cond = function()
					return not vim.g.vscode
				end,
				config = function()
					require("pluginconfig.language.skkeleton_indicator")
				end,
			},
			{ "lukas-reineke/cmp-rg" },
		},
	},

	--------------------------------
	-- lsp
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre" },
		config = function()
			require("pluginconfig.lsp.nvim-lspconfig")
		end,
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				config = function()
					require("pluginconfig.lsp.mason-lspconfig")
				end,
			},
		},
	},
	{
		"tamago324/nlsp-settings.nvim",
		config = function()
			require("pluginconfig.lsp.nlsp-settings")
		end,
	},

	-- lsp ui
	{
		"nvimdev/lspsaga.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lsp.lspsaga")
		end,
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter" },
			{ "nvim-tree/nvim-web-devicons" },
		},
	},
	{
		"folke/trouble.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lsp.trouble")
		end,
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lsp.fidget")
		end,
	},

	--------------------------------------------------------------
	-- FuzzyFinders
	--------------------------------
	-- telescope.nvim
	{
		"nvim-telescope/telescope.nvim",
		event = { "VimEnter" },
		config = function()
			require("pluginconfig.tools.telescope")
		end,
		dependencies = {
			{
				"nvim-telescope/telescope-frecency.nvim",
				dependencies = { "tami5/sqlite.lua" },
			},
			{
				"delphinus/telescope-memo.nvim",
			},
			{
				"benfowler/telescope-luasnip.nvim",
			},
			{
				"nvim-telescope/telescope-ui-select.nvim",
			},
			{ "nvim-telescope/telescope-symbols.nvim" },
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "VeryLazy" },
		cmd = "TSUpdateSync",
		config = function()
			require("pluginconfig.editor.nvim-treesitter")
		end,
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				config = function()
					require("ts_context_commentstring").setup({})
					vim.g.skip_ts_context_commentstring_module = true
				end,
			},
			{ "nvim-treesitter/nvim-treesitter-refactor" },
			{ "nvim-treesitter/nvim-tree-docs" },
			{ "yioneko/nvim-yati" },
		},
	},

	-- 他の共通プラグインを続ける...
	-- [省略: 残りの共通プラグインも同様に定義]
}

-- バージョン固有プラグインの読み込み関数
local function load_version_plugins()
	local nvim_version = vim.version()
	local is_nightly = nvim_version.prerelease ~= nil
	
	if is_nightly then
		-- Nightly版の実験的プラグインを読み込み
		local nightly_plugins = require("plugins_nightly")
		return vim.tbl_extend("force", common_plugins, nightly_plugins)
	else
		-- Stable版の追加プラグインを読み込み (現在は空)
		local stable_plugins = require("plugins_stable") 
		return vim.tbl_extend("force", common_plugins, stable_plugins)
	end
end

-- 共通プラグインをエクスポート
return {
	common_plugins = common_plugins,
	load_all_plugins = load_version_plugins,
}