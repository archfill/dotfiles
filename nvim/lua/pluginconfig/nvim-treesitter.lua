require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'all', -- :TSInstall allと同じ
  ignore_install = { 'phpdoc', 'tree-sitter-phpdoc' },
  highlight = {
    enable = true, -- syntax highlightを有効にする
    disable = {},
    additional_vim_regex_highlighting = true,
  },
}