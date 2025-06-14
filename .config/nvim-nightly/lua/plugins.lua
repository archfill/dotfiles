-- ===== NEOVIM NIGHTLY VERSION CONFIGURATION =====
-- このファイルはNeovim Nightly版専用の設定です
-- 実験的なプラグインや新機能のテストを含みます
--
-- Stable版との主な違い:
-- - AI補完プラグイン (supermaven-nvim)
-- - 検索ハイライト強化 (nvim-hlslens) 
-- - ファイルナビゲーション強化 (harpoon)
--
-- ==================================================

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
			require("pluginconfig.editor.nvim-treesitter")
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
			require("pluginconfig.editor.nvim-various-textobjs")
		end,
	},
	-- incremental-selection
	{
		"mfussenegger/nvim-treehopper",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.nvim-treehopper")
		end,
	},

	-- Treesitter UI customize
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "BufReadPost",
		config = function()
			-- No additional configuration needed, plugin works out of the box
		end,
	},
	-- ↓flutter-toolsのと競合する
	-- { "haringsrob/nvim_context_vt", event = "VeryLazy" },
	{
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		-- event = { "BufRead", "BufNewFile", "InsertEnter" },
		config = function()
			require("pluginconfig.editor.hlargs")
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
			require("pluginconfig.ui.lualine")
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
			require("pluginconfig.ui.bufferline")
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
			require("pluginconfig.editor.vim-illuminate")
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.todo-comments")
		end,
	},
	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.modes")
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
			require("pluginconfig.ui.sidebar")
		end,
	},

	--------------------------------
	-- Window Separators
	{
		"nvim-zh/colorful-winsep.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.ui.colorful-winsep")
		end,
	},

	--------------------------------
	-- Snippet
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			require("pluginconfig.editor.LuaSnip")
		end,
	},

	-- formatting
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("pluginconfig.lsp.conform")
		end,
	},

	-- linting  
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("pluginconfig.lsp.nvim-lint")
		end,
	},

	-- comment out
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.Comment")
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
			require("pluginconfig.ui.alpha-nvim")
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
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
			require("pluginconfig.ui.nvim-scrollbar")
		end,
		dependencies = { { "kevinhwang91/nvim-hlslens" } },
	},

	--------------------------------
	-- Move
	{
		"phaazon/hop.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.hop")
		end,
	},


	--------------------------------
	-- Window
	{
		"simeji/winresizer",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.winresizer")
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
			require("pluginconfig.editor.possession")
		end,
	},

	--------------------------------
	-- Manual
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.which-key")
		end,
	},

	--------------------------------
	-- Commandline
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.ui.noice")
		end,
	},

	--------------------------------
	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.editor.toggleterm")
		end,
	},

	--------------------------------
	-- Reading assistant
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.editor.indent-blankline")
		end,
	},

	--------------------------------
	-- Buffer
	{
		"famiu/bufdelete.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.editor.bufdelete")
		end,
	},

	--------------------------------
	-- file finder
	{
		"nvim-neo-tree/neo-tree.nvim",
		event = "VimEnter",
		branch = "main",
		config = function()
			require("pluginconfig.tools.neo-tree")
		end,
	},

	--------------------------------
	-- Project
	{
		"ahmedkhalf/project.nvim",
		event = "BufWinEnter",
		config = function()
			require("pluginconfig.tools.project")
		end,
	},
	{
		"klen/nvim-config-local",
		event = "BufEnter",
		config = function()
			require("pluginconfig.tools.nvim-config-local")
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
			require("pluginconfig.tools.neogit")
		end,
	},
	{
		"akinsho/git-conflict.nvim",
		event = "VeryLazy",
		config = function()
			require("git-conflict").setup()
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.tools.gitsigns")
		end,
	},
	{
		"sindrets/diffview.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.tools.diffview")
		end,
	},

	--------------------------------
	-- Translate
	{
		"uga-rosa/translate.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.language.translate")
		end,
	},

	--------------------------------
	-- language
	--- flutter
	{
		"akinsho/flutter-tools.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.language.flutter-tools")
		end,
	},

	--------------------------------
	-- Markdown
	{
		"previm/previm",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.language.previm")
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
					require("pluginconfig.lsp.nvim-dap")
				end,
			},
			{ "nvim-neotest/nvim-nio" },
		},
		config = function()
			require("pluginconfig.lsp.nvim-dap-ui")
		end,
	},


	--------------------------------
	-- AI completion

	--------------------------------
	-- Coding

	--------------------------------
	-- Popup Info
	{
		"lewis6991/hover.nvim",
		event = "VeryLazy",
		config = function()
			require("pluginconfig.editor.hover")
		end,
	},

	--------------------------------
	-- tools
	--- memo
	{
		"renerocksai/telekasten.nvim",
		event = "VimEnter",
		config = function()
			require("pluginconfig.tools.telekasten")
		end,
		dependencies = { "renerocksai/calendar-vim" },
	},

	-- ===== NIGHTLY版専用: 実験的プラグイン =====
	{
		-- AI コード補完（実験的）
		"supermaven-inc/supermaven-nvim",
		event = "VeryLazy",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = {}, 
				color = {
					suggestion_color = "#ffffff",
					cterm = 244,
				},
				log_level = "info",
				disable_inline_completion = false,
				disable_keymaps = false
			})
		end,
	},
	{
		-- バッファ内検索の強化（実験的）
		"kevinhwang91/nvim-hlslens",
		event = "VeryLazy",
		config = function()
			require('hlslens').setup()
		end,
	},
	{
		-- ファイル内関数・変数ジャンプの強化
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
			
			vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
			vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
			vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end)
			vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end)
			vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end)
			vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end)
		end,
	},

	--------------------------------
	{ "folke/neodev.nvim" },
}

require("lazy").setup(vim.tbl_deep_extend("force", plugins, local_plugins), {
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
	},
})
