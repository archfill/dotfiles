return {
  "akinsho/git-conflict.nvim",
  event = "BufRead",
  config = function()
    require("git-conflict").setup({
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = false,
      list_opener = "copen",
      
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
      
      -- コンフリクトマーカーの設定
      markers = {
        start = "<<<<<<< ",
        middle = "======= ",
        finish = ">>>>>>> ",
      },
      
      -- 検出無効化するディレクトリ
      disable_in_paths = {
        ".git/",
        "node_modules/",
        ".cache/",
      },
    })
    
    -- カスタムキーマップ設定
    vim.keymap.set("n", "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", { desc = "Choose ours (current branch)" })
    vim.keymap.set("n", "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", { desc = "Choose theirs (incoming branch)" })
    vim.keymap.set("n", "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", { desc = "Choose both changes" })
    vim.keymap.set("n", "<leader>gc0", "<cmd>GitConflictChooseNone<cr>", { desc = "Choose none (delete conflict)" })
    vim.keymap.set("n", "]x", "<cmd>GitConflictNextConflict<cr>", { desc = "Next conflict" })
    vim.keymap.set("n", "[x", "<cmd>GitConflictPrevConflict<cr>", { desc = "Previous conflict" })
    vim.keymap.set("n", "<leader>gcl", "<cmd>GitConflictListQf<cr>", { desc = "List conflicts in quickfix" })
    
    -- Autocommands for conflict detection
    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictDetected",
      callback = function()
        vim.notify("Git conflict detected! Use ]x and [x to navigate.", vim.log.levels.WARN)
      end,
    })
    
    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictResolved",
      callback = function()
        vim.notify("All git conflicts resolved!", vim.log.levels.INFO)
      end,
    })
  end,
}