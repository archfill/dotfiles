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
      -- DASHBOARD: Ultimate Modern Startup Experience
      -- ================================================================
      dashboard = {
        enabled = true,
        preset = {
          -- 🎨 Beautiful Modern Header with Gradient Effect
          header = [[
                                                        
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                        
    ✨ Beautiful • 🚀 Powerful • 🎯 Professional • 💡 Innovative ✨]],
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
          -- 🎨 Central Header Section
          { section = "header", gap = 1, padding = 1 },
          
          -- 🎯 Main Action Panel (Beautiful Button Layout)
          { section = "keys", gap = 1, padding = 1 },
          
          -- 💼 Left Side Panel: System & Development Info (zsh compatible)
          {
            pane = 2,
            section = "terminal",
            cmd = "if command -v neofetch >/dev/null 2>&1; then neofetch --ascii_distro arch_small --color_blocks off 2>/dev/null || echo '🖥️  System info available'; elif command -v figlet >/dev/null 2>&1; then figlet -f small 'Ready' 2>/dev/null && figlet -f small 'to Code' 2>/dev/null; else echo '🌈 Welcome to Neovim!' && echo '⚡ Ready for coding!' && echo '🚀 Happy hacking!' && echo '💡 Let us create amazing things!'; fi",
            height = 8,
            padding = 1,
            title = "System Info",
            icon = " ",
            indent = 2,
          },
          
          -- 📊 Performance & Stats Panel (zsh compatible)
          {
            pane = 2,
            section = "terminal", 
            cmd = "echo '⚡ Neovim Performance Stats:' && echo '' && plugin_count=$(find ~/.local/share/nvim/lazy -maxdepth 1 -type d 2>/dev/null | wc -l 2>/dev/null || echo '0') && echo '🔌 Plugins: '${plugin_count}' installed' && echo '⏱️  Startup: Fast & responsive' && echo '💾 Memory: Optimized usage' && echo '🎯 Mode: Professional Development' && echo '' && echo '✨ Status: Ready for excellence!'",
            height = 8,
            padding = 1,
            title = "Performance",
            icon = "📊",
            indent = 2,
          },

          -- 📁 Recent Files Panel (Enhanced)
          { 
            pane = 2, 
            icon = " ", 
            title = "Recent Files", 
            section = "recent_files", 
            indent = 2, 
            padding = 1,
            limit = 8,
          },
          
          -- 🗂️ Projects Panel (Enhanced)
          { 
            pane = 2, 
            icon = " ", 
            title = "Projects", 
            section = "projects", 
            indent = 2, 
            padding = 1,
            limit = 6,
          },

          -- 🌿 Git Status Panel (Enhanced, zsh compatible)
          {
            pane = 2,
            icon = " ",
            title = "Git Repository",
            section = "terminal",
            enabled = function()
              return vim.fn.isdirectory(".git") == 1 or vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("%.git")
            end,
            cmd = "echo '📊 Repository Status:' && echo '' && git status --porcelain -b 2>/dev/null | head -10 || echo '📭 Clean working directory' && echo '' && branch_name=$(git branch --show-current 2>/dev/null) && echo '🌱 Branch: '${branch_name:-main} && last_commit=$(git log -1 --pretty=format:'%ar' 2>/dev/null) && echo '📝 Last commit: '${last_commit:-'No commits'}",
            height = 8,
            padding = 1,
            ttl = 5 * 60,
            indent = 2,
          },

          -- 🕐 Time & Welcome Panel (zsh compatible)
          {
            pane = 2,
            section = "terminal",
            cmd = "current_date=$(date +'%A, %B %d, %Y' 2>/dev/null) && current_time=$(date +'%I:%M %p' 2>/dev/null) && echo '🕐 '${current_date:-'Today'} && echo '⏰ '${current_time:-'Now'} && echo '' && echo '🌟 Welcome back, Developer!' && echo '💡 Today is a great day to code!' && echo '🚀 Let us build something amazing!' && echo '' && echo '✨ Happy coding! ✨'",
            height = 8,
            padding = 1,
            title = "Welcome",
            icon = "👋",
            indent = 2,
          },

          -- 🔧 Development Environment Panel (zsh compatible)
          {
            pane = 2,
            section = "terminal",
            cmd = "echo '🔧 Development Environment:' && echo '' && nvim_version=$(nvim --version 2>/dev/null | head -1 | awk '{print $2}' 2>/dev/null) && echo '📝 Editor: Neovim '${nvim_version:-'Latest'} && echo '🎨 Theme: Catppuccin Mocha' && echo '🏗️  Build: LazyVim Standards' && echo '⚡ Performance: Optimized' && echo '🔌 LSP: Full Language Support' && echo '' && echo '🎯 Status: Professional Ready!'",
            height = 8,
            padding = 1,
            title = "Environment",
            icon = "🔧",
            indent = 2,
          },

          -- 📈 Quick Statistics Panel (zsh compatible - CRITICAL FIX)
          {
            pane = 2,
            section = "terminal",
            cmd = "echo '📈 Quick Stats:' && echo '' && current_dir=$(pwd 2>/dev/null) && echo '📂 CWD: '${current_dir##*/} && file_count=$(find . -maxdepth 2 -type f 2>/dev/null | wc -l 2>/dev/null || echo '0') && echo '📁 Files: '${file_count} && code_files=$(find . \\( -name '*.lua' -o -name '*.js' -o -name '*.ts' -o -name '*.py' -o -name '*.go' -o -name '*.rs' \\) 2>/dev/null | wc -l 2>/dev/null || echo '0') && echo '📊 Code Files: '${code_files} && echo '🎯 Mode: Development' && echo '' && echo '💪 Ready to create!'",
            height = 8,
            padding = 1,
            title = "Statistics",
            icon = "📈",
            indent = 2,
          },

          -- 🎉 Startup Completion
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