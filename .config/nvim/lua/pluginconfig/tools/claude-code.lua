local claude_ok, claude_code = pcall(require, "claude-code")
if not claude_ok then
	vim.notify("claude-code.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

claude_code.setup({
	window = {
		split_ratio = 0.35,
		position = "botright",
		enter_insert = true,
		hide_numbers = true,
		hide_signcolumn = true,
	},
	refresh = {
		enable = true,
		updatetime = 100,
		timer_interval = 1000,
		show_notifications = false,
	},
	git = {
		use_git_root = true,
	},
	shell = {
		separator = "&&",
		pushd_cmd = "pushd",
		popd_cmd = "popd",
	},
	command = "claude",
	command_variants = {
		continue = "--continue",
		resume = "--resume",
		verbose = "--verbose",
	},
	keymaps = {
		toggle = {
			normal = "<C-,>",
			terminal = "<C-,>",
			variants = {
				continue = "<leader>cC",
				verbose = "<leader>cV",
			},
		},
		window_navigation = true,
		scrolling = true,
	},
})


local which_key_ok, which_key = pcall(require, "which-key")
if which_key_ok then
	which_key.add({
		{ "<leader>c", group = "Claude Code" },
		{ "<leader>cc", desc = "ターミナルトグル" },
		{ "<leader>cC", desc = "会話を継続" },
		{ "<leader>cV", desc = "詳細モード" },
		{ "<leader>cR", desc = "会話を選択して再開" },
	})
end

vim.api.nvim_create_augroup("ClaudeCodeOptimization", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = "ClaudeCodeOptimization",
	pattern = "*claude*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		
		local opts = { buffer = true, silent = true }
		vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
		vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
		vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
		vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
		vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)
	end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = "ClaudeCodeOptimization",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})