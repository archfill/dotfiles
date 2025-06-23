-- ================================================================
-- UI: Which-key - Priority 600
-- ================================================================

return {
  {
    "folke/which-key.nvim",
    priority = 600,
    event = "VeryLazy",
    config = function()
      local which_key = require("which-key")
      
      -- 基本設定 (pluginconfigから移行)
      which_key.setup({
        preset = "modern",
        icons = {
          breadcrumb = "»", 
          separator = "➜",
          group = "+",
        },
        win = {
          border = "rounded", -- pluginconfigの設定を保持
          padding = { 1, 2 },
          wo = {
            winblend = 0,
          },
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = "left",
        },
        show_help = true,
        show_keys = true,
        triggers = {
          { "<auto>", mode = "nixsotc" },
          { "s", mode = { "n", "v" } },
        },
      })
      
      -- キーマップ登録 - Group hints only (LazyVim Rule 3 compliant)
      which_key.add({
        -- Group definitions only - actual keymaps defined in plugin specs
        { "<leader>f", group = "Files" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Search" },
        { "<leader>t", group = "Toggle" },
        { "<leader>u", group = "UI" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>z", group = "Zettelkasten" },
        { "<leader>n", group = "Noice" },
        { "<leader>b", group = "Buffers" },
      })
      
      -- Success notification (pluginconfigから移行)
      vim.notify("⌨️ Which-key ready! Press <leader> to see mappings", vim.log.levels.INFO)
    end,
  },
}