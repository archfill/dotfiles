-- ================================================================
-- UI: Statusline and UI Elements - Priority 800
-- ================================================================

return {
  -- 🎨 Beautiful Modern Statusline with Catppuccin
  {
    "nvim-lualine/lualine.nvim",
    priority = 800,
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin", -- 美しいCatppuccinテーマ
        component_separators = { left = "", right = "" }, -- Modern separators
        section_separators = { left = "", right = "" },   -- Elegant rounded
        disabled_filetypes = {
          statusline = { "dashboard", "alpha", "starter" },
          winbar = { "dashboard", "alpha", "starter" },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true, -- Modern global statusline
        refresh = {
          statusline = 100,  -- More responsive
          tabline = 100,
          winbar = 100,
        }
      },
      sections = {
        -- Left side: Mode + Git info
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return str:sub(1,1) -- Single character mode
            end,
            color = { gui = "bold" },
          }
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { gui = "bold" },
          },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed
                }
              end
            end,
          }
        },
        -- Center: Filename + Diagnostics
        lualine_c = {
          {
            "filename",
            file_status = true,
            newfile_status = false,
            path = 1, -- Relative path
            symbols = {
              modified = " ●",
              readonly = " ",
              unnamed = "[No Name]",
              newfile = " [New]",
            },
            color = function()
              return vim.bo.modified and { fg = "#f9e2af" } or { fg = "#cdd6f4" }
            end,
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic", "nvim_lsp" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            diagnostics_color = {
              error = { fg = "#f38ba8" },
              warn = { fg = "#fab387" },
              info = { fg = "#89b4fa" },
              hint = { fg = "#a6e3a1" },
            },
            update_in_insert = false,
          }
        },
        -- Right side: LSP + File info + Progress
        lualine_x = {
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if next(clients) == nil then
                return ""
              end
              local client_names = {}
              for _, client in pairs(clients) do
                table.insert(client_names, client.name)
              end
              return " " .. table.concat(client_names, ", ")
            end,
            color = { fg = "#a6e3a1", gui = "bold" },
          },
          {
            "encoding",
            color = { fg = "#cdd6f4" },
            cond = function() return vim.o.encoding ~= "utf-8" end,
          },
          {
            "fileformat",
            symbols = {
              unix = " LF",
              dos = " CRLF",
              mac = " CR",
            },
            color = { fg = "#cdd6f4" },
            cond = function() return vim.bo.fileformat ~= "unix" end,
          },
          {
            "filetype",
            colored = true,
            icon_only = false,
            color = { fg = "#f2cdcd" },
          }
        },
        lualine_y = {
          {
            "progress",
            color = { fg = "#89b4fa", gui = "bold" },
          }
        },
        lualine_z = {
          {
            "location",
            color = { fg = "#cdd6f4", gui = "bold" },
          },
          {
            function()
              return " " .. os.date("%H:%M")
            end,
            color = { fg = "#f5c2e7" },
          }
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1,
            color = { fg = "#6c7086" }, -- Surface2 for inactive
          }
        },
        lualine_x = {
          {
            "location",
            color = { fg = "#6c7086" },
          }
        },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {
        "neo-tree",
        "lazy",
        "mason",
        "trouble",
        "quickfix",
        "man",
        "fugitive"
      }
    },
  },

  -- Modern UI for messages, cmdline, and popupmenu
  {
    "folke/noice.nvim",
    priority = 750,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim", -- Using snacks.notifier instead of nvim-notify
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- 検索を中央表示にするため無効化
        command_palette = false, -- コマンドパレットを中央表示にするため無効化
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      cmdline = {
        enabled = true,
        view = "cmdline_popup", -- 中央ポップアップ表示
        opts = {},
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          input = {},
        },
      },
      notify = {
        enabled = false, -- Use snacks.notifier instead
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
    },
  },
}