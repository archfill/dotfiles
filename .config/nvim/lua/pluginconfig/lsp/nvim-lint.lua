-- nvim-lint configuration for linting
local lint = require("lint")

-- Configure linters by filetype
lint.linters_by_ft = {
	-- JavaScript/TypeScript
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	
	-- Python
	python = { "pylint" },
	
	-- Rust
	rust = { "clippy" },
	
	-- Go
	go = { "golangci_lint" },
	
	-- C/C++
	c = { "cppcheck" },
	cpp = { "cppcheck" },
	
	-- Java
	java = { "checkstyle" },
	
	-- YAML
	yaml = { "yamllint" },
	
	-- Docker
	dockerfile = { "hadolint" },
	
	-- Markdown/Text
	markdown = { "textlint" },
	text = { "textlint" },
	
	-- Shell
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	
	-- JSON
	json = { "jsonlint" },
	
	-- Web開発品質向上
	html = { "htmlhint" },
	css = { "stylelint" },
	
	-- Tier1言語追加
	php = { "phpstan" },
	ruby = { "rubocop" },
	sql = { "sqlfluff" },
	terraform = { "tflint" },
	hcl = { "tflint" },
	kotlin = { "ktlint" },
	
	-- 外部依存言語
	dart = { "dart_analyzer" },
	
	-- Lua (using selene if available)
	lua = { "selene" },
}

-- Create autocommand for linting
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		-- Only lint if linter is available for the filetype
		local linters = lint.linters_by_ft[vim.bo.filetype]
		if linters then
			-- Check if any of the linters are actually available
			for _, linter_name in ipairs(linters) do
				local linter = lint.linters[linter_name]
				if linter and linter.cmd then
					-- Check if the command exists
					if vim.fn.executable(linter.cmd) == 1 then
						lint.try_lint()
						break
					end
				end
			end
		end
	end,
})

-- Manual linting keymap
vim.keymap.set("n", "<leader>l", function()
	lint.try_lint()
end, { desc = "Trigger linting for current file" })