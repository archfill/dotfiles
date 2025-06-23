-- ================================================================
-- TOOLS: Telescope - Fuzzy Finder
-- ================================================================

return {
  -- Telescope: ファジーファインダー + 高性能拡張
  {
    "nvim-telescope/telescope.nvim",
    priority = 400, -- Tools category priority
    keys = {
      -- ===== CORE FILE OPERATIONS (Migrated to snacks.nvim) =====
      -- { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" }, -- → snacks.picker.files
      -- { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" }, -- → snacks.picker.grep
      -- { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" }, -- → snacks.picker.buffers
      -- { "<leader>fm", function() require("telescope.builtin").oldfiles() end, desc = "Recent Files" }, -- → snacks.picker.recent
      -- { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old Files" }, -- → snacks.picker.recent
      
      -- ===== SPECIALIZED OPERATIONS (Telescope Maintained) =====
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },

      -- ===== ADVANCED FILE OPERATIONS =====
      { "<leader>fd", function() require("telescope.builtin").find_files({ cwd = "~/.dotfiles" }) end, desc = "Find Dotfiles" },
      { "<leader>fn", function() require("telescope.builtin").find_files({ cwd = "~/.config/nvim" }) end, desc = "Find Neovim Config" },
      { "<leader>ft", function() require("telescope.builtin").live_grep({ default_text = "TODO\\|FIXME\\|HACK\\|BUG" }) end, desc = "Find TODOs" },

      -- ===== CORE EXTENSIONS =====
      { "<leader>fB", function() require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true }) end, desc = "File Browser" },
      { "<leader>fp", function() require("telescope").extensions.project.project({}) end, desc = "Projects" },
      { "<leader>fs", function() require("telescope").extensions.symbols.symbols() end, desc = "Symbols & Emoji" },
      { "<leader>fu", function() require("telescope").extensions.undo.undo() end, desc = "Undo Tree" },
      { "<leader>fH", function() require("telescope").extensions.heading.heading() end, desc = "Document Headings" },

      -- ===== HIGH PRIORITY EXTENSIONS =====
      { "<leader>fF", function() require("telescope").extensions.frecency.frecency() end, desc = "Frecency Files (Smart)" },
      { "<leader>fy", function() require("telescope").extensions.yanky.history() end, desc = "Yank History" },
      { "<leader>fM", function() require("telescope").extensions.media_files.media_files() end, desc = "Media Files" },
      { "<leader>fX", function() require("telescope").extensions.tabs.list() end, desc = "Tabs" },
      { "<leader>fC", function() require("telescope").extensions.cmdline.cmdline() end, desc = "Command Line" },
      { "<leader>fS", function() require("telescope").extensions.session.session() end, desc = "Sessions" },

      -- ===== UTILITY SEARCHES (Migrated to snacks.nvim) =====
      -- { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Registers" }, -- → snacks.picker.registers
      -- { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" }, -- → snacks.picker.keymaps
      -- { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" }, -- → snacks.picker.colorschemes
      -- { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jump List" }, -- → snacks.picker.jumps
      -- { "<leader>fL", "<cmd>Telescope loclist<cr>", desc = "Location List" }, -- → snacks.picker.loclist
      -- { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix" }, -- → snacks.picker.qflist

      -- ===== COMMAND OPERATIONS (Partial Migration) =====
      { "<leader>f:", "<cmd>Telescope commands<cr>", desc = "Commands" },
      -- { "<leader>f;", "<cmd>Telescope command_history<cr>", desc = "Command History" }, -- → snacks.picker (:<leader>:)
      { "<leader>f/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
      { "<leader>f?", function() require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({})) end, desc = "Buffer Fuzzy Find" },
      -- { "<leader>-", "<cmd>Telescope command_history<cr>", desc = "Command History" }, -- → snacks.picker

      -- ===== LSP OPERATIONS =====
      { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>lr", "<cmd>Telescope lsp_references<cr>", desc = "LSP References" },
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
      { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },


      -- ===== TELESCOPE META =====
      { "<leader>fT", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtins" },

      -- ===== FLUTTER DEVELOPMENT =====
      { "<leader>flc", "<cmd>Telescope flutter commands<cr>", desc = "Flutter Commands" },
      { "<leader>flv", "<cmd>Telescope flutter fvm<cr>", desc = "Flutter FVM" },
    },
    cmd = { "Telescope" },
    dependencies = { 
      "nvim-lua/plenary.nvim",
      -- ===== CORE EXTENSIONS =====
      -- 高性能ソーター拡張
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      -- ファイルブラウザー拡張
      "nvim-telescope/telescope-file-browser.nvim",
      -- UI統合拡張
      "nvim-telescope/telescope-ui-select.nvim",
      -- 記号・絵文字検索
      "nvim-telescope/telescope-symbols.nvim",
      -- プロジェクト管理
      {
        "nvim-telescope/telescope-project.nvim",
        dependencies = { "nvim-telescope/telescope-file-browser.nvim" },
      },
      -- 最近使用ファイル (OPTIONAL)
      { "smartpde/telescope-recent-files", enabled = false },
      -- アンドゥツリー (ESSENTIAL)
      "debugloop/telescope-undo.nvim",
      -- 見出し検索 (ESSENTIAL)
      "crispgm/telescope-heading.nvim",
      -- セッション管理 (OPTIONAL)
      { "HUAHUAI23/telescope-session.nvim", enabled = false },

      -- ===== HIGH PRIORITY ADDITIONS =====
      -- Frecency: 学習機能付きファイル検索 (ESSENTIAL)
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = {
          { "kkharji/sqlite.lua" },
        },
      },
      -- Yanky: ヤンク履歴管理 (ESSENTIAL)
      {
        "gbprod/yanky.nvim",
        opts = {},
      },
      -- Media Files: 画像・PDF・動画プレビュー (OPTIONAL)
      {
        "nvim-telescope/telescope-media-files.nvim",
        enabled = false,
        dependencies = {
          "nvim-lua/popup.nvim",
        },
      },
      -- Tabs: タブ管理強化 (OPTIONAL)
      { "LukasPietzschmann/telescope-tabs", enabled = false },
      -- Command Line: フローティングコマンドライン (OPTIONAL)
      { "jonarrien/telescope-cmdline.nvim", enabled = false },
    },
    opts = function()
      local actions = require("telescope.actions")
      local action_layout = require("telescope.actions.layout")
      
      -- ================================================================
      -- UNIFIED FLOATING DESIGN STANDARDS (Snacks Compatible)
      -- ================================================================
      -- Global design consistency:
      -- - Border: "rounded" borderchars across all pickers/extensions
      -- - Transparency: winblend = 5 for subtle floating effect
      -- - Layout: center/horizontal floating strategies
      -- - Navigation: C-j/C-k, Tab/S-Tab for selection
      -- - Visual: prompt_prefix 🔍, selection_caret ▶
      
      return {
        defaults = {
          -- Performance optimizations
          file_ignore_patterns = {
            "node_modules/*", ".git/*", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip",
            "target/*", "build/*", "dist/*",
          },
          
          -- Unified Floating Layout Configuration
          layout_strategy = "horizontal", -- Default to horizontal floating
          layout_config = {
            horizontal = { 
              width = 0.85, 
              height = 0.8, 
              preview_width = 0.6,
              -- Center floating positioning
              anchor = "center",
              prompt_position = "top",
            },
            center = {
              width = 0.7,
              height = 0.7,
              anchor = "center",
            },
            vertical = { 
              width = 0.8, 
              height = 0.9, 
              preview_height = 0.5,
              anchor = "center",
              prompt_position = "top",
            },
            -- Global floating settings
            center_gravity = true,
          },
          
          -- Enhanced Floating Window Styling
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          prompt_prefix = "🔍 ",
          selection_caret = "▶ ",
          winblend = 5, -- Subtle transparency for modern floating feel
          
          -- Enhanced keymaps
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<C-t>"] = action_layout.toggle_preview,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-t>"] = action_layout.toggle_preview,
              ["q"] = actions.close,
            },
          },
        },
        
        -- Picker-specific configurations - UNIFIED FLOATING DESIGN
        pickers = {
          find_files = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.8,
              height = 0.7,
              preview_width = 0.55,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            hidden = true,
          },
          live_grep = {
            layout_strategy = "horizontal", 
            layout_config = {
              width = 0.9,
              height = 0.8,
              preview_width = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          buffers = {
            layout_strategy = "center",
            layout_config = {
              width = 0.7,
              height = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            sort_mru = true,
          },
          help_tags = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.8,
              height = 0.75,
              preview_width = 0.65,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          colorscheme = {
            layout_strategy = "center",
            layout_config = {
              width = 0.6,
              height = 0.7,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            enable_preview = true,
          },
          -- Additional essential pickers
          diagnostics = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.8,
              preview_width = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          lsp_references = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.8,
              preview_width = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          lsp_document_symbols = {
            layout_strategy = "center",
            layout_config = {
              width = 0.8,
              height = 0.7,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          commands = {
            layout_strategy = "center",
            layout_config = {
              width = 0.7,
              height = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
        },
        
        -- Extensions configuration
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.8,
              preview_width = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            hijack_netrw = true,
          },
          ["ui-select"] = {
            layout_strategy = "center",
            layout_config = {
              width = 0.6,
              height = 0.5,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            winblend = 10,
          },
          project = {
            base_dirs = {
              { "~/Projects", max_depth = 3 },
              { "~/dotfiles", max_depth = 2 },
              { vim.fn.getcwd(), max_depth = 1 },
            },
            layout_strategy = "center",
            layout_config = {
              width = 0.8,
              height = 0.7,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          undo = {
            layout_strategy = "horizontal",
            layout_config = {
              width = 0.9,
              height = 0.8,
              preview_width = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          yanky = {
            layout_strategy = "center", 
            layout_config = {
              width = 0.7,
              height = 0.6,
            },
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
            workspaces = {
              ["nvim"] = vim.fn.stdpath("config"),
              ["dotfiles"] = vim.fn.expand("~/dotfiles"),
            },
          },
        },
      }
    end,
    config = function(_, opts)
      -- Essential telescope setup with extensions
      local telescope = require("telescope")
      
      -- Setup with opts
      telescope.setup(opts)
      
      -- Load essential extensions only
      local essential_extensions = {
        "fzf",
        "ui-select", 
        "file_browser",
        "project",
        "undo",
        "heading",
        "frecency",
        "yanky",
      }
      
      -- Safe extension loading
      for _, ext in ipairs(essential_extensions) do
        local ok, _ = pcall(telescope.load_extension, ext)
        if not ok then
          vim.notify("Telescope extension '" .. ext .. "' not available", vim.log.levels.WARN)
        end
      end
    end,
  },
}

