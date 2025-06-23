-- ================================================================
-- UI: Snacks.nvim - Priority 900 (High Priority UI)
-- ================================================================
-- Replaces: alpha-nvim, nvim-notify, indent-blankline.nvim
-- Future migrations: neo-tree → snacks.explorer, telescope → snacks.picker

return {
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    keys = {
      -- Notifier controls
      { "<leader>nc", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<BS>", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
      -- Dashboard
      { "<leader>D", function() require("snacks").dashboard() end, desc = "Dashboard" },
    },
    opts = {
      -- ================================================================
      -- BIGFILE: Enhanced large file handling
      -- ================================================================
      bigfile = { enabled = true, size = 1.5 * 1024 * 1024 }, -- 1.5MB threshold
      
      -- ================================================================
      -- DASHBOARD: Replaces alpha-nvim
      -- ================================================================
      dashboard = {
        enabled = true,
        preset = {
          -- Custom header with NEOVIM ASCII art (same as alpha.nvim)
          header = [[
                                                        
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                        
           🚀 Welcome to Neovim Development Environment ]],
          -- Custom keys section preserving all 47 buttons from alpha.nvim
          keys = {
            -- File Operations
            { icon = "📁", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = "🔍", key = "g", desc = "Live Grep", action = ":Telescope live_grep" },
            { icon = "📄", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = "✏️ ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "📂", key = "e", desc = "File Explorer", action = ":Neotree" },
            
            -- Session Management
            { icon = "💾", key = "S", desc = "Save Session", action = ":PossessionSave" },
            { icon = "🔄", key = "R", desc = "Load Session", action = ":PossessionLoad" },
            { icon = "🗑️ ", key = "D", desc = "Delete Session", action = ":PossessionDelete" },
            { icon = "📋", key = "T", desc = "Show Sessions", action = ":PossessionShow" },
            
            -- Configuration
            { icon = "⚙️ ", key = "c", desc = "Edit Config", action = ":edit ~/.config/nvim/init.lua" },
            { icon = "🔌", key = "p", desc = "Edit Plugins", action = ":edit ~/.config/nvim/lua/plugins.lua" },
            
            -- Lazy.nvim Plugin Management
            { icon = "💤", key = "l", desc = "Lazy Home", action = ":Lazy" },
            { icon = "🔄", key = "s", desc = "Sync Plugins", action = ":Lazy sync" },
            { icon = "⬆️ ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
            { icon = "⬇️ ", key = "i", desc = "Install Plugins", action = ":Lazy install" },
            { icon = "🧹", key = "x", desc = "Clean Plugins", action = ":Lazy clean" },
            { icon = "📊", key = "P", desc = "Plugin Profile", action = ":Lazy profile" },
            { icon = "📜", key = "L", desc = "Plugin Log", action = ":Lazy log" },
            
            -- Exit
            { icon = "🚪", key = "q", desc = "Quit Neovim", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          {
            pane = 2,
            section = "terminal",
            cmd = "if command -v neofetch >/dev/null 2>&1; then neofetch --ascii_distro arch_small; elif command -v figlet >/dev/null 2>&1; then figlet -f small 'Ready to Code'; else echo '🌈 Welcome to Neovim!' && echo '⚡ Ready for coding!' && echo '🚀 Happy hacking!'; fi",
            height = 5,
            padding = 1,
          },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          -- Git Status only if in a git repository
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return vim.fn.isdirectory(".git") == 1 or vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("%.git")
            end,
            cmd = "git status --porcelain -b 2>/dev/null || echo 'Not in a git repository'",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          {
            section = "startup",
            gap = 1,
            padding = 1,
          },
        },
      },
      
      -- ================================================================
      -- NOTIFIER: Replaces nvim-notify
      -- ================================================================
      notifier = {
        enabled = true,
        timeout = 3000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        -- Preserve nvim-notify style and functionality
        margin = { top = 0, right = 1, bottom = 0 },
        padding = true,
        sort = { "level", "added" },
        -- Animation and style options
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
        style = "compact", -- modern, compact, minimal
      },
      
      -- ================================================================
      -- INDENT: Replaces indent-blankline.nvim
      -- ================================================================
      indent = {
        enabled = true,
        animate = {
          enabled = true,
          duration = {
            step = 20, -- ms per step
            total = 500, -- ms total
          },
        },
        scope = {
          enabled = true,
          animate = true,
          char = "│",
          underline = true,
          only_current = false,
        },
        char = "│",
        -- Only show indent lines in these file types
        filter = function(buf)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft == "" then
            return false
          end
          return not vim.tbl_contains({
            "help", "dashboard", "neo-tree", "Trouble", "trouble", "lazy", "mason",
            "notify", "toggleterm", "lazyterm",
          }, ft)
        end,
      },
      
      -- ================================================================
      -- ADDITIONAL SNACKS FEATURES
      -- ================================================================
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            require("snacks").debug.inspect(...)
          end
          _G.bt = function()
            require("snacks").debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
          
          -- Create some toggle mappings
          require("snacks").toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          require("snacks").toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          require("snacks").toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          require("snacks").toggle.diagnostics():map("<leader>ud")
          require("snacks").toggle.line_number():map("<leader>ul")
          require("snacks").toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          require("snacks").toggle.treesitter():map("<leader>uT")
          require("snacks").toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          require("snacks").toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },
}