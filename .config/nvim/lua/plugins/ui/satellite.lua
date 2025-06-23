-- ================================================================
-- UI: Satellite.nvim - Decorated Scrollbar - Priority 700
-- ================================================================
-- Modern scrollbar with cursor, search, diagnostics, and git visualization
-- Unified design with existing floating window system

return {
  {
    "lewis6991/satellite.nvim",
    priority = 700, -- UI category priority
    lazy = false, -- UI category requires priority-based loading
    opts = {
      -- ================================================================
      -- UNIFIED FLOATING DESIGN INTEGRATION
      -- ================================================================
      -- Transparency matching telescope.nvim and snacks.nvim
      winblend = 5, -- Subtle transparency for modern floating feel
      
      -- Visual configuration
      current_only = false, -- Show scrollbars for all windows
      width = 2, -- Scrollbar width (thin but visible)
      
      -- ================================================================
      -- HANDLERS: Enhanced Visual Information
      -- ================================================================
      handlers = {
        -- Cursor position indicator
        cursor = {
          enabled = true,
          symbols = { '⎺', '⎻', '⎼', '⎽' }, -- Clean cursor indicators
          overlap = true,
        },
        
        -- Search results highlighting
        search = {
          enabled = true,
          symbols = { '━', '━', '━', '━' }, -- Bold search indicators
          overlap = true,
        },
        
        -- Diagnostic information (errors, warnings, etc.)
        diagnostic = {
          enabled = true,
          signs = { '-', '=', '≡' }, -- Clean diagnostic indicators
          min_severity = vim.diagnostic.severity.HINT,
          overlap = true,
        },
        
        -- Git hunks (requires gitsigns.nvim) - Simplified
        gitsigns = {
          enabled = true,
          overlap = false,
        },
        
        -- Marks visualization - Simplified
        marks = {
          enabled = false, -- Disable for performance
        },
        
        -- Quickfix and location list - Simplified
        quickfix = {
          enabled = true,
          overlap = true,
        }
      },
      
      -- ================================================================
      -- EXCLUDED FILE TYPES (Performance optimization)
      -- ================================================================
      excluded_filetypes = {
        "prompt",
        "TelescopePrompt",
        "TelescopeResults", 
        "TelescopePreview",
        "noice",
        "notify",
        "neo-tree",
        "dashboard", 
        "alpha",
        "startify",
        "lazy",
        "mason",
        "help",
        "trouble",
        "lspinfo",
        "man",
        "gitcommit",
        "gitrebase",
        "lspsagafinder",
        "",
      },
      
      -- ================================================================
      -- MOUSE INTERACTION
      -- ================================================================
      -- Enable mouse click to jump to positions
      mouse = {
        enabled = true,
      },
      
      -- ================================================================
      -- INTEGRATION SETTINGS
      -- ================================================================
      -- Fold information display
      folds = {
        enabled = true,
        symbols = { '▞', '▚' }, -- Fold indicators
        overlap = false,
      },
    },
    
    -- ================================================================
    -- INITIALIZATION AND COMMANDS
    -- ================================================================
    config = function(_, opts)
      -- Setup satellite with options
      require("satellite").setup(opts)
      
      -- Success notification
      vim.notify("📊 Satellite scrollbar ready!", vim.log.levels.INFO)
    end,
    
    -- ================================================================
    -- DEPENDENCIES
    -- ================================================================
    dependencies = {
      -- Optional integration with gitsigns
      { "lewis6991/gitsigns.nvim", optional = true },
    },
  },
}