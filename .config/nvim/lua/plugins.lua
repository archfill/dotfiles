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

local plugins = {
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
			require("pluginconfig.dressing")
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
			require("pluginconfig/nvim-notify")
		end,
	},

	-- color scheme
	-- { "EdenEast/nightfox.nvim" },
	{ "folke/tokyonight.nvim" },

	-- font
	{
		"nvim-tree/nvim-web-devicons",
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
					require("pluginconfig.lspkind")
				end,
			},
			{
				"vim-skk/skkeleton",
				config = function()
					require("pluginconfig.skkeleton")
				end,
				dependencies = {
					{ "rinx/cmp-skkeleton", "vim-denops/denops.vim" },
				},
			},
			{
				"delphinus/skkeleton_indicator.nvim",
				config = function()
					require("pluginconfig.skkeleton_indicator")
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
			require("pluginconfig.nvim-lspconfig")
		end,
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				config = function()
					require("pluginconfig.mason-lspconfig")
				end,
			},
			{ "weilbith/nvim-lsp-smag", after = "nvim-lspconfig" },
		},
	},
	{
		"tamago324/nlsp-settings.nvim",
		config = function()
			require("pluginconfig.nlsp-settings")
		end,
	},

	-- lsp ui
	{
		"nvimdev/lspsaga.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.lspsaga")
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
			require("pluginconfig.trouble")
		end,
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		event = "VimEnter",
		config = function()
			require("pluginconfig.fidget")
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
			{
				"nvim-telescope/telescope-ui-select.nvim",
				-- config = function()
				-- 	require("telescope").load_extension("ui-select")
				-- end,
			},
			{ "nvim-telescope/telescope-symbols.nvim" }, --- Used in telekasten.nvim
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "VeryLazy" },
		-- event = { "BufRead", "BufNewFile", "InsertEnter" },
		cmd = "TSUpdateSync",
		config = function()
			require("pluginconfig/nvim-treesitter")
		end,
		dependencies = {
			{
				"JoosepAlviste/nvim-ts-context-commentstring",
				config = function()
					require("ts_context_commentstring").setup({
						-- enable = true,
					})

					vim.g.skip_ts_context_commentstring_module = true
				end,
			},
			-- { "nvim-treesitter/nvim-treesitter-context" },
			{ "nvim-treesitter/nvim-treesitter-refactor" },
			{ "nvim-treesitter/nvim-tree-docs" },
			{ "yioneko/nvim-yati" },
		},
	},

	--------------------------------
	-- Treesitter textobject & operator
	{ "nvim-treesitter/nvim-treesitter-textobjects", event = "VeryLazy" },
	{
		"chrisgrieser/nvim-various-textobjs",
		event = "VeryLazy",
		config = function()
			require("pluginconfig/nvim-various-textobjs")
		end,
	},
	-- incremental-selection
	{
		"mfussenegger/nvim-treehopper",
		event = "VeryLazy",
		config = function()
			require("pluginconfig/nvim-treehopper")
		end,
	},

	-- Treesitter UI customize
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		config = function()
			-- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
			vim.cmd.edit({ bang = true })
		end,
	},
	-- ↓flutter-toolsのと競合する
	-- { "haringsrob/nvim_context_vt", event = "VeryLazy" },
	{
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		-- event = { "BufRead", "BufNewFile", "InsertEnter" },
		config = function()
			require("pluginconfig.hlargs")
		end,
	},
	{
		"romgrk/nvim-treesitter-context",
		cmd = { "TSContextEnable" },
		config = function()
			require("treesitter-context").setup({})
		end,
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
		-- enabled = function()
		-- 	return not vim.g.vscode
		-- end,
		cond = function()
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
		event = "VeryLazy",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.vim-illuminate")
		end,
	},
	-- {
	-- 	"xiyaowong/nvim-cursorword",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("pluginconfig.nvim-cursorword")
	-- 	end,
	-- },
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.todo-comments")
		end,
	},
	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.modes")
		end,
	},

	--------------------------------
	-- Sidebar
	-- conflict with clever-f (augroup sidebar_nvim_prevent_buffer_override)
	{
		"GustavoKatel/sidebar.nvim",
		event = "VeryLazy",
		cond = function()
			return not vim.g.vscode
		end,
		cmd = { "SidebarNvimToggle" },
		config = function()
			require("pluginconfig.sidebar")
		end,
	},

	--------------------------------
	-- Window Separators
	{
		"nvim-zh/colorful-winsep.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig/colorful-winsep")
		end,
	},

	--------------------------------
	-- Snippet
	{
		"L3MON4D3/LuaSnip",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.LuaSnip")
		end,
	},

	-- formatter
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.null-ls")
		end,
	},

	-- comment out
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.Comment")
		end,
	},

	-- bracket
	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	--------------------------------
	-- Startup screen
	{
		"goolord/alpha-nvim",
		event = "BufEnter",
		cond = function()
			return not vim.g.vscode
		end,
		config = function()
			require("pluginconfig.alpha-nvim")
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons", "ColaMint/pokemon.nvim" } },
	},

	--------------------------------
	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		event = "VimEnter",
		cond = function()
			return not vim.g.vscode
		end,
		config = function()
			require("pluginconfig.nvim-scrollbar")
		end,
		dependencies = { { "kevinhwang91/nvim-hlslens" } },
	},

	--------------------------------
	-- Move
	{
		"phaazon/hop.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.hop")
		end,
	},

	----------------
	-- Horizontal Move
	{
		"jinh0/eyeliner.nvim",
		event = "VeryLazy",
		config = function()
			require("eyeliner").setup({})
		end,
	},
	{
		"ggandor/lightspeed.nvim",
		event = "VeryLazy",
		init = function()
			vim.g.lightspeed_no_default_keymaps = true
		end,
		config = function()
			require("/pluginconfig/lightspeed")
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
	{
		"simeji/winresizer",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.winresizer")
		end,
	},

	--------------------------------
	-- Session
	-- do not use the session per current directory
	{
		"jedrzejboczar/possession.nvim",
		event = "BufEnter",
		cond = function()
			return not vim.g.vscode
		end,
		config = function()
			require("pluginconfig.possession")
		end,
	},

	--------------------------------
	-- Manual
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.which-key")
		end,
	},

	--------------------------------
	-- Commandline
	{
		"folke/noice.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.noice")
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
	-- Buffer
	{
		"famiu/bufdelete.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.bufdelete")
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
		event = "BufWinEnter",
		config = function()
			require("pluginconfig.project")
		end,
	},
	{
		"klen/nvim-config-local",
		event = "BufEnter",
		config = function()
			require("pluginconfig/nvim-config-local")
		end,
	},

	--------------------------------
	-- cursorline
	-- {
	-- 	"delphinus/auto-cursorline.nvim",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("auto-cursorline").setup({})
	-- 	end,
	-- },

	--------------------------------
	-- Git
	{
		"NeogitOrg/neogit",
		-- event = "BufReadPre",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.neogit")
		end,
	},
	{
		"akinsho/git-conflict.nvim",
		event = "VeryLazy",
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
		event = "VeryLazy",
		config = function()
			require("pluginconfig.diffview")
		end,
	},

	--------------------------------
	-- Translate
	{
		"uga-rosa/translate.nvim",
		event = "VeryLazy",
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
	-- Markdown
	{
		"previm/previm",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.previm")
		end,
		dependencies = { "tyru/open-browser.vim" },
	},
	{ "iamcco/markdown-preview.nvim", ft = { "markdown" }, build = ":call mkdp#util#install()" }, --- Used in telekasten.nvim
	{ "mzlogin/vim-markdown-toc" },

	--- Debugging
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = {
			{
				"mfussenegger/nvim-dap",
				config = function()
					require("pluginconfig.nvim-dap")
				end,
			},
			{ "nvim-neotest/nvim-nio" },
		},
		config = function()
			require("pluginconfig.nvim-dap-ui")
		end,
	},

	--------------------------------
	-- OpenAI
	{
		"jackMort/ChatGPT.nvim",
		cmd = { "ChatGPT", "ChatGPTActAs" },
		config = function()
			require("chatgpt").setup({
				-- optional configuration
			})
		end,
	},

	--------------------------------
	-- AI completion
	{
		"zbirenbaum/copilot.lua",
		-- cmd = { "Copilot" },
		event = "InsertEnter",
		config = function()
			vim.defer_fn(function()
				require("pluginconfig.copilot")
			end, 100)
		end,
	},

	--------------------------------
	-- Coding
	--- Writing assistant
	{
		"rareitems/put_at_end.nvim",
		event = { "BufNewFile", "BufReadPre" },
		config = function()
			require("pluginconfig.put_at_end")
		end,
	},

	--------------------------------
	-- Popup Info
	{
		"lewis6991/hover.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.hover")
		end,
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
	{
		"renerocksai/telekasten.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.telekasten")
		end,
		dependencies = { "renerocksai/calendar-vim" },
	},

	-- neorg
	{
		"nvim-neorg/neorg",
		event = "VeryLazy",
		build = ":Neorg sync-parsers",
		-- ft = { "norg" },
		config = function()
			require("pluginconfig.neorg")
		end,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
	},
	-- {
	-- 	"nvim-neorg/neorg",
	-- 	event = "VimEnter",
	-- 	build = ":Neorg sync-parsers",
	-- 	opts = {
	-- 		load = {
	-- 			["core.defaults"] = {},
	-- 			["core.norg.dirman"] = {
	-- 				config = {
	-- 					workspaces = {
	-- 						work = "~/neorg/work",
	-- 					},
	-- 				},
	-- 			},
	-- 			-- ["core.integrations.telescope"] = {},
	-- 			["core.norg.concealer"] = {
	-- 				config = {
	-- 					icon_preset = "diamond",
	-- 				},
	-- 			},
	-- 			["core.norg.completion"] = {
	-- 				config = {
	-- 					engine = "nvim-cmp",
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- 	dependencies = { { "nvim-lua/plenary.nvim" } },
	-- },

	--------------------------------
	{ "folke/neodev.nvim" },
}

require("lazy").setup(vim.tbl_deep_extend("force", plugins, local_plugins), {
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
	},
})
