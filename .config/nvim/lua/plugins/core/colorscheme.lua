-- ================================================================
-- CORE: Colorschemes - Priority 1000 (Highest)
-- ================================================================

return {
  -- Tokyo Night colorscheme
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      -- Terminal Colors
      vim.opt.termguicolors = true
      
      -- Tokyo Night Colorscheme（安全な読み込み）
      local ok, _ = pcall(vim.cmd.colorscheme, "tokyonight")
      if not ok then
        -- フォールバックカラースキーム
        vim.cmd.colorscheme("default")
        vim.notify("tokyonight colorscheme not found, using default", vim.log.levels.WARN)
      end
      
      -- Custom Highlights
      vim.cmd("hi Comment gui=NONE")
    end,
  },
}