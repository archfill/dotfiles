require("mason-lspconfig").setup()

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	-- LSPサーバーのフォーマット機能を無効にする
	client.server_capabilities.documentFormattingProvider = false

	local opts = { noremap = true, silent = true }
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	-- buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	-- buf_set_keymap("n", LK_LSP .. "rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	-- buf_set_keymap("n", LK_LSP .. "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	buf_set_keymap("n", LK_LSP .. "f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

	-- require("nvim-navic").attach(client, bufnr)
end

local lspconfig = require("lspconfig")
-- local configs = require("lspconfig/configs")
-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local clangd_capabilities = vim.lsp.protocol.make_client_capabilities()
clangd_capabilities.offsetEncoding = { "utf-16" }

capabilities.textDocument.completion.completionItem.snippetSupport = true

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup_handlers({
	function(server_name)
		if server_name == "clangd" then
			lspconfig[server_name].setup({
				capabilities = clangd_capabilities,
				on_attach = on_attach,
			})
		else
			lspconfig[server_name].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
		end
	end,
	-- ["emmet_ls"] = function()
	-- 	-- emmet
	-- 	lspconfig.emmet_ls.setup({
	-- 		-- on_attach = on_attach,
	-- 		capabilities = capabilities,
	-- 		filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
	-- 		init_options = {
	-- 			html = {
	-- 				options = {
	-- 					-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
	-- 					["bem.enabled"] = true,
	-- 				},
	-- 			},
	-- 		},
	-- 	})
	-- end,
	-- ["sourcekit"] = function()
	-- 	-- swift
	-- 	lspconfig.sourcekit.setup({
	-- 		on_attach = on_attach,
	-- 		capabilities = capabilities,
	-- 		filetypes = { "swift", "c", "cpp", "objective-c", "objective-cpp" },
	-- 	})
	-- end,
})

-- lspconfig.dartls.setup({
-- 	on_attach = on_attach,
-- 	capabilities = capabilities,
-- 	filetypes = { "dart" },
-- 	init_options = {
-- 		closingLabels = "true",
-- 		fluttreOutline = "false",
-- 		onlyAnalyzeProjectsWithOpenFiles = "false",
-- 		outline = "true",
-- 		suggestFromUnimportedLibraries = "true",
-- 	},
-- })
