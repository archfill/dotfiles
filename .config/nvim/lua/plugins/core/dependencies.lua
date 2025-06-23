-- ================================================================
-- CORE: Essential Dependencies - Priority 850
-- ================================================================

return {
  -- Icons - Essential for many plugins
  {
    "nvim-tree/nvim-web-devicons",
    priority = 850,
    lazy = false,
    opts = {
      override = {},
      default = true,
    },
  },

  -- NUI - Core UI library
  {
    "MunifTanjim/nui.nvim",
    priority = 820,
    lazy = false,
  },
}