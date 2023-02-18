require("hop").setup({})

vim.api.nvim_set_keymap(
  "n",
  "F",
  "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>",
  {}
)
vim.api.nvim_set_keymap(
  "n",
  "f",
  "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>",
  {}
)
vim.api.nvim_set_keymap(
  "x",
  "F",
  "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>",
  {}
)
vim.api.nvim_set_keymap(
  "x",
  "f",
  "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>",
  {}
)
