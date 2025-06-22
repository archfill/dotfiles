local pubspec_ok, pubspec = pcall(require, "pubspec-assist")
if not pubspec_ok then
	vim.notify("pubspec-assist.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

pubspec.setup({
	use_telescope = true,
})

vim.api.nvim_create_augroup("PubspecSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = "PubspecSettings",
	pattern = "yaml",
	callback = function()
		local filename = vim.fn.expand('%:t')
		if filename == "pubspec.yaml" then
			local bufnr = vim.api.nvim_get_current_buf()
			local opts = { buffer = bufnr, noremap = true, silent = true }
			
			vim.bo.expandtab = true
			vim.bo.shiftwidth = 2
			vim.bo.tabstop = 2
			vim.bo.softtabstop = 2
			
			vim.wo.foldmethod = "indent"
			vim.wo.foldlevel = 99
			
			vim.keymap.set('n', '<leader>Pp', function()
				require("pubspec-assist").show_package_info()
			end, vim.tbl_extend('force', opts, { desc = "Show package info" }))
			
			vim.keymap.set('n', '<leader>Ps', function()
				require("pubspec-assist").search_packages()
			end, vim.tbl_extend('force', opts, { desc = "Search packages" }))
			
			vim.keymap.set('n', '<leader>Pl', function()
				vim.cmd('terminal flutter pub get')
			end, vim.tbl_extend('force', opts, { desc = "Flutter pub get" }))
			
			vim.keymap.set('n', '<leader>Pt', function()
				vim.cmd('terminal flutter pub deps')
			end, vim.tbl_extend('force', opts, { desc = "Show dependency tree" }))
			
			vim.keymap.set('n', '<leader>Po', function()
				vim.cmd('terminal flutter pub outdated')
			end, vim.tbl_extend('force', opts, { desc = "Show outdated packages" }))
		end
	end,
})

local function is_flutter_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

vim.api.nvim_create_user_command("PubGet", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub get')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Run flutter pub get" })

vim.api.nvim_create_user_command("PubUpgrade", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub upgrade')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Run flutter pub upgrade" })

vim.api.nvim_create_user_command("PubOutdated", function()
	if is_flutter_project() then
		vim.cmd('terminal flutter pub outdated')
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Show outdated packages" })