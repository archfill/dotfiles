require("telescope").load_extension("frecency")
-- require("telescope").load_extension("packer")
require("telescope").load_extension("flutter")
require("telescope").load_extension("memo")
require("telescope").load_extension("luasnip")

require("telescope").setup({
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		file_ignore_patterns = { "node_modules/*" },
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
		frecency = {
			db_root = vim.fn.stdpath("state"),
			ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
			db_safe_mode = false,
			auto_validate = true,
		},
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
})

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope find_files hidden=true<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = false })

-- frecency
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope frecency<cr>", { noremap = true, silent = false })

-- Flutter
vim.keymap.set("n", "<leader>flc", "<cmd>Telescope flutter commands<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>flv", "<cmd>Telescope flutter fvm<cr>", { noremap = true, silent = false })

-- memo
vim.keymap.set("n", "<leader>ml", "<cmd>Telescope memo list<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>mg", "<cmd>Telescope memo live_grep<cr>", { noremap = true, silent = false })

-- luasnip
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope luasnip<cr>", { noremap = true, silent = false })

-- todo-comments
vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<cr>", { noremap = true, silent = false })
