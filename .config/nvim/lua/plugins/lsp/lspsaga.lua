-- ================================================================
-- LSP: LSP Saga - Beautiful LSP UI
-- ================================================================

return {
  -- lspsaga: 美しいLSP UI拡張
  {
    "nvimdev/lspsaga.nvim",
    keys = {
      { "gh", "<cmd>Lspsaga finder<cr>", desc = "LSP Finder (Saga)" },
      { "gp", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek Definition (Saga)" },
      { "gP", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek Type Definition (Saga)" },
      { "<leader>o", "<cmd>Lspsaga outline<cr>", desc = "Outline (Saga)" },
      { "<leader>ca", "<cmd>Lspsaga code_action<cr>", desc = "Code Action (Saga)" },
      { "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line Diagnostics (Saga)" },
      { "<leader>cD", "<cmd>Lspsaga show_cursor_diagnostics<cr>", desc = "Cursor Diagnostics (Saga)" },
      { "<leader>cb", "<cmd>Lspsaga show_buf_diagnostics<cr>", desc = "Buffer Diagnostics (Saga)" },
      { "[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous Diagnostic (Saga)" },
      { "]e", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic (Saga)" },
      { "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incoming Calls (Saga)" },
      { "<leader>co", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing Calls (Saga)" },
      { "<leader>rn", "<cmd>Lspsaga rename<cr>", desc = "Rename (Saga)" },
      { "<leader>sl", "<cmd>Lspsaga render_hover_doc<cr>", desc = "Hover Documentation (Saga)" },
      { "<leader>sk", "<cmd>Lspsaga signature_help<cr>", desc = "Signature Help (Saga)" },
      { "<A-d>", "<cmd>Lspsaga term_toggle<cr>", desc = "Toggle Terminal (Saga)" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      ui = {
        border = "single",
        winblend = 10,
        expand = "",
        collapse = "",
        preview = " ",
        code_action = "💡",
        diagnostic = "🐛",
        incoming = " ",
        outgoing = " ",
        hover = " ",
        kind = {},
      },
      hover = {
        max_width = 0.6,
        max_height = 0.8,
        open_link = "gx",
        open_browser = "!chrome",
      },
      diagnostic = {
        on_insert = false,
        on_insert_follow = false,
        insert_winblend = 0,
        show_code_action = true,
        show_source = true,
        jump_num_shortcut = true,
        max_width = 0.7,
        custom_fix = nil,
        custom_msg = nil,
        text_hl_follow = false,
        border_follow = true,
        keys = {
          exec_action = "o",
          quit = "q",
          go_action = "g"
        },
      },
      code_action = {
        num_shortcut = true,
        show_server_name = false,
        extend_gitsigns = true,
        keys = {
          quit = "q",
          exec = "<CR>",
        },
      },
      lightbulb = {
        enable = true,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
      },
      preview = {
        lines_above = 0,
        lines_below = 10,
      },
      scroll_preview = {
        scroll_down = "<C-f>",
        scroll_up = "<C-b>",
      },
      request_timeout = 2000,
    },
  },
}