-- blink.cmp configuration - modern Rust-based completion plugin
-- High-performance replacement for nvim-cmp

local blink = require("blink.cmp")

blink.setup({
	-- keymap preset - 'super-tab' for enhanced tab-based workflow
	keymap = {
		preset = "super-tab",
		-- Custom enhanced keymaps for better UX
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<C-d>"] = { "scroll_documentation_down", "fallback" },
		["<C-u>"] = { "scroll_documentation_up", "fallback" },
		["<C-l>"] = { "accept", "fallback" },
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		-- Enhanced Tab behavior with smart context switching
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			"snippet_forward",
			"fallback",
		},
	},

	-- appearance configuration
	appearance = {
		-- use 'mono' for 'Nerd Font Mono' to ensure proper icon alignment
		nerd_font_variant = "mono",
		-- Enhanced highlight namespace for better theme integration
		highlight_ns = vim.api.nvim_create_namespace("blink_cmp_enhanced"),
		use_nvim_cmp_as_default = false,
		-- kind icons matching current lspkind configuration
		kind_icons = {
			Text = "󰉿",
			Method = "󰊕",
			Function = "󰊕",
			Constructor = "󰒓",
			Field = "󰜢",
			Variable = "󰆦",
			Property = "󰖷",
			Class = "󱡠",
			Interface = "󱡠",
			Struct = "󱡠",
			Module = "󰅩",
			Unit = "󰪚",
			Value = "󰦨",
			Enum = "󰦨",
			EnumMember = "󰦨",
			Keyword = "󰻾",
			Constant = "󰏿",
			Snippet = "󱄽",
			Color = "󰏘",
			File = "󰈔",
			Reference = "󰬲",
			Folder = "󰉋",
			Event = "󱐋",
			Operator = "󰪚",
			TypeParameter = "󰬛",
		},
	},

	-- completion behavior - enhanced for better UX
	completion = {
		-- Enhanced keyword matching - 'full' for better context awareness
		keyword = { range = "full" },

		-- trigger behavior - more intelligent and responsive
		trigger = {
			show_on_keyword = true,
			show_on_trigger_character = true,
			-- Reduced blocked characters for more responsive completion
			show_on_blocked_trigger_characters = { " " },
			-- Enhanced trigger on insert and accept
			show_on_insert_on_trigger_character = true,
			show_on_accept_on_trigger_character = true,
		},

		-- Auto-brackets for better coding experience
		accept = {
			auto_brackets = { enabled = true },
		},

		-- list behavior - optimized for super-tab workflow
		list = {
			selection = {
				-- Smart preselection based on context
				preselect = function(ctx)
					return vim.bo.filetype ~= "markdown"
				end,
				-- Auto-insert for smooth Tab workflow
				auto_insert = true,
			},
			-- Maximum items for performance
			max_items = 50,
			-- Cycle through suggestions smoothly
			cycle = { from_top = false },
		},

		-- Enhanced menu appearance with borders
		menu = {
			auto_show = true,
			border = "single",
			-- Improved column layout with padding
			draw = {
				padding = { 0, 1 },
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", "kind" },
				},
			},
		},

		-- Auto-show documentation for better context
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
			update_delay_ms = 50,
			treesitter_highlighting = true,
			window = {
				min_width = 10,
				max_width = 80,
				max_height = 20,
				border = "single",
				scrollbar = true,
				direction_priority = {
					menu_north = { "e", "w", "n", "s" },
					menu_south = { "e", "w", "s", "n" },
				},
			},
		},

		-- Enable ghost text for better preview
		ghost_text = {
			enabled = true,
			show_with_selection = true,
			show_without_selection = false,
			show_with_menu = false, -- Only when menu is closed
			show_without_menu = true,
		},
	},

	-- completion sources - enhanced with filetype specialization
	sources = {
		-- default sources for most filetypes
		default = { "lsp", "path", "snippets", "buffer" },

		-- Enhanced filetype-specific source configuration
		per_filetype = {
			-- Lua development with enhanced Neovim API support
			lua = { "lsp", "snippets", "buffer", "path" },
			-- Markdown with rich text support
			markdown = { "lsp", "path", "snippets", "buffer" },
			-- Git commit messages (concise completion)
			gitcommit = { "buffer" },
			-- TypeScript/JavaScript enhanced LSP
			typescript = { "lsp", "snippets", "path", "buffer" },
			typescriptreact = { "lsp", "snippets", "path", "buffer" },
			javascript = { "lsp", "snippets", "path", "buffer" },
			javascriptreact = { "lsp", "snippets", "path", "buffer" },
			-- Python development
			python = { "lsp", "snippets", "path", "buffer" },
			-- JSON/YAML configuration files
			json = { "lsp", "snippets", "path" },
			yaml = { "lsp", "snippets", "path" },
			-- Shell scripting
			sh = { "lsp", "snippets", "path", "buffer" },
			bash = { "lsp", "snippets", "path", "buffer" },
			zsh = { "lsp", "snippets", "path", "buffer" },
		},

		-- Enhanced provider configurations
		providers = {
			-- LSP provider with intelligent filtering
			lsp = {
				fallbacks = { "buffer" },
				score_offset = 5, -- Boost LSP items
				transform_items = function(_, items)
					-- Filter text items for better relevance
					return vim.tbl_filter(function(item)
						return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
					end, items)
				end,
			},
			-- Buffer provider with smart context
			buffer = {
				score_offset = -3,
			},
			-- Path provider with enhanced scoring
			path = {
				score_offset = 3,
				fallbacks = { "buffer" },
			},
			-- Snippets with higher priority
			snippets = {
				score_offset = 1,
			},
		},
	},

	-- Enhanced cmdline completion with ghost text
	cmdline = {
		enabled = true,
		keymap = {
			preset = "cmdline",
			-- Enhanced cmdline navigation
			["<Tab>"] = { "show", "accept" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
		},
		sources = function()
			local type = vim.fn.getcmdtype()
			-- search forward/backward
			if type == "/" or type == "?" then
				return { "buffer" }
			end
			-- commands
			if type == ":" or type == "@" then
				return { "cmdline" }
			end
			return {}
		end,
		completion = {
			menu = { auto_show = true },
			-- Enable ghost text for cmdline (shell-like experience)
			ghost_text = { enabled = true },
		},
	},

	-- snippets configuration - use default preset (friendly-snippets)
	snippets = { 
		preset = "default",
		-- Enhanced snippet expansion
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
		active = function(filter)
			return vim.snippet.active(filter)
		end,
		jump = function(direction)
			vim.snippet.jump(direction)
		end,
	},

	-- Enhanced fuzzy matching with Rust implementation
	fuzzy = {
		implementation = "prefer_rust_with_warning",
		-- Smart typo tolerance based on keyword length
		max_typos = function(keyword)
			return math.floor(#keyword / 4)
		end,
		-- Learning-based improvements
		use_frecency = true,
		use_proximity = true,
		-- Enhanced sorting with exact matches prioritized
		sorts = {
			"exact", -- Prioritize exact matches
			"score",
			"sort_text",
		},
		-- Enhanced prebuilt binaries settings
		prebuilt_binaries = {
			download = true,
			ignore_version_mismatch = false,
		},
	},

	-- Enable signature help for better function context
	signature = {
		enabled = true,
		trigger = {
			enabled = true,
			show_on_trigger_character = true,
			show_on_insert_on_trigger_character = true,
		},
		window = {
			min_width = 1,
			max_width = 100,
			max_height = 10,
			border = "single",
			direction_priority = { "n", "s" },
			treesitter_highlighting = true,
			show_documentation = true,
		},
	},
})