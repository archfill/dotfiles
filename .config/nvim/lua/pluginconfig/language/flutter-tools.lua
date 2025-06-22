local flutter_tools_ok, flutter_tools = pcall(require, "flutter-tools")
if not flutter_tools_ok then
	vim.notify("flutter-tools.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

flutter_tools.setup({
	ui = {
		border = "rounded",
		notification_style = "nvim-notify",
	},
	decorations = {
		statusline = {
			app_version = true,
			device = true,
		},
	},
	debugger = {
		enabled = true,
		run_via_dap = true,
	},
	flutter_path = nil,
	flutter_lookup_cmd = "which flutter",
	root_patterns = { ".git", "pubspec.yaml" },
	fvm = true,
	widget_guides = {
		enabled = true,
	},
	closing_tags = {
		highlight = "Comment",
		prefix = "// ",
		enabled = true,
	},
	dev_log = {
		enabled = true,
		notify_errors = true,
		open_cmd = "tabedit",
	},
	dev_tools = {
		autostart = false,
		auto_open_browser = false,
	},
	outline = {
		open_cmd = "30vnew",
		auto_open = false,
	},
	lsp = {
		color = {
			enabled = true,
			background = false,
			foreground = false,
			virtual_text = true,
			virtual_text_str = "■",
		},
		capabilities = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end
			return capabilities
		end,
		settings = {
			enableSnippets = true,
			updateImportsOnRename = true,
		},
	},
})

local function is_flutter_project()
	return vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 1
end

vim.api.nvim_create_user_command("FlutterReload", function()
	if is_flutter_project() then
		require("flutter-tools.commands").reload()
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Flutter Hot Reload" })

vim.api.nvim_create_user_command("FlutterRestart", function()
	if is_flutter_project() then
		require("flutter-tools.commands").restart()
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Flutter Hot Restart" })

vim.api.nvim_create_user_command("FlutterQuit", function()
	if is_flutter_project() then
		require("flutter-tools.commands").quit()
	else
		vim.notify("Not a Flutter project", vim.log.levels.WARN)
	end
end, { desc = "Flutter Quit" })