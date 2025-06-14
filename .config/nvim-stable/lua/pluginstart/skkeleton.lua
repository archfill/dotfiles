vim.keymap.set({ "i", "c", "l" }, "<C-j>", "<Plug>(skkeleton-enable)")
vim.keymap.set("i", "<C-x><C-o>", function()
  require("cmp").complete()
end)

local pre_config

local g1 = vim.api.nvim_create_augroup("skkeleton_callbacks", {})
vim.api.nvim_create_autocmd("User", {
  group = g1,
  pattern = "skkeleton-enable-pre",
  callback = function()
    pre_config = require("cmp.config").get()
    require("cmp").setup.buffer({
      sources = { { name = "skkeleton" } },
      view = { entries = "native" },
    })
  end,
})
vim.api.nvim_create_autocmd("User", {
  group = g1,
  pattern = "skkeleton-disable-pre",
  callback = function()
    if pre_config then
      require("cmp").setup.buffer(pre_config)
      pre_config = nil
    end
  end,
})
