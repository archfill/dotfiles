-- mason-lspconfig.nvim設定
-- mason.nvimとnvim-lspconfigを連携

-- 安全なrequire
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
	vim.notify("mason-lspconfig.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
	vim.notify("nvim-lspconfig が見つかりません", vim.log.levels.ERROR)
	return
end

-- ===== MASON-LSPCONFIG 基本設定 =====
mason_lspconfig.setup({
	-- 自動インストールするLSPサーバー（基本のみ）
	ensure_installed = {
		"lua_ls",      -- Lua
		"pyright",     -- Python  
		"jsonls",      -- JSON
	},
	automatic_installation = true,
})