return {
  "lewis6991/gitsigns.nvim",
  event = "BufRead",
  config = function()
    require("gitsigns").setup({
      -- サイン設定
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      
      -- サインのハイライト設定
      signs_staged_enable = true,
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      
      -- 監視設定
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      
      -- プレビュー設定  
      preview_config = {
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      
      -- キーマップ設定
      on_attach = function(bufnr)
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        
        -- ハンクナビゲーション
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("gitsigns").nav_hunk("next")
          end
        end, { desc = "Next Git hunk" })
        
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("gitsigns").nav_hunk("prev")
          end
        end, { desc = "Previous Git hunk" })
        
        -- ハンク操作
        map("n", "<leader>ghs", require("gitsigns").stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>ghr", require("gitsigns").reset_hunk, { desc = "Reset hunk" })
        map("v", "<leader>ghs", function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selected hunk" })
        map("v", "<leader>ghr", function()
          require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selected hunk" })
        
        map("n", "<leader>ghS", require("gitsigns").stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>ghu", require("gitsigns").undo_stage_hunk, { desc = "Undo stage hunk" })
        map("n", "<leader>ghR", require("gitsigns").reset_buffer, { desc = "Reset buffer" })
        
        -- プレビューと操作
        map("n", "<leader>ghp", require("gitsigns").preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>ghd", require("gitsigns").diffthis, { desc = "Diff this" })
        map("n", "<leader>ghD", function()
          require("gitsigns").diffthis("~")
        end, { desc = "Diff this ~" })
        
        -- ブラメ表示
        map("n", "<leader>ghb", function()
          require("gitsigns").blame_line({ full = true })
        end, { desc = "Blame line" })
        map("n", "<leader>ghtb", require("gitsigns").toggle_current_line_blame, { desc = "Toggle line blame" })
        
        -- 削除行表示
        map("n", "<leader>ghtd", require("gitsigns").toggle_deleted, { desc = "Toggle deleted" })
        
        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
      end,
    })
  end,
}