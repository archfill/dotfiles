local null_ls = require("null-ls")

local ignored_filetypes = {
	"TelescopePrompt",
	"diff",
	"gitcommit",
	"unite",
	"qf",
	"help",
	"markdown",
	"minimap",
	"packer",
	"lazy",
	"dashboard",
	"telescope",
	"lsp-installer",
	"lspinfo",
	"NeogitCommitMessage",
	"NeogitCommitView",
	"NeogitGitCommandHistory",
	"NeogitLogView",
	"NeogitNotification",
	"NeogitPopup",
	"NeogitStatus",
	"NeogitStatusNew",
	"aerial",
	"null-ls-info",
	"mason",
	"noice",
	"notify",
}

local ignored_buftype = {
	"nofile",
}

local groupname = "vimrc_null_ls"
vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = groupname,
	pattern = "*",
	callback = function()
		if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
			return
		end
		if vim.tbl_contains(ignored_buftype, vim.bo.buftype) then
			return
		end

		vim.fn.matchadd("DiffDelete", "\\v\\s+$")
	end,
	once = false,
})

local sources = {
	null_ls.builtins.formatting.stylua.with({
		condition = function()
			return vim.fn.executable("stylua") > 0
		end,
	}),
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
	null_ls.builtins.formatting.autopep8.with({
		condition = function()
			return vim.fn.executable("autopep8") > 0
		end,
	}),
	null_ls.builtins.formatting.dart_format.with({
		condition = function()
			return vim.fn.executable("dart") > 0
		end,
	}),
	-- null_ls.builtins.diagnostics.swiftlint,
	-- null_ls.builtins.diagnostics.swiftlint.with({
	-- 	condition = function()
	-- 		return vim.fn.executable("swiftlint") > 0
	-- 	end,
	-- }),
	-- null_ls.builtins.formatting.swiftlint.with({
	-- 	condition = function()
	-- 		return vim.fn.executable("swiftlint") > 0
	-- 	end,
	-- }),
}

local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			return client.name ~= "tsserver"
		end,
		bufnr = bufnr,
	})
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
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
