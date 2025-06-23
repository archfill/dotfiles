-- ================================================================
-- EDITOR: Autopairs - Priority 250
-- ================================================================

return {
  {
    "windwp/nvim-autopairs",
    priority = 250,
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      
      -- Integration with blink.cmp
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        blink.setup({
          sources = {
            providers = {
              autopairs = {
                name = 'autopairs',
                module = 'nvim-autopairs.completion.blink',
                score_offset = 1,
              },
            },
          },
        })
      end
    end,
  },
}