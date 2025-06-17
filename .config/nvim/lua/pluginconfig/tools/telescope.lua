local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local utils = require("telescope.utils")
local conf = require("telescope.config").values
local telescope_builtin = require("telescope.builtin")
local Path = require("plenary.path")

-- Load telescope extensions (only if plugins are available)
local function safe_load_extension(extension_name)
	local ok, _ = pcall(require("telescope").load_extension, extension_name)
	if not ok then
		vim.notify("Telescope extension '" .. extension_name .. "' not available", vim.log.levels.WARN)
	end
end

safe_load_extension("flutter")

local telescope_opts = {
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		file_ignore_patterns = { "node_modules/*", ".git/*" },
		mappings = {
			-- map actions.which_key to <C-h> (default: <C-/>)
			-- actions.which_key shows the mappings for your picker,
			-- e.g. git_{create, delete, ...}_branch for the git_branches picker
			n = {
				["<C-t>"] = require("telescope.actions.layout").toggle_preview,
			},
			i = {
				["<C-t>"] = require("telescope.actions.layout").toggle_preview,
				["<C-j>"] = require("telescope.actions").move_selection_next,
				["<C-k>"] = require("telescope.actions").move_selection_previous,
				["<Tab>"] = require("telescope.actions").toggle_selection
					+ require("telescope.actions").move_selection_next,
			},
		},
	},
	pickers = {
		live_grep = {
			additional_args = function(opts)
				return { "--hidden" }
			end,
		},
		-- Default configuration for builtin pickers goes here:
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
	},
	extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
		project = {
			base_dirs = (function()
				local dirs = {}
				local function file_exists(fname)
					local stat = vim.loop.fs_stat(vim.fn.expand(fname))
					return (stat and stat.type) or false
				end

				if file_exists("~/.ghq") then
					dirs[#dirs + 1] = { "~/.ghq", max_depth = 5 }
				end
				if file_exists("~/Workspace") then
					dirs[#dirs + 1] = { "~/Workspace", max_depth = 3 }
				end
				if #dirs == 0 then
					return nil
				end
				return dirs
			end)(),
		},
	},
}

require("telescope").setup(telescope_opts)



-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope find_files hidden=true<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fm", "<cmd>Telescope oldfiles<CR>", { noremap = true, silent = false })

-- git
vim.api.nvim_set_keymap(
	"n",
	"<leader>gs",
	"<Cmd>lua require('telescope.builtin').git_status()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>gc",
	"<Cmd>lua require('telescope.builtin').git_commits()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>gC",
	"<Cmd>lua require('telescope.builtin').git_bcommits()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>gv",
	"<Cmd>lua require('telescope.builtin').git_branches()<CR>",
	{ noremap = true, silent = true }
)

-- Flutter
vim.keymap.set("n", "<leader>flc", "<cmd>Telescope flutter commands<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>flv", "<cmd>Telescope flutter fvm<cr>", { noremap = true, silent = false })


-- todo-comments
vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<cr>", { noremap = true, silent = false })

-- command history
vim.api.nvim_set_keymap("n", "<leader>-", "<Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "<C-t>", "<BS><Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
