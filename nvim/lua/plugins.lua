local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
	vim.api.nvim_command("silent !git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
	-- プラグインを書く
	use("wbthomason/packer.nvim")

	--------------------------------
	-- Lua Library
	use({ "nvim-lua/popup.nvim", module = "popup" })
	use({ "nvim-lua/plenary.nvim" }) -- do not lazy load
	-- use({ "kkharji/sqlite.lua", module = "sqlite" })
	use({ "MunifTanjim/nui.nvim", module = "nui" })

	--------------------------------
	-- Notify
	use({ "rcarriga/nvim-notify", module = "notify" })

	-- color scheme
	local colorscheme = "nightfox.nvim"
	use("EdenEast/nightfox.nvim")
	use("cocopon/pgmnt.vim")

	-- font
	use({
		"kyazdani42/nvim-web-devicons",
		after = colorscheme,
		config = function()
			require("pluginconfig.nvim-web-devicons")
		end,
	})

	-- status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("pluginconfig.lualine")
		end,
	})
	-- use({
	-- 	"SmiteshP/nvim-navic",
	-- 	requires = { "neovim/nvim-lspconfig" },
	-- 	module = "nvim-navic",
	-- 	setup = function()
	-- 		require("pluginconfig.nvim-navic")
	-- 	end,
	-- })

	--------------------------------
	-- Bufferline
	if not vim.g.vscode then
		use({
			"akinsho/bufferline.nvim",
			tag = "v2.*",
			requires = { "kyazdani42/nvim-web-devicons" },
			after = colorscheme,
			config = function()
				require("pluginconfig.bufferline")
			end,
		})
	end

	--------------------------------------------------------------
	-- FuzzyFinders
	--------------------------------
	-- telescope.nvim
	use({
		"nvim-telescope/telescope.nvim",
		-- requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
		requires = {
			"tami5/sqlite.lua",
			"nvim-telescope/telescope-frecency.nvim",
			"nvim-telescope/telescope-packer.nvim",
			"delphinus/telescope-memo.nvim",
			"benfowler/telescope-luasnip.nvim",
		},
		after = { colorscheme },
		-- event = "VimEnter",
		config = function()
			require("pluginconfig.telescope")
		end,
	})

	--------------------------------
	-- file finder
	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "main",
		requires = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("pluginconfig.neo-tree")
		end,
	})

	--------------------------------
	-- Snippet
	use({
		"L3MON4D3/LuaSnip",
		event = "VimEnter",
		config = function()
			require("pluginconfig.LuaSnip")
		end,
	})

	--------------------------------
	-- Auto Completion
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
		},
		after = { "LuaSnip", "nvim-autopairs" },
		config = function()
			require("pluginconfig/nvim-cmp")
		end,
	})
	use({
		"onsails/lspkind.nvim",
		module = "lspkind",
		config = function()
			require("pluginconfig.lspkind")
		end,
	})
	use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" })
	use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
	-- use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
	use({ "f3fora/cmp-spell", after = "nvim-cmp" })
	use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
	use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
	use({
		"vim-skk/skkeleton",
		requires = { "vim-denops/denops.vim" },
		config = function()
			require("pluginconfig.skkeleton")
		end,
		setup = function()
			require("pluginstart.skkeleton")
		end,
	})
	-- use({ "rinx/cmp-skkeleton", after = { "nvim-cmp", "skkeleton" }, event = { "InsertEnter" } })
	use({ "rinx/cmp-skkeleton", after = { "nvim-cmp", "skkeleton" } })
	use({
		"delphinus/skkeleton_indicator.nvim",
		config = function()
			require("pluginconfig.skkeleton_indicator")
		end,
	})

	--------------------------------
	-- lsp
	use("neovim/nvim-lspconfig")
	use({
		"williamboman/mason.nvim",
		event = "VimEnter",
		config = function()
			require("mason").setup({})
		end,
	})
	use({
		"williamboman/mason-lspconfig.nvim",
		after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp", "nlsp-settings.nvim" },
		config = function()
			require("pluginconfig.mason-lspconfig")
		end,
	})
	use({
		"tamago324/nlsp-settings.nvim",
		after = { "nvim-lspconfig" },
		config = function()
			require("pluginconfig.nlsp-settings")
		end,
	})

	-- lsp ui
	use({
		"glepnir/lspsaga.nvim",
		event = "VimEnter",
		after = "mason.nvim",
		config = function()
			require("pluginconfig.lspsaga")
		end,
	})
	use({
		"folke/lsp-colors.nvim",
		module = "lsp-colors",
	})
	use({
		"folke/trouble.nvim",
		after = { "mason.nvim" },
		config = function()
			require("pluginconfig.trouble")
		end,
	})
	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})

	-- comment out
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		after = { colorscheme },
		run = ":TSUpdate",
		config = function()
			require("pluginconfig/nvim-treesitter")
		end,
	})
	use({ "yioneko/nvim-yati", after = "nvim-treesitter" })
	use("nvim-treesitter/nvim-treesitter-context")
	use({ "JoosepAlviste/nvim-ts-context-commentstring", after = { "nvim-treesitter" } })
	-- use({ "haringsrob/nvim_context_vt", after = { "nvim-treesitter", colorscheme } })
	use({
		"m-demare/hlargs.nvim",
		after = { "nvim-treesitter" },
		config = function()
			require("pluginconfig.hlargs")
		end,
	})

	-- formatter
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		after = { "mason.nvim" },
		config = function()
			require("pluginconfig/null-ls")
		end,
	})

	-- bracket
	use({
		"windwp/nvim-autopairs",
		event = "VimEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})

	-- highlight
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	})
	use({
		"RRethy/vim-illuminate",
		event = "VimEnter",
		config = function()
			require("pluginconfig.vim-illuminate")
		end,
	})
	use({
		"norcalli/nvim-colorizer.lua",
		event = "VimEnter",
		config = function()
			require("colorizer").setup()
		end,
	})
	use({
		"folke/todo-comments.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.todo-comments")
		end,
	})
	use({
		"mvllow/modes.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.modes")
		end,
	})

	--------------------------------
	-- Sidebar
	-- conflict with clever-f (augroup sidebar_nvim_prevent_buffer_override)
	use({
		"GustavoKatel/sidebar.nvim",
		cmd = { "SidebarNvimToggle" },
		config = function()
			require("pluginconfig.sidebar")
		end,
	})

	--------------------------------
	-- Scrollbar
	use({
		"petertriho/nvim-scrollbar",
		requires = { { "kevinhwang91/nvim-hlslens", opt = true } },
		after = { colorscheme, "nvim-hlslens" },
		config = function()
			require("pluginconfig.nvim-scrollbar")
		end,
	})

	--------------------------------
	-- Move
	use({
		"phaazon/hop.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.hop")
		end,
	})

	--------------------------------
	-- Window
	use({
		"kwkarlwang/bufresize.nvim",
		event = "WinNew",
		config = function()
			require("pluginconfig.bufresize")
		end,
	})

	--------------------------------
	-- Terminal
	use({
		"akinsho/toggleterm.nvim",
		-- after = { colorscheme },
		event = "VimEnter",
		config = function()
			require("pluginconfig.toggleterm")
		end,
	})

	--------------------------------
	-- Reading assistant
	use({
		"lukas-reineke/indent-blankline.nvim",
		-- after = { colorscheme },
		event = "VimEnter",
		config = function()
			require("pluginconfig.indent-blankline")
		end,
	})

	--------------------------------
	-- Project
	use({
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.project")
		end,
	})

	--------------------------------
	-- Git
	use({
		"TimUntersberger/neogit",
		event = "VimEnter",
		config = function()
			require("pluginconfig.neogit")
		end,
	})
	use({
		"akinsho/git-conflict.nvim",
		event = "VimEnter",
		config = function()
			require("git-conflict").setup()
		end,
	})
	use({ "yutkat/convert-git-url.nvim", cmd = { "ConvertGitUrl" } })
	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		event = "VimEnter",
		config = function()
			require("pluginconfig.gitsigns")
		end,
	})
	use({
		"sindrets/diffview.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.diffview")
		end,
	})

	--------------------------------
	-- Translate
	use({
		"uga-rosa/translate.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.translate")
		end,
	})

	--------------------------------
	-- language
	--- flutter
	use({
		"akinsho/flutter-tools.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("pluginconfig.flutter-tools")
		end,
	})

	--------------------------------
	-- tools
	--- memo
	use({
		"glidenote/memolist.vim",
		config = function()
			require("pluginconfig.memolist")
		end,
	})

	-- neorg
	use({
		"nvim-neorg/neorg",
		requires = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		after = { "nvim-treesitter" },
		run = ":Neorg sync-parsers",
		config = function()
			require("pluginconfig.neorg")
		end,
	})

	-- packer bootstrap
	if packer_bootstrap then
		require("packer").sync()
	end
end)

vim.cmd([[autocmd BufWritePost init.lua source <afile> | PackerCompile]])
