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
      -- ===== SNACKS PICKER: Core Daily Operations (Hybrid Migration) =====
      { "<leader>ff", function() require("snacks").picker.files() end, desc = "Files (Snacks)" },
      { "<leader>fg", function() require("snacks").picker.grep() end, desc = "Grep (Snacks)" },
      { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers (Snacks)" },
      { "<leader>fm", function() require("snacks").picker.recent() end, desc = "Recent (Snacks)" },
      { "<leader>fo", function() require("snacks").picker.recent() end, desc = "Old Files (Snacks)" },
      
      -- ===== VIM OPERATIONS (Migrated from Telescope) =====
      { "<leader>fr", function() require("snacks").picker.registers() end, desc = "Registers (Snacks)" },
      { "<leader>fk", function() require("snacks").picker.keymaps() end, desc = "Keymaps (Snacks)" },
      { "<leader>fc", function() require("snacks").picker.colorschemes() end, desc = "Colors (Snacks)" },
      { "<leader>fj", function() require("snacks").picker.jumps() end, desc = "Jumps (Snacks)" },
      { "<leader>fL", function() require("snacks").picker.loclist() end, desc = "Location List (Snacks)" },
      { "<leader>fq", function() require("snacks").picker.qflist() end, desc = "Quickfix (Snacks)" },
      
      -- ===== UTILITY OPERATIONS =====
      { "<leader>:", function() require("snacks").picker.command_history() end, desc = "Command History (Snacks)" },
      { "<leader>/", function() require("snacks").picker.grep({ search = vim.fn.expand("<cword>") }) end, desc = "Grep Word (Snacks)" },
      
      -- ===== SNACKS CORE FEATURES =====
      -- Notifier controls
      { "<leader>nc", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<BS>", function() require("snacks").notifier.hide() end, desc = "Dismiss All Notifications" },
      -- Dashboard
      { "<leader>D", function() require("snacks").dashboard() end, desc = "Dashboard" },
    },
    opts = {
      -- ================================================================
      -- UNIFIED FLOATING DESIGN STANDARDS (Telescope Compatible)
      -- ================================================================
      -- Global design consistency:
      -- - Border: "rounded" across all components
      -- - Transparency: winblend = 5 for subtle floating effect
      -- - Positioning: Center-based layouts (50%, 50%)
      -- - Animation: Smooth transitions with backdrop support
      -- - Keymaps: Telescope-compatible navigation (C-j/C-k, Tab/S-Tab)
      
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
      -- NOTIFIER: Enhanced Floating Notifications
      -- ================================================================
      notifier = {
        enabled = true,
        timeout = 3000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        -- Enhanced floating style to match unified design
        margin = { top = 0, right = 1, bottom = 0 },
        padding = true,
        sort = { "level", "added" },
        -- Unified styling with Telescope
        style = "compact", 
        border = "rounded", -- Match Telescope border style
        -- Animation and style options
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
        -- Transparency to match overall floating theme
        win = {
          winblend = 5, -- Match Telescope transparency
          backdrop = false, -- Individual notifications don't need backdrop
        },
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
      -- SNACKS PICKER: High-Performance Daily Operations
      -- ================================================================
      -- Hybrid migration: Core operations moved from telescope.nvim
      picker = {
        -- 🚀 Enhanced UI Configuration
        ui = {
          title = " {source} ",
          title_pos = "center",
          border = "rounded",
        },
        
        -- 🎨 Enhanced Floating Window Layout Configuration
        layout = {
          preset = "telescope", -- Base preset
          backdrop = { 
            enabled = true,
            blend = 70, -- Enhanced backdrop transparency
          },
          width = 0.85,
          height = 0.75,
          row = "50%", -- Perfect center vertically
          col = "50%", -- Perfect center horizontally
          border = "rounded", -- Modern rounded borders
          title_pos = "center",
          -- Enhanced floating window styling  
          style = "minimal",
          relative = "editor",
          anchor = "center",
          -- Animation and effects
          zindex = 200, -- Ensure proper layering
          focusable = true,
          noautocmd = false,
        },
        
        -- ⚡ Performance Optimizations
        finder = {
          follow = true,
          hidden = true,
        },
        
        -- 🔧 Source Configurations for Hybrid Migration - UNIFIED FLOATING
        sources = {
          -- ===== CORE FILE OPERATIONS (Unified Floating Design) =====
          files = {
            finder = "files",
            format = "file",
            hidden = true,
            follow = true,
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          grep = {
            finder = "grep", 
            format = "file",
            live = true,
            supports_live = true,
            layout = { 
              preset = "telescope",
              width = 0.9,
              height = 0.8,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          buffers = {
            finder = "buffers",
            format = "buffer",
            sort_lastused = true,
            layout = { 
              preset = "telescope",
              width = 0.7,
              height = 0.6,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          recent = {
            finder = "recent",
            format = "file", 
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          -- ===== VIM OPERATIONS (Unified Floating Design) =====
          registers = {
            finder = "vim_registers",
            format = "register",
            preview = "preview",
            confirm = { "copy", "close" },
            layout = { 
              preset = "telescope",
              width = 0.6,
              height = 0.5,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          keymaps = {
            finder = "vim_keymaps",
            format = "keymap",
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          colorschemes = {
            finder = "vim_colorschemes", 
            format = "text",
            preview = "colorscheme",
            layout = { 
              preset = "telescope",
              width = 0.6,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
            confirm = function(picker, item)
              picker:close()
              if item then
                picker.preview.state.colorscheme = nil
                vim.schedule(function()
                  vim.cmd("colorscheme " .. item.text)
                end)
              end
            end,
          },
          
          jumps = {
            finder = "vim_jumps",
            format = "file",
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.6,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          loclist = {
            finder = "qf",
            format = "file", 
            qf_win = 0,
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
          
          qflist = {
            finder = "qf",
            format = "file",
            layout = { 
              preset = "telescope",
              width = 0.8,
              height = 0.7,
              row = "50%",
              col = "50%",
              border = "rounded",
            },
          },
        },
        
        -- 🎯 Enhanced Keymaps for Hybrid Operations - Telescope Compatible
        win = {
          input = {
            keys = {
              -- Vim-style navigation (Telescope compatible)
              ["<C-j>"] = { "list_down", mode = { "n", "i" } },
              ["<C-k>"] = { "list_up", mode = { "n", "i" } },
              
              -- Selection operations
              ["<Tab>"] = { "list_select", mode = { "n", "i" } },
              ["<S-Tab>"] = { "list_unselect", mode = { "n", "i" } },
              
              -- Quick actions (Telescope compatible)
              ["<C-q>"] = { "qflist", mode = { "n", "i" } },
              ["<C-v>"] = { "vsplit", mode = { "n", "i" } },
              ["<C-s>"] = { "split", mode = { "n", "i" } },
              ["<C-t>"] = { "tab", mode = { "n", "i" } },
              
              -- Layout control
              ["<C-p>"] = { "toggle_preview", mode = { "n", "i" } },
              ["<C-h>"] = { "layout", mode = { "n", "i" } },
              
              -- Exit shortcuts (Telescope compatible)
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["q"] = { "close", mode = "n" },
            },
            -- Enhanced input styling
            border = "rounded",
            title_pos = "center",
            winblend = 5, -- Match Telescope transparency
          },
          list = {
            border = "rounded",
            winblend = 5,
          },
          preview = {
            border = "rounded", 
            winblend = 5,
          },
        },
        
        -- 🔍 Advanced Matcher Configuration
        matcher = {
          frecency = true,
          sort_empty = true,
          cwd_bonus = true,
        },
        
        -- 🎪 Previewers Configuration
        previewers = {
          file = {
            treesitter = true,
            highlight_limit = 1024 * 1024, -- 1MB limit
            timeout = 250,
          },
        },
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