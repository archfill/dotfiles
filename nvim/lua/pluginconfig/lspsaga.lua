local lspsaga = require("lspsaga")
lspsaga.init_lsp_saga({ -- defaults ...
  border_style = "single",
  saga_winblend = 0,
  move_in_saga = { prev = "<C-p>", next = "<C-n>" },
  diagnostic_header = { " ", " ", " ", "ﴞ" },
  show_diagnostic_source = true,
  diagnostic_source_bracket = {},
  max_preview_lines = 10,
  code_action_icon = " ",
  code_action_num_shortcut = true,
  code_action_lightbulb = {
    enable = true,
    sign = true,
    sign_priority = 20,
    virtual_text = true,
  },
  finder_icons = {
    def = "  ",
    ref = "諭 ",
    link = "  ",
  },
  finder_action_keys = {
    open = "o",
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = "q",
    scroll_down = "<C-f>",
    scroll_up = "<C-b>", -- quit can be a table
  },
  code_action_keys = {
    quit = "q",
    exec = "<CR>",
  },
  rename_action_quit = "<C-c>",
  definition_preview_icon = "  ",
  symbol_in_winbar = {
    in_custom = false,
    enable = false,
    separator = " ",
    show_file = true,
    click_support = false,
  },
  show_outline = {
    win_position = "right",
    --set special filetype win that outline window split.like NvimTree neotree
    -- defx, db_ui
    win_with = "",
    win_width = 30,
    auto_enter = true,
    auto_preview = true,
    virt_text = "┃",
    jump_key = "o",
    -- auto refresh when change buffer
    auto_refresh = true,
  },
  server_filetype_map = {},
})

--- In lsp attach function
-- local map = vim.api.nvim_buf_set_keymap
-- map(0, "n", "<space>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
-- map(0, "n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- map(0, "x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- map(0, "n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
-- map(0, "n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- map(0, "n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- map(0, "n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
-- map(0, "n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
vim.keymap.set("n", "<space>rn", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gx", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("x", "gx", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-u>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1, '<c-u>')<cr>", {})
vim.keymap.set("n", "<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1, '<c-d>')<cr>", {})
