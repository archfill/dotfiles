
if vim.g.vscode then
  -- VSCode extension
  require("base-vscode")
else
  -- ordinary Neovim
  require("base")
  require("plugins")
  require("colorscheme")
end

require("mapping")
