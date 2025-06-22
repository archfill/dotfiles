-- blink.cmp configuration - modern Rust-based completion plugin
-- High-performance replacement for nvim-cmp

local blink = require("blink.cmp")

blink.setup({
	-- keymap preset - 'default' provides C-y accept, similar to built-in completion
	keymap = { preset = "default" },

	-- appearance configuration
	appearance = {
		-- use 'mono' for 'Nerd Font Mono' to ensure proper icon alignment
		nerd_font_variant = "mono",
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

	-- completion behavior
	completion = {
		-- keyword matching - 'prefix' matches text before cursor only
		keyword = { range = "prefix" },

		-- trigger behavior
		trigger = {
			show_on_keyword = true,
			show_on_trigger_character = true,
			-- block trigger characters that cause too frequent popup
			show_on_blocked_trigger_characters = { " ", "\n", "\t" },
		},

		-- list behavior
		list = {
			selection = {
				-- don't preselect first item automatically
				preselect = false,
				-- don't auto-insert on selection (manual confirm with C-y)
				auto_insert = false,
			},
		},

		-- menu appearance
		menu = {
			auto_show = true,
			-- nvim-cmp style column layout
			draw = {
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", "kind" },
				},
			},
		},

		-- documentation window (manual trigger only)
		documentation = { auto_show = false },

		-- disable ghost text for now
		ghost_text = { enabled = false },
	},

	-- completion sources
	sources = {
		-- default sources for most filetypes
		default = { "lsp", "path", "snippets", "buffer" },

		-- filetype-specific source configuration
		per_filetype = {
			gitcommit = { "lsp", "path", "snippets", "buffer" },
			markdown = { "lsp", "path", "snippets", "buffer" },
			-- disable aggressive completion for certain filetypes
			-- lua = { inherit_defaults = true },
		},

		-- provider configurations
		providers = {
			-- LSP provider with buffer fallback
			lsp = {
				fallbacks = { "buffer" },
				-- filter text items since buffer provider handles those
				transform_items = function(_, items)
					return vim.tbl_filter(function(item)
						return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
					end, items)
				end,
			},
			-- buffer provider with lower priority
			buffer = {
				score_offset = -3,
			},
			-- path provider with higher priority
			path = {
				score_offset = 3,
				fallbacks = { "buffer" },
			},
		},
	},

	-- cmdline completion (search and commands)
	cmdline = {
		enabled = true,
		keymap = { preset = "cmdline" },
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
		},
	},

	-- snippets configuration - use default preset (friendly-snippets)
	snippets = { preset = "default" },

	-- fuzzy matching with Rust implementation for performance
	fuzzy = {
		implementation = "prefer_rust_with_warning",
		-- allow some typos for better UX
		max_typos = function(keyword)
			return math.floor(#keyword / 4)
		end,
		use_frecency = true,
		use_proximity = true,
	},

	-- signature help (experimental)
	signature = { enabled = false },
})