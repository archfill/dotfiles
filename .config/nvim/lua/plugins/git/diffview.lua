return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    { "<leader>gD", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
    { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Files Panel" },
    { "<leader>gdr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh Diffview" },
  },
  config = function()
    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = false,
      git_cmd = { "git" },
      hg_cmd = { "hg" },
      use_icons = true,
      show_help_hints = true,
      watch_index = true,
      
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = false,
          winbar_info = false,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = false,
          winbar_info = false,
        },
      },
      
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
          win_opts = {},
        },
      },
      
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
          hg = {
            single_file = {},
            multi_file = {},
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
          win_opts = {},
        },
      },
      
      commit_log_panel = {
        win_config = {
          win_opts = {},
        }
      },
      
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = "80"
        end,
        diff_buf_win_enter = function(bufnr, winid, ctx)
          if ctx.layout_name:match("^diff2") then
            if ctx.symbol == "a" then
              vim.opt_local.winhl = table.concat({
                "DiffAdd:DiffviewDiffAddAsDelete",
                "DiffDelete:DiffviewDiffDelete",
              }, ",")
            elseif ctx.symbol == "b" then
              vim.opt_local.winhl = table.concat({
                "DiffDelete:DiffviewDiffDelete",
              }, ",")
            end
          end
        end,
      },
      
      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "<tab>", require("diffview.actions").select_next_entry, { desc = "Next entry" } },
          { "n", "<s-tab>", require("diffview.actions").select_prev_entry, { desc = "Previous entry" } },
          { "n", "gf", require("diffview.actions").goto_file_edit, { desc = "Go to file" } },
          { "n", "<C-w><C-f>", require("diffview.actions").goto_file_split, { desc = "Go to file split" } },
          { "n", "<C-w>gf", require("diffview.actions").goto_file_tab, { desc = "Go to file tab" } },
          { "n", "<leader>e", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "<leader>b", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "g<C-x>", require("diffview.actions").cycle_layout, { desc = "Cycle layout" } },
          { "n", "[x", require("diffview.actions").prev_conflict, { desc = "Previous conflict" } },
          { "n", "]x", require("diffview.actions").next_conflict, { desc = "Next conflict" } },
          { "n", "<leader>co", require("diffview.actions").conflict_choose("ours"), { desc = "Choose ours" } },
          { "n", "<leader>ct", require("diffview.actions").conflict_choose("theirs"), { desc = "Choose theirs" } },
          { "n", "<leader>cb", require("diffview.actions").conflict_choose("base"), { desc = "Choose base" } },
          { "n", "<leader>ca", require("diffview.actions").conflict_choose("all"), { desc = "Choose all" } },
          { "n", "dx", require("diffview.actions").conflict_choose("none"), { desc = "Delete conflict" } },
        },
        diff1 = {
          { "n", "g?", require("diffview.actions").help("view"), { desc = "Help" } },
        },
        diff2 = {
          { "n", "g?", require("diffview.actions").help("view"), { desc = "Help" } },
        },
        diff3 = {
          { "n", "g?", require("diffview.actions").help("view"), { desc = "Help" } },
        },
        diff4 = {
          { "n", "g?", require("diffview.actions").help("view"), { desc = "Help" } },
        },
        file_panel = {
          { "n", "j", require("diffview.actions").next_entry, { desc = "Next entry" } },
          { "n", "<down>", require("diffview.actions").next_entry, { desc = "Next entry" } },
          { "n", "k", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
          { "n", "<up>", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
          { "n", "<cr>", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "o", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "l", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "<2-LeftMouse>", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "-", require("diffview.actions").toggle_stage_entry, { desc = "Toggle stage" } },
          { "n", "S", require("diffview.actions").stage_all, { desc = "Stage all" } },
          { "n", "U", require("diffview.actions").unstage_all, { desc = "Unstage all" } },
          { "n", "X", require("diffview.actions").restore_entry, { desc = "Restore entry" } },
          { "n", "L", require("diffview.actions").open_commit_log, { desc = "Open commit log" } },
          { "n", "zo", require("diffview.actions").open_fold, { desc = "Open fold" } },
          { "n", "h", require("diffview.actions").close_fold, { desc = "Close fold" } },
          { "n", "zc", require("diffview.actions").close_fold, { desc = "Close fold" } },
          { "n", "za", require("diffview.actions").toggle_fold, { desc = "Toggle fold" } },
          { "n", "zR", require("diffview.actions").open_all_folds, { desc = "Open all folds" } },
          { "n", "zM", require("diffview.actions").close_all_folds, { desc = "Close all folds" } },
          { "n", "<c-b>", require("diffview.actions").scroll_view(-0.25), { desc = "Scroll up" } },
          { "n", "<c-f>", require("diffview.actions").scroll_view(0.25), { desc = "Scroll down" } },
          { "n", "<tab>", require("diffview.actions").select_next_entry, { desc = "Next entry" } },
          { "n", "<s-tab>", require("diffview.actions").select_prev_entry, { desc = "Previous entry" } },
          { "n", "gf", require("diffview.actions").goto_file_edit, { desc = "Go to file" } },
          { "n", "<C-w><C-f>", require("diffview.actions").goto_file_split, { desc = "Go to file split" } },
          { "n", "<C-w>gf", require("diffview.actions").goto_file_tab, { desc = "Go to file tab" } },
          { "n", "i", require("diffview.actions").listing_style, { desc = "Toggle listing style" } },
          { "n", "f", require("diffview.actions").toggle_flatten_dirs, { desc = "Toggle flatten dirs" } },
          { "n", "R", require("diffview.actions").refresh_files, { desc = "Refresh files" } },
          { "n", "<leader>e", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "<leader>b", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "g<C-x>", require("diffview.actions").cycle_layout, { desc = "Cycle layout" } },
          { "n", "[x", require("diffview.actions").prev_conflict, { desc = "Previous conflict" } },
          { "n", "]x", require("diffview.actions").next_conflict, { desc = "Next conflict" } },
          { "n", "g?", require("diffview.actions").help("file_panel"), { desc = "Help" } },
        },
        file_history_panel = {
          { "n", "g!", require("diffview.actions").options, { desc = "Options" } },
          { "n", "<C-A-d>", require("diffview.actions").open_in_diffview, { desc = "Open in diffview" } },
          { "n", "y", require("diffview.actions").copy_hash, { desc = "Copy hash" } },
          { "n", "L", require("diffview.actions").open_commit_log, { desc = "Open commit log" } },
          { "n", "zR", require("diffview.actions").open_all_folds, { desc = "Open all folds" } },
          { "n", "zM", require("diffview.actions").close_all_folds, { desc = "Close all folds" } },
          { "n", "j", require("diffview.actions").next_entry, { desc = "Next entry" } },
          { "n", "<down>", require("diffview.actions").next_entry, { desc = "Next entry" } },
          { "n", "k", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
          { "n", "<up>", require("diffview.actions").prev_entry, { desc = "Previous entry" } },
          { "n", "<cr>", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "o", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "<2-LeftMouse>", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "<c-b>", require("diffview.actions").scroll_view(-0.25), { desc = "Scroll up" } },
          { "n", "<c-f>", require("diffview.actions").scroll_view(0.25), { desc = "Scroll down" } },
          { "n", "<tab>", require("diffview.actions").select_next_entry, { desc = "Next entry" } },
          { "n", "<s-tab>", require("diffview.actions").select_prev_entry, { desc = "Previous entry" } },
          { "n", "gf", require("diffview.actions").goto_file_edit, { desc = "Go to file" } },
          { "n", "<C-w><C-f>", require("diffview.actions").goto_file_split, { desc = "Go to file split" } },
          { "n", "<C-w>gf", require("diffview.actions").goto_file_tab, { desc = "Go to file tab" } },
          { "n", "<leader>e", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "<leader>b", require("diffview.actions").toggle_files, { desc = "Toggle files panel" } },
          { "n", "g<C-x>", require("diffview.actions").cycle_layout, { desc = "Cycle layout" } },
          { "n", "g?", require("diffview.actions").help("file_history_panel"), { desc = "Help" } },
        },
        option_panel = {
          { "n", "<tab>", require("diffview.actions").select_entry, { desc = "Select entry" } },
          { "n", "q", require("diffview.actions").close, { desc = "Close" } },
          { "n", "g?", require("diffview.actions").help("option_panel"), { desc = "Help" } },
        },
        help_panel = {
          { "n", "q", require("diffview.actions").close, { desc = "Close" } },
          { "n", "<esc>", require("diffview.actions").close, { desc = "Close" } },
        },
      },
    })
  end,
}