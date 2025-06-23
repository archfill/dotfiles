-- ================================================================
-- TOOLS: Snacks Picker - Hybrid Migration Specialist
-- ================================================================
-- Dedicated configuration for snacks.nvim picker functionality
-- Part of the telescope.nvim → snacks.nvim hybrid migration

return {
  {
    "folke/snacks.nvim",
    -- Enhanced keys for picker-specific operations
    keys = {
      -- ===== SMART OPERATIONS (snacks.nvim exclusive) =====
      { "<leader>fs", function() require("snacks").picker.smart() end, desc = "Smart Picker (Snacks)" },
      { "<leader>fz", function() require("snacks").picker() end, desc = "All Pickers (Snacks)" },
      
      -- ===== PROJECT NAVIGATION =====
      { "<leader>fp", function() require("snacks").picker.projects() end, desc = "Projects (Snacks)" },
      
      -- ===== SPECIALIZED SEARCHES =====
      { "<leader>f.", function() require("snacks").picker.files({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Files in Current Dir (Snacks)" },
      { "<leader>fw", function() require("snacks").picker.grep_word() end, desc = "Grep Word Under Cursor (Snacks)" },
      { "<leader>fW", function() require("snacks").picker.grep_word() end, desc = "Grep WORD Under Cursor (Snacks)" },
      
      -- ===== RESUME & HISTORY =====
      { "<leader>fR", function() require("snacks").picker.resume() end, desc = "Resume Last Picker (Snacks)" },
      
      -- ===== ADVANCED FILE OPERATIONS =====
      { "<leader>fa", function() require("snacks").picker.files({ hidden = true, no_ignore = true }) end, desc = "All Files (Hidden) (Snacks)" },
      { "<leader>fG", function() require("snacks").picker.git_files() end, desc = "Git Files (Snacks)" },
    },
    
    opts = {
      picker = {
        -- ================================================================
        -- ADVANCED PICKER CONFIGURATIONS
        -- ================================================================
        
        -- 🚀 Performance Optimizations
        performance = {
          debounce = 20, -- 20ms debounce for live updates
          max_results = 1000, -- Limit results for performance
          timeout = 5000, -- 5s timeout for searches
        },
        
        -- 🎨 Enhanced Layouts
        layouts = {
          ivy = {
            height = 0.4,
            width = 0.9,
            row = "100%",
            border = "rounded",
            title_pos = "center",
          },
          
          dropdown = {
            height = 0.6,
            width = 0.7,
            row = "30%",
            border = "rounded",
            title_pos = "center",
          },
          
          telescope = {
            height = 0.8,
            width = 0.9,
            preview_width = 0.6,
            border = "rounded",
            title_pos = "center",
          },
          
          cursor = {
            height = 0.4,
            width = 0.5,
            border = "rounded",
            title_pos = "center",
          },
        },
        
        -- 🔧 Enhanced Source Configurations
        sources = {
          -- Advanced file finder
          files = {
            finder = "files",
            format = "file",
            hidden = true,
            follow = true,
            ignore_patterns = {
              "node_modules/", ".git/", "target/", "build/", "dist/",
              "*.pyc", "*.class", "*.o", "*.obj", "*.exe",
            },
            layout = { preset = "ivy" },
            confirm = "open",
          },
          
          -- Live grep with advanced options
          grep = {
            finder = "grep",
            format = "file", 
            live = true,
            supports_live = true,
            args = {
              "--hidden",
              "--glob", "!.git/",
              "--smart-case",
              "--line-number",
              "--column",
              "--no-heading",
              "--with-filename",
            },
            layout = { preset = "ivy" },
          },
          
          -- Smart multi-source picker
          smart = {
            multi = { "buffers", "recent", "files" },
            format = "file",
            matcher = {
              cwd_bonus = true,
              frecency = true,
              sort_empty = true,
            },
            transform = "unique_file",
            layout = { preset = "telescope" },
          },
          
          -- Enhanced projects picker
          projects = {
            finder = "recent_projects",
            format = "file",
            dev = { "~/dev", "~/projects", "~/workspace", "~/.config" },
            patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
            recent = true,
            matcher = {
              frecency = true,
              sort_empty = true,
              cwd_bonus = false,
            },
            layout = { preset = "dropdown" },
          },
          
          -- Git files integration
          git_files = {
            finder = "git_files",
            format = "file",
            show_untracked = true,
            layout = { preset = "ivy" },
          },
          
          -- Advanced buffers picker
          buffers = {
            finder = "buffers",
            format = "buffer",
            sort_lastused = true,
            current = true,
            hidden = false,
            layout = { preset = "dropdown" },
          },
          
          -- Enhanced recent files
          recent = {
            finder = "recent",
            format = "file",
            matcher = {
              frecency = true,
              cwd_bonus = true,
            },
            layout = { preset = "ivy" },
          },
        },
        
        -- 🎯 Global Keymaps for All Pickers
        win = {
          input = {
            keys = {
              -- Navigation
              ["<C-j>"] = { "list_down", mode = { "n", "i" } },
              ["<C-k>"] = { "list_up", mode = { "n", "i" } },
              ["<C-n>"] = { "list_down", mode = { "n", "i" } },
              ["<C-p>"] = { "list_up", mode = { "n", "i" } },
              
              -- Selection
              ["<CR>"] = { "confirm", mode = { "n", "i" } },
              ["<Tab>"] = { "list_select", mode = { "n", "i" } },
              ["<S-Tab>"] = { "list_unselect", mode = { "n", "i" } },
              
              -- Window management
              ["<C-v>"] = { "vsplit", mode = { "n", "i" } },
              ["<C-s>"] = { "split", mode = { "n", "i" } },
              ["<C-t>"] = { "tab", mode = { "n", "i" } },
              
              -- Quick actions
              ["<C-q>"] = { "qflist", mode = { "n", "i" } },
              ["<M-q>"] = { "qflist_all", mode = { "n", "i" } },
              
              -- Layout control
              ["<C-l>"] = { "layout", mode = { "n", "i" } },
              ["<C-o>"] = { "toggle_preview", mode = { "n", "i" } },
              
              -- Advanced navigation
              ["<C-u>"] = { "preview_scroll_up", mode = { "n", "i" } },
              ["<C-d>"] = { "preview_scroll_down", mode = { "n", "i" } },
              
              -- History
              ["<C-r>"] = { "history", mode = { "n", "i" } },
              
              -- Close
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<C-c>"] = { "close", mode = { "n", "i" } },
            },
          },
          
          list = {
            keys = {
              ["<CR>"] = "confirm",
              ["<Tab>"] = "list_select", 
              ["<S-Tab>"] = "list_unselect",
              ["<C-q>"] = "qflist",
              ["dd"] = "list_delete",
            },
          },
        },
        
        -- 🔍 Advanced Matcher
        matcher = {
          frecency = true,
          sort_empty = true,
          cwd_bonus = true,
          filename_bonus = true,
          case_mode = "smart_case",
        },
        
        -- 🎪 Enhanced Previewers
        previewers = {
          file = {
            treesitter = true,
            highlight_limit = 1024 * 1024, -- 1MB
            timeout = 250,
            wrap = false,
            show_line_numbers = true,
          },
          
          buffer = {
            treesitter = true,
            highlight_limit = 1024 * 1024,
          },
        },
        
        -- 🎨 UI Customization
        ui = {
          select = {
            backend = "snacks",
          },
          
          title = " {source} ",
          title_pos = "center",
          border = "rounded",
          
          icons = {
            file = "󰈔",
            folder = "󰉋",
            git = "󰊢",
            search = "󰍉",
            recent = "󰋚",
            project = "󰉋",
          },
        },
      },
    },
  },
}