return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  event = "VeryLazy", -- バックアップとして event も追加
  keys = {
    -- 関数呼び出し形式に変更（より効率的）
    { "<leader>gg", function() require("neogit").open() end, desc = "Neogit - Open Git Interface" },
    { "<leader>gn", function() require("neogit").open({ "commit" }) end, desc = "Neogit - Commit" },
    { "<leader>gB", function() require("neogit").open({ "branch" }) end, desc = "Neogit - Branch Management" },
    { "<leader>gl", function() require("neogit").open({ "log" }) end, desc = "Neogit - Git Log" },
    { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit - Push" },
    { "<leader>gP", "<cmd>Neogit pull<cr>", desc = "Neogit - Pull" },
  },
  config = function()
    require("neogit").setup({
      -- 統合設定
      integrations = {
        diffview = true,
        telescope = true,
      },
      
      -- UI設定
      disable_hint = false,
      disable_context_highlighting = false,
      disable_signs = false,
      disable_line_numbers = true,
      disable_relative_line_numbers = true,
      
      -- 開く方法設定
      kind = "tab",
      
      -- 自動リフレッシュとファイル監視
      auto_refresh = true,
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      
      -- 高度な設定
      disable_insert_on_commit = "auto",
      use_default_keymaps = true,
      console_timeout = 2000,
      prompt_force_push = true,
      
      -- サイン設定
      signs = {
        hunk = { "󰐕", "󰍷" },
        item = { "●", "◯" },
        section = { "", "" },
      },
      
      -- ステータス設定
      status = {
        recent_commit_count = 10,
      },
      
      -- グラフスタイル（ルートレベルに移動）
      graph_style = "unicode",
      
      -- 設定の永続化
      remember_settings = true,
      use_per_project_settings = true,
      
      -- ブランチ表示順序
      sort_branches = "-committerdate",
      
      -- 無視設定
      ignored_settings = {
        "NeogitPushPopup--force-with-lease",
        "NeogitPushPopup--force",
        "NeogitPullPopup--rebase",
        "NeogitCommitPopup--allow-empty",
        "NeogitRevertPopup--no-edit",
      },
    })
  end,
}