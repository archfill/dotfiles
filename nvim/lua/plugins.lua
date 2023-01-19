local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------------
---- Load local plugins
local function load_local_plugins()
	if vim.fn.filereadable(vim.fn.expand("~/.nvim_pluginlist_local.lua")) == 1 then
		return dofile(vim.fn.expand("~/.nvim_pluginlist_local.lua"))
	end
end
local local_plugins = load_local_plugins() or {}

local plugins = {
	----------------------------------------------------------------
	-- Installer
	{ "folke/lazy.nvim" },

	-- External package Installer
	{
		"williamboman/mason.nvim",
		event = "VimEnter",
		config = function()
			require("mason").setup({})
		end,
	},

	--------------------------------
	-- Lua Library
	{ "nvim-lua/popup.nvim" },
	{ "nvim-lua/plenary.nvim" }, -- do not lazy load
	{ "MunifTanjim/nui.nvim" },
	{ "tami5/sqlite.lua" },

	--------------------------------
	-- denops
	{ "vim-denops/denops.vim", event = "VimEnter" },

	--------------------------------
	-- Notify
	{ "rcarriga/nvim-notify" },

	-- color scheme
	{ "EdenEast/nightfox.nvim" },

	-- font
	{
		"kyazdani42/nvim-web-devicons",
		config = function()
			require("pluginconfig.nvim-web-devicons")
		end,
	},

	--------------------------------
	-- Auto Completion
	{
		"hrsh7th/nvim-cmp",
		event = "VimEnter",
		config = function()
			require("pluginconfig/nvim-cmp")
		end,
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "hrsh7th/cmp-nvim-lsp-document-symbol" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-emoji" },
			{ "hrsh7th/cmp-calc" },
			{ "f3fora/cmp-spell" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "ray-x/cmp-treesitter" },
			{
				"onsails/lspkind.nvim",
				config = function()
					require("pluginconfig.lspkind")
				end,
			},
			{
				"vim-skk/skkeleton",
				config = function()
					require("pluginconfig.skkeleton")
				end,
				after = { "denops.vim" },
				dependencies = {
					{ "rinx/cmp-skkeleton" },
				},
			},
			{
				"delphinus/skkeleton_indicator.nvim",
				config = function()
					require("pluginconfig.skkeleton_indicator")
				end,
			},
		},
	},

	--------------------------------
	-- lsp
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre" },
		-- config = function()
		-- 	require("pluginconfig.nvim-lspconfig")
		-- end,
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				config = function()
					require("pluginconfig.mason-lspconfig")
				end,
			},
		},
	},
	{
		"tamago324/nlsp-settings.nvim",
		after = { "nvim-lspconfig" },
		config = function()
			require("pluginconfig.nlsp-settings")
		end,
	},

	-- lsp ui
	{
		"glepnir/lspsaga.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lspsaga")
		end,
	},
	{
		"folke/lsp-colors.nvim",
	},
	{
		"folke/trouble.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.trouble")
		end,
	},
	{
		"j-hui/fidget.nvim",
		event = "VimEnter",
		config = function()
			require("fidget").setup({})
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
			require("pluginconfig.telescope")
		end,
		dependencies = {
			{
				"nvim-telescope/telescope-frecency.nvim",
				-- config = function()
				-- 	require("telescope").load_extension("frecency")
				-- end,
			},
			{
				"nvim-telescope/telescope-packer.nvim",
				-- config = function()
				-- 	require("telescope").load_extension("packer")
				-- end,
			},
			{
				"delphinus/telescope-memo.nvim",
				-- config = function()
				-- 	require("telescope").load_extension("memo")
				-- end,
			},
			{
				"benfowler/telescope-luasnip.nvim",
				-- config = function()
				-- 	require("telescope").load_extension("luasnip")
				-- end,
			},
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "VimEnter" },
		run = ":TSUpdateSync",
		config = function()
			require("pluginconfig/nvim-treesitter")
		end,
		dependencies = {
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			-- { "nvim-treesitter/nvim-treesitter-context" },
			{ "nvim-treesitter/nvim-treesitter-refactor" },
			{ "nvim-treesitter/nvim-tree-docs" },
			{ "yioneko/nvim-yati" },
		},
	},

	-- Treesitter UI customize
	{ "mrjones2014/nvim-ts-rainbow", event = "VimEnter" },
	{ "haringsrob/nvim_context_vt", event = "VimEnter" },
	{
		"m-demare/hlargs.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.hlargs")
		end,
	},
	{
		"romgrk/nvim-treesitter-context",
		cmd = { "TSContextEnable" },
	},

	--------------------------------------------------------------
	-- Appearance

	-- status line
	{
		"nvim-lualine/lualine.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lualine")
		end,
	},

	--------------------------------
	-- Bufferline
	{
		"akinsho/bufferline.nvim",
		event = "VimEnter",
		enabled = function()
			return not vim.g.vscode
		end,
		config = function()
			require("pluginconfig.bufferline")
		end,
	},

	----------------------------------
	---- Syntax

	-- highlight
	{
		"norcalli/nvim-colorizer.lua",
		event = "VimEnter",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "VimEnter",
		config = function()
			require("pluginconfig.vim-illuminate")
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		event = "VimEnter",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.todo-comments")
		end,
	},
	{
		"mvllow/modes.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.modes")
		end,
	},

	--------------------------------
	-- Sidebar
	-- conflict with clever-f (augroup sidebar_nvim_prevent_buffer_override)
	{
		"GustavoKatel/sidebar.nvim",
		cmd = { "SidebarNvimToggle" },
		config = function()
			require("pluginconfig.sidebar")
		end,
	},

	--------------------------------
	-- Snippet
	{
		"L3MON4D3/LuaSnip",
		event = "VimEnter",
		config = function()
			require("pluginconfig.LuaSnip")
		end,
	},

	-- formatter
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.null-ls")
		end,
	},

	-- comment out
	{
		"numToStr/Comment.nvim",
		event = "VimEnter",
		config = function()
			require("Comment").setup()
		end,
	},

	-- bracket
	{
		"windwp/nvim-autopairs",
		event = "VimEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	--------------------------------
	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		event = "VimEnter",
		config = function()
			require("pluginconfig.nvim-scrollbar")
		end,
		dependencies = { { "kevinhwang91/nvim-hlslens" } },
	},

	--------------------------------
	-- Move
	{
		"phaazon/hop.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.hop")
		end,
	},

	--------------------------------
	-- Window
	{
		"kwkarlwang/bufresize.nvim",
		event = "WinNew",
		config = function()
			require("pluginconfig.bufresize")
		end,
	},

	--------------------------------
	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.toggleterm")
		end,
	},

	--------------------------------
	-- Reading assistant
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.indent-blankline")
		end,
	},

	--------------------------------
	-- file finder
	{
		"nvim-neo-tree/neo-tree.nvim",
		event = "VimEnter",
		branch = "main",
		config = function()
			require("pluginconfig.neo-tree")
		end,
	},

	--------------------------------
	-- Project
	{
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.project")
		end,
	},

	--------------------------------
	-- Git
	{
		"TimUntersberger/neogit",
		event = "BufReadPre",
		config = function()
			require("pluginconfig.neogit")
		end,
	},
	{
		"akinsho/git-conflict.nvim",
		event = "VimEnter",
		config = function()
			require("git-conflict").setup()
		end,
	},
	{ "yutkat/convert-git-url.nvim", cmd = { "ConvertGitUrl" } },
	{
		"lewis6991/gitsigns.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.gitsigns")
		end,
	},
	{
		"sindrets/diffview.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.diffview")
		end,
	},

	--------------------------------
	-- Translate
	{
		"uga-rosa/translate.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.translate")
		end,
	},

	--------------------------------
	-- language
	--- flutter
	{
		"akinsho/flutter-tools.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.flutter-tools")
		end,
	},

	--------------------------------
	-- markdown
	{
		"previm/previm",
		event = "VimEnter",
		config = function()
			require("pluginconfig.previm")
		end,
		dependencies = { "tyru/open-browser.vim" },
	},

	--------------------------------
	-- tools
	--- memo
	{
		"glidenote/memolist.vim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.memolist")
		end,
	},

	-- neorg
	{
		"nvim-neorg/neorg",
		event = "VimEnter",
		after = { "nvim-treesitter", "nvim-cmp" },
		run = ":Neorg sync-parsers",
		ft = { "norg" },
		config = function()
			require("pluginconfig.neorg")
		end,
	},
}

require("lazy").setup(vim.tbl_deep_extend("force", plugins, local_plugins), {
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
	},
})
