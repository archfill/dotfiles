-- ================================================================
-- LSP: Trouble.nvim - Diagnostics & References Display
-- ================================================================

return {
  -- Trouble: LSP診断・参照・quickfix統合表示
  {
    "folke/trouble.nvim",
    keys = {
      -- ===== CORE TROUBLE OPERATIONS =====
      { "<leader>xx", "<cmd>Trouble<cr>", desc = "Trouble" },
      { "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", desc = "Document Diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist<cr>", desc = "Location List" },
      { "<leader>xq", "<cmd>Trouble quickfix<cr>", desc = "Quickfix" },
      
      -- ===== LSP INTEGRATION =====
      { "gR", "<cmd>Trouble lsp_references<cr>", desc = "LSP References" },
    },
    cmd = { "Trouble" },
    opts = {
      mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      win = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Trouble",
        title_pos = "center",
        position = { 0.5, 0.5 },
        size = { width = 0.8, height = 0.8 },
        zindex = 200,
      },
      icons = {
        indent = {
          fold_open = "",
          fold_closed = "",
        },
        folder_closed = "",
        folder_open = "",
      },
      group = true, -- group results by file
      padding = true, -- add an extra new line on top of the list
      action_keys = { -- key mappings for actions in the trouble list
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = { "o" }, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = { "zM", "zm" }, -- close all folds
        open_folds = { "zR", "zr" }, -- open all folds
        toggle_fold = { "zA", "za" }, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j", -- next item
      },
      indent_lines = true, -- add an indent guide below the fold icons
      auto_open = false, -- automatically open the list when you have diagnostics
      auto_close = false, -- automatically close the list when you have no diagnostics
      auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
      auto_fold = false, -- automatically fold a file trouble list at creation
      auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
      signs = {
        -- icons / text used for a diagnostic
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "﫠",
      },
      use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
    },
  },
}