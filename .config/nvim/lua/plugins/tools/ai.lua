-- ================================================================
-- TOOLS: AI Development Tools
-- ================================================================

return {
  -- Claude Code Integration
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ai", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code Continue" },
      { "<leader>av", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code Verbose" },
      { "<leader>ar", "<cmd>ClaudeCodeResume<cr>", desc = "Claude Code Resume" },
    },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeVerbose", "ClaudeCodeResume" },
    opts = {
      -- Claude Code configuration
      auto_open = false,
      split_direction = "horizontal",
      split_size = 0.3,
      keymaps = {
        continue = "<leader>ac",
        resume = "<leader>ar",
        verbose = "<leader>av",
      },
    },
  },
}