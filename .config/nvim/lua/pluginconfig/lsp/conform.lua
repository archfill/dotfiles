-- conform.nvim configuration for formatting
local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		-- JavaScript/TypeScript
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		
		-- Web technologies
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		graphql = { "prettier" },
		
		-- Lua
		lua = { "stylua" },
		
		-- Python
		python = { "isort", "black" },
		
		-- Dart/Flutter
		dart = { "dart_format" },
		
		-- Rust
		rust = { "rustfmt" },
		
		-- Go
		go = { "gofmt", "goimports" },
		
		-- C/C++
		c = { "clang_format" },
		cpp = { "clang_format" },
		
		-- Java
		java = { "google_java_format" },
		
		-- Shell (using beautysh as alternative to shfmt)
		sh = { "beautysh" },
		bash = { "beautysh" },
		
		-- Additional formats
		toml = { "taplo" },
		xml = { "xmlformat" },
		
		-- Tier1言語追加
		php = { "php_cs_fixer" },
		ruby = { "rubocop" },
		sql = { "sql_formatter" },
		terraform = { "terraform_fmt" },
		hcl = { "terraform_fmt" },
		kotlin = { "ktlint" },
		
		-- 既存言語不足対応
		dockerfile = { "dockfmt" },
	},
	
	-- Format on save
	format_on_save = {
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	},
	
	-- Format after paste
	format_after_save = {
		lsp_fallback = true,
	},
})

-- Keymap for manual formatting
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "Format file or range (in visual mode)" })

-- Highlight trailing whitespace
local groupname = "conform_whitespace"
vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = groupname,
	pattern = "*",
	callback = function()
		local ignored_filetypes = {
			"TelescopePrompt",
			"diff",
			"gitcommit",
			"unite",
			"qf",
			"help",
			"markdown",
			"minimap",
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
			"mason",
			"noice",
			"notify",
		}
		
		local ignored_buftype = { "nofile" }
		
		if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
			return
		end
		if vim.tbl_contains(ignored_buftype, vim.bo.buftype) then
			return
		end

		vim.fn.matchadd("DiffDelete", "\\v\\s+$")
	end,
})