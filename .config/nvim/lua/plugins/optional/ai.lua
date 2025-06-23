-- ================================================================
-- OPTIONAL: AI Development Tools
-- ================================================================
-- This file manages optional AI development tools
-- Enable/disable features by changing 'enabled' flags

return {
  -- GitHub Copilot (vim version)
  {
    "github/copilot.vim", 
    enabled = false,
    description = "GitHub Copilot integration (vim version)",
  },
  
  -- GitHub Copilot (lua version)
  {
    "zbirenbaum/copilot.lua", 
    enabled = false,
    description = "GitHub Copilot integration (lua version)",
  },
  
  -- ChatGPT integration
  {
    "jackMort/ChatGPT.nvim",
    enabled = false,
    description = "ChatGPT integration for Neovim",
  },
}