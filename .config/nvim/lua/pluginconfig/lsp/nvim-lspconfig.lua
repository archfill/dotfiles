-- nvim-lspconfig設定（完全版）

-- 診断アイコンの設定
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- lspconfigとcmp_nvim_lspの確認
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
	vim.notify("lspconfig not found", vim.log.levels.WARN)
	return
end

-- Try blink.cmp first, fallback to cmp_nvim_lsp for compatibility
local blink_cmp_ok, blink_cmp = pcall(require, "blink.cmp")
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if not blink_cmp_ok and not cmp_nvim_lsp_ok then
	vim.notify("Neither blink.cmp nor cmp_nvim_lsp found", vim.log.levels.WARN)
	return
end

-- LSP共通設定
local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	-- LSPサーバーのフォーマット機能を無効にする（conform.nvimを使用）
	if client.server_capabilities then
		client.server_capabilities.documentFormattingProvider = false
	end

	local opts = { noremap = true, silent = true }
	-- 基本的なLSPキーマップは keymap/plugins.lua で管理（パフォーマンス最適化）
	-- ここでは複雑な設定やハンドラのみ定義
end

-- 補完機能の設定 - blink.cmp優先、fallbackはnvim-cmp
local capabilities
if blink_cmp_ok then
	capabilities = blink_cmp.get_lsp_capabilities()
elseif cmp_nvim_lsp_ok then
	capabilities = cmp_nvim_lsp.default_capabilities()
else
	capabilities = vim.lsp.protocol.make_client_capabilities()
end

-- 基本的なLSPサーバー設定（mason-lspconfigに依存しない）
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
	clangd = {
		capabilities = vim.tbl_deep_extend("force", capabilities, {
			offsetEncoding = { "utf-16" },
		}),
	},
}

-- サーバーのセットアップ
for server, config in pairs(servers) do
	local server_config = vim.tbl_deep_extend("force", {
		on_attach = on_attach,
		capabilities = capabilities,
	}, config)
	
	lspconfig[server].setup(server_config)
end

-- mason-lspconfigが利用可能な場合は追加設定
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lspconfig_ok then
	-- setup_handlers関数の存在確認
	if mason_lspconfig.setup_handlers then
		mason_lspconfig.setup_handlers({
			function(server_name)
				-- 既に設定済みのサーバーはスキップ
				if servers[server_name] then
					return
				end
				
				-- その他のサーバー用デフォルト設定
				lspconfig[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end,
		})
	else
		-- 手動でインストール済みサーバーを設定
		local installed_servers = mason_lspconfig.get_installed_servers or function() return {} end
		for _, server_name in pairs(installed_servers()) do
			if not servers[server_name] then
				lspconfig[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end
	end
end