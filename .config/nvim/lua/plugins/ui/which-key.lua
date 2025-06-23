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
      
      -- キーマップ登録 (pluginconfigから完全移行)
      which_key.add({
        -- Files group
        { "<leader>f", group = "Files" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
        
        -- Git group
        { "<leader>g", group = "Git" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
        { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
        
        -- Explorer
        { "<leader>e", "<cmd>Neotree position=float reveal toggle<cr>", desc = "Toggle Explorer" },
        { "<leader>q", "<cmd>nohlsearch<cr>", desc = "No Highlight" },
        
        -- Noice group
        { "<leader>n", group = "Noice" },
        { "<leader>nm", "<cmd>Noice<cr>", desc = "Messages" },
        { "<leader>nl", "<cmd>Noice last<cr>", desc = "Last Message" },
        { "<leader>ne", "<cmd>Noice errors<cr>", desc = "Errors" },
        { "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss" },

        -- Buffers group 
        { "<leader>b", group = "Buffers" },
        { "<leader>bd", desc = "Delete Buffer" },
        { "<leader>bo", desc = "Delete Other Buffers" },
        { "<leader>1", desc = "Go to Buffer 1" },
        { "<leader>2", desc = "Go to Buffer 2" },
        { "<leader>3", desc = "Go to Buffer 3" },
        { "<leader>4", desc = "Go to Buffer 4" },
        { "<leader>5", desc = "Go to Buffer 5" },
        { "<leader>6", desc = "Go to Buffer 6" },
        { "<leader>7", desc = "Go to Buffer 7" },
        { "<leader>8", desc = "Go to Buffer 8" },
        { "<leader>9", desc = "Go to Buffer 9" },

        -- Buffer navigation
        { "H", desc = "Previous Buffer" },
        { "L", desc = "Next Buffer" },
        { "x", desc = "Delete Buffer" },
        
        -- Additional groups for extensibility
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Search" },
        { "<leader>t", group = "Toggle" },
        { "<leader>u", group = "UI" },
        { "<leader>us", desc = "Toggle Scrollbar" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>z", group = "Zettelkasten" },
      })
      
      -- Success notification (pluginconfigから移行)
      vim.notify("⌨️ Which-key ready! Press <leader> to see mappings", vim.log.levels.INFO)
    end,
  },
}