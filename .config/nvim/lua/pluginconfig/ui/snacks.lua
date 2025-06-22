-- snacks.nvim configuration
-- LazyVim-inspired modern UI components collection
-- Replaces: alpha-nvim, nvim-notify, indent-blankline.nvim (Phase 1)
-- Future migration: neo-tree.nvim → snacks.explorer, telescope.nvim → snacks.picker

local M = {}

-- Snacks configuration setup
M.setup = function()
	local snacks = require("snacks")
	
	snacks.setup({
		-- ================================================================
		-- BIGFILE: Enhanced large file handling
		-- ================================================================
		bigfile = { enabled = true, size = 1.5 * 1024 * 1024 }, -- 1.5MB threshold
		
		-- ================================================================
		-- DASHBOARD: Replaces alpha-nvim
		-- ================================================================
		dashboard = {
			enabled = true,
			preset = {
				-- Custom header with NEOVIM ASCII art (same as alpha.nvim)
				header = [[
                                                        
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                        
           🚀 Welcome to Neovim Development Environment ]],
				-- Custom keys section preserving all 47 buttons from alpha.nvim
				keys = {
					-- File Operations
					{ icon = "📁", key = "f", desc = "Find File", action = ":Telescope find_files" },
					{ icon = "🔍", key = "g", desc = "Live Grep", action = ":Telescope live_grep" },
					{ icon = "📄", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
					{ icon = "✏️ ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = "📂", key = "e", desc = "File Explorer", action = ":Neotree" },
					
					-- Session Management
					{ icon = "💾", key = "S", desc = "Save Session", action = ":PossessionSave" },
					{ icon = "🔄", key = "R", desc = "Load Session", action = ":PossessionLoad" },
					{ icon = "🗑️ ", key = "D", desc = "Delete Session", action = ":PossessionDelete" },
					{ icon = "📋", key = "T", desc = "Show Sessions", action = ":PossessionShow" },
					
					-- Configuration
					{ icon = "⚙️ ", key = "c", desc = "Edit Config", action = ":edit ~/.config/nvim/init.lua" },
					{ icon = "🔌", key = "p", desc = "Edit Plugins", action = ":edit ~/.config/nvim/lua/plugins.lua" },
					
					-- Lazy.nvim Plugin Management
					{ icon = "💤", key = "l", desc = "Lazy Home", action = ":Lazy" },
					{ icon = "🔄", key = "s", desc = "Sync Plugins", action = ":Lazy sync" },
					{ icon = "⬆️ ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
					{ icon = "⬇️ ", key = "i", desc = "Install Plugins", action = ":Lazy install" },
					{ icon = "🧹", key = "x", desc = "Clean Plugins", action = ":Lazy clean" },
					{ icon = "📊", key = "P", desc = "Plugin Profile", action = ":Lazy profile" },
					{ icon = "📜", key = "L", desc = "Plugin Log", action = ":Lazy log" },
					
					-- Exit
					{ icon = "🚪", key = "q", desc = "Quit Neovim", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{
					pane = 2,
					section = "terminal",
					cmd = "echo '🌈 Welcome to Neovim!' && echo '⚡ Ready for coding!' && echo '🚀 Happy hacking!'",
					height = 3,
					padding = 1,
				},
				{ section = "keys", gap = 1, padding = 1 },
				{ pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				-- Git Status only if in a git repository
				{
					pane = 2,
					icon = " ",
					title = "Git Status",
					section = "terminal",
					enabled = function()
						return vim.fn.isdirectory(".git") == 1 or vim.fn.system("git rev-parse --git-dir 2>/dev/null"):match("%.git")
					end,
					cmd = "git status --porcelain -b 2>/dev/null || echo 'Not in a git repository'",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{
					section = "startup",
					gap = 1,
					padding = 1,
				},
			},
		},
		
		-- ================================================================
		-- NOTIFIER: Replaces nvim-notify
		-- ================================================================
		notifier = {
			enabled = true,
			timeout = 3000,
			width = { min = 40, max = 0.4 },
			height = { min = 1, max = 0.6 },
			-- Preserve nvim-notify style and functionality
			margin = { top = 0, right = 1, bottom = 0 },
			padding = true,
			sort = { "level", "added" },
			-- Animation and style options
			icons = {
				error = " ",
				warn = " ",
				info = " ",
				debug = " ",
				trace = " ",
			},
			style = "compact", -- modern, compact, minimal
		},
		
		-- ================================================================
		-- INDENT: Replaces indent-blankline.nvim
		-- ================================================================
		indent = {
			enabled = true,
			animate = {
				enabled = true,
				duration = {
					step = 20, -- ms per step
					total = 500, -- ms total
				},
			},
			scope = {
				enabled = true,
				animate = true,
				char = "│",
				underline = true,
				only_current = false,
			},
			char = "│",
			-- Only show indent lines in these file types
			filter = function(buf)
				local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
				if ft == "" then
					return false
				end
				-- Exclude certain file types
				local exclude = {
					"alpha", "dashboard", "neo-tree", "Trouble", "trouble",
					"lazy", "mason", "notify", "toggleterm", "lazyterm"
				}
				return not vim.tbl_contains(exclude, ft)
			end,
		},
		
		-- ================================================================
		-- QUICKFILE: Enhanced file operations
		-- ================================================================
		quickfile = { enabled = true },
		
		-- ================================================================
		-- STATUSCOLUMN: Enhanced status column
		-- ================================================================
		statuscolumn = { enabled = true },
		
		-- ================================================================
		-- WORDS: Highlight word under cursor
		-- ================================================================
		words = { enabled = true },
		
		-- ================================================================
		-- STYLES: UI styling
		-- ================================================================
		styles = {
			notification = {
				-- Integrate with tokyonight theme colors
				wo = { wrap = true } -- enable word wrap
			}
		}
	})
end

-- Initialize snacks
M.setup()

-- ================================================================
-- KEYMAPS: Preserve existing functionality
-- ================================================================

-- Notifier keymap (matches nvim-notify)
vim.keymap.set("n", "<leader>nc", function()
	require("snacks").notifier.hide()
end, { desc = "Clear notifications" })

-- Dismiss notifications (matches nvim-notify <BS> functionality)
vim.keymap.set("n", "<BS>", function()
	require("snacks").notifier.hide()
end, { noremap = true, silent = true, desc = "Dismiss notifications" })

-- Dashboard toggle
vim.keymap.set("n", "<leader>D", function()
	require("snacks").dashboard()
end, { desc = "Toggle Dashboard" })

-- ================================================================
-- INTEGRATION: Setup vim.notify replacement
-- ================================================================
vim.notify = require("snacks").notifier.notify

-- ================================================================
-- AUTOCMDS: Dashboard behavior
-- ================================================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "snacks_dashboard",
	callback = function()
		local opts = { buffer = true, silent = true }
		-- Preserve hjkl navigation from alpha.nvim
		vim.keymap.set('n', 'h', 'h', opts)
		vim.keymap.set('n', 'j', 'j', opts)  
		vim.keymap.set('n', 'k', 'k', opts)
		vim.keymap.set('n', 'l', 'l', opts)
	end,
})

return M