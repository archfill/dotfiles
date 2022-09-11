-- Default options
require("nightfox").setup({
  options = {
    -- Compiled file's destination location
    compile_path = vim.fn.stdpath("cache") .. "/nightfox",
    compile_file_suffix = "_compiled", -- Compiled file suffix
    transparent = false, -- Disable setting background
    terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
    dim_inactive = false, -- Non focused panes set to alternative background
    styles = { -- Style to be applied to different syntax groups
      comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
      conditionals = "NONE",
      constants = "NONE",
      functions = "NONE",
      keywords = "NONE",
      numbers = "NONE",
      operators = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "NONE",
    },
    inverse = { -- Inverse highlight for different types
      match_paren = false,
      visual = false,
      search = false,
    },
    modules = { -- List of various plugins and additional options
      -- ...
    },
  },
})

-- setup must be called before loading
vim.cmd("colorscheme nightfox")

-- 透過
vim.cmd("highlight Normal ctermbg=none guibg=NONE")
vim.cmd("highlight NonText ctermbg=none guibg=NONE")
vim.cmd("highlight LineNr ctermbg=none guibg=NONE")
vim.cmd("highlight Folded ctermbg=none guibg=NONE")
vim.cmd("highlight EndOfBuffer ctermbg=none guibg=NONE")

-- 透過
vim.cmd("augroup TransparentBG")
vim.cmd("autocmd!")
vim.cmd("autocmd Colorscheme * highlight Normal ctermbg=none guibg=NONE")
vim.cmd("autocmd Colorscheme * highlight NonText ctermbg=none guibg=NONE")
vim.cmd("autocmd Colorscheme * highlight LineNr ctermbg=none guibg=NONE")
vim.cmd("autocmd Colorscheme * highlight Folded ctermbg=none guibg=NONE")
vim.cmd("autocmd Colorscheme * highlight EndOfBuffer ctermbg=none guibg=NONE")
vim.cmd("augroup END")
