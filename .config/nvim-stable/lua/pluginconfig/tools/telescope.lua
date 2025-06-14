local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local utils = require("telescope.utils")
local conf = require("telescope.config").values
local telescope_builtin = require("telescope.builtin")
local Path = require("plenary.path")

require("telescope").load_extension("frecency")
require("telescope").load_extension("flutter")
require("telescope").load_extension("memo")
require("telescope").load_extension("luasnip")
require("telescope").load_extension("ui-select")

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
		frecency = {
			show_scores = false,
			show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
			disable_devicons = false,
			workspaces = {
				["conf"] = "/home/archfill/.config",
				["data"] = "/home/archfill/.local/share",
				["project"] = "/home/archfill/Projects",
			},
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
}

require("telescope").setup(telescope_opts)

local function join_uniq(tbl, tbl2)
	local res = {}
	local hash = {}
	for _, v1 in ipairs(tbl) do
		res[#res + 1] = v1
		hash[v1] = true
	end

	for _, v in pairs(tbl2) do
		if not hash[v] then
			table.insert(res, v)
		end
	end
	return res
end

telescope_builtin.my_mru = function(opts)
	local o = vim.tbl_extend("force", telescope_opts.extensions.frecency, opts or {})
	local frecency = require("telescope").extensions.frecency
	local results_mru_cur = frecency.query({ workspace = vim.uv.cwd() })

	local show_untracked = vim.F.if_nil(o.show_untracked, true)
	local recurse_submodules = vim.F.if_nil(o.recurse_submodules, false)
	if show_untracked and recurse_submodules then
		error("Git does not suppurt both --others and --recurse-submodules")
	end
	local cmd = {
		"git",
		"ls-files",
		"--exclude-standard",
		"--cached",
		show_untracked and "--others" or nil,
		recurse_submodules and "--recurse-submodules" or nil,
	}
	local results_git = utils.get_os_command_output(cmd)
	local results = join_uniq(results_mru_cur, results_git)

	pickers
		.new(opts, {
			prompt_title = "MRU",
			finder = finders.new_table({
				results = results,
				entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
			}),
			sorter = conf.file_sorter(opts),
			previewer = conf.file_previewer(opts),
		})
		:find()
end

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope find_files hidden=true<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>fm", "<cmd>Telescope my_mru<CR>", { noremap = true, silent = false })

-- frecency
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope frecency<cr>", { noremap = true, silent = false })

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

-- memo
vim.keymap.set("n", "<leader>ml", "<cmd>Telescope memo list<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>mg", "<cmd>Telescope memo live_grep<cr>", { noremap = true, silent = false })

-- luasnip
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope luasnip<cr>", { noremap = true, silent = false })

-- todo-comments
vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<cr>", { noremap = true, silent = false })

-- command history
vim.api.nvim_set_keymap("n", "<leader>-", "<Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "<C-t>", "<BS><Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
