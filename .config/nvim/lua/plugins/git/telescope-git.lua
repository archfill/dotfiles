-- ================================================================
-- GIT: Telescope Git Integration
-- ================================================================

return {
  -- Git operations via Telescope
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- ===== GIT FILE OPERATIONS =====
      { "<leader>fG", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
      { "<leader>gx", function() require("telescope").extensions.git_conflicts.conflicts() end, desc = "Git Conflicts" },

      -- ===== GIT OPERATIONS =====
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
      { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Git Buffer Commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Git競合解決拡張
      "Snikimonkd/telescope-git-conflicts.nvim",
    },
  },
}