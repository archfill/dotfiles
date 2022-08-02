local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
  null_ls.builtins.formatting.stylua.with({
    condition = function()
      return vim.fn.executable("stylua") > 0
    end,
  }),
  null_ls.builtins.diagnostics.eslint,
  null_ls.builtins.formatting.prettier.with({
    condition = function()
      return vim.fn.executable("prettier") > 0
    end,
  }),
  null_ls.builtins.diagnostics.eslint.with({
    condition = function()
      return vim.fn.executable("eslint") > 0
    end,
  }),
  null_ls.builtins.completion.spell,
  null_ls.builtins.formatting.autopep8,
}

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name ~= "tsserver"
    end,
    bufnr = bufnr,
  })
end

local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
      once = false,
    })
  end
end

null_ls.setup({
  sources = sources,
  on_attach = on_attach,
})
