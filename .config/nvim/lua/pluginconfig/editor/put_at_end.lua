local m = require("put_at_end")
local s = vim.keymap.set
-- s("i", "<C-g>", m.put_semicolon)
s("n", "<C-l>", m.put_semicolon)
s("n", "<C-,>", m.put_period)
s("n", "<C-.>", m.put_comma)
