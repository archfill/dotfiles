-- ================================================================
-- EDITOR: Completion System - Priority 500
-- ================================================================

return {
  -- blink.cmp: Modern Rust-based completion plugin for better performance
  {
    "saghen/blink.cmp",
    version = "1.*", -- use release version for stability
    priority = 500,
    event = { "InsertEnter", "CmdlineEnter" },
    lazy = true,
    dependencies = {
      "rafamadriz/friendly-snippets", -- snippets collection
      "saghen/blink.compat", -- nvim-cmp compatibility layer
      "rinx/cmp-skkeleton", -- SKK input source
    },
    opts = function()
      return {
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
          nerd_font_variant = "mono",
          highlight_ns = vim.api.nvim_create_namespace("blink_cmp_enhanced"),
          use_nvim_cmp_as_default = false,
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
          keyword = { range = "full" },
          trigger = {
            show_on_keyword = true,
            show_on_trigger_character = true,
            show_on_blocked_trigger_characters = { " " },
            show_on_insert_on_trigger_character = true,
            show_on_accept_on_trigger_character = true,
          },
          accept = {
            auto_brackets = { enabled = true },
          },
          list = {
            selection = {
              preselect = function(ctx)
                return vim.bo.filetype ~= "markdown"
              end,
              auto_insert = true,
            },
            max_items = 50,
            cycle = { from_top = false },
          },
          menu = {
            auto_show = true,
            border = "single",
            draw = {
              padding = { 0, 1 },
              columns = {
                { "label", "label_description", gap = 1 },
                { "kind_icon", "kind" },
              },
            },
          },
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
          ghost_text = {
            enabled = true,
            show_with_selection = true,
            show_without_selection = false,
            show_with_menu = false,
            show_without_menu = true,
          },
        },

        -- completion sources with filetype specialization
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "skkeleton" },
          per_filetype = {
            lua = { "lsp", "snippets", "buffer", "path" },
            markdown = { "lsp", "path", "snippets", "buffer" },
            gitcommit = { "buffer" },
            typescript = { "lsp", "snippets", "path", "buffer" },
            typescriptreact = { "lsp", "snippets", "path", "buffer" },
            javascript = { "lsp", "snippets", "path", "buffer" },
            javascriptreact = { "lsp", "snippets", "path", "buffer" },
            python = { "lsp", "snippets", "path", "buffer" },
            json = { "lsp", "snippets", "path" },
            yaml = { "lsp", "snippets", "path" },
            sh = { "lsp", "snippets", "path", "buffer" },
            bash = { "lsp", "snippets", "path", "buffer" },
            zsh = { "lsp", "snippets", "path", "buffer" },
          },
          providers = {
            lsp = {
              fallbacks = { "buffer" },
              score_offset = 5,
              transform_items = function(_, items)
                return vim.tbl_filter(function(item)
                  return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
                end, items)
              end,
            },
            buffer = {
              score_offset = -3,
            },
            path = {
              score_offset = 3,
              fallbacks = { "buffer" },
            },
            snippets = {
              score_offset = 1,
            },
            skkeleton = {
              name = 'skkeleton',
              module = 'blink.compat.source',
              score_offset = 15,
              opts = {},
            },
          },
        },

        -- Enhanced cmdline completion with ghost text
        cmdline = {
          enabled = true,
          keymap = {
            preset = "cmdline",
            ["<Tab>"] = { "show", "accept" },
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            if type == "/" or type == "?" then
              return { "buffer" }
            end
            if type == ":" or type == "@" then
              return { "cmdline" }
            end
            return {}
          end,
          completion = {
            menu = { auto_show = true },
            ghost_text = { enabled = true },
          },
        },

        -- snippets configuration - use default preset (friendly-snippets)
        snippets = { 
          preset = "default",
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
          max_typos = function(keyword)
            return math.floor(#keyword / 4)
          end,
          use_frecency = true,
          use_proximity = true,
          sorts = {
            "exact",
            "score",
            "sort_text",
          },
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
      }
    end,
  },
}