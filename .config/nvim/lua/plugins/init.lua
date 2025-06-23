-- ================================================================
-- LAZVIM-STANDARD PLUGIN LOADER
-- ================================================================
-- This file automatically loads all plugins from the categorized directories
-- following LazyVim-Based Dotfiles Standards (CLAUDE.md Rules 1-10)

-- Load global keymaps first
require("core.global-keymap")

-- Define plugin categories in priority order
local plugin_categories = {
	-- Priority 1000: Core essentials (colorschemes, fundamental UI)
	"core",

	-- Priority 800: Interface components
	"ui",

	-- Priority 500: Text editing fundamentals
	"editor",

	-- Keys/Cmd: Development tools (on-demand loading)
	"tools",

	-- Event: Language servers and completion
	"lsp",

	-- Filetype: Language-specific configurations
	"lang",

	-- Event: Code assistance (formatting, linting, snippets)
	"coding",

	-- Tools: Git integration
	"git",

	-- VeryLazy: Utility plugins
	"util",

	-- Extras: Optional features system
	"optional",
}

-- Function to safely require plugin files
local function load_plugin_category(category)
	local category_path = "plugins." .. category

	-- Get all lua files in the category directory
	local plugin_files =
		vim.split(vim.fn.glob(vim.fn.stdpath("config") .. "/lua/plugins/" .. category .. "/*.lua"), "\n")

	local category_plugins = {}

	for _, file in ipairs(plugin_files) do
		if file ~= "" then
			local filename = vim.fn.fnamemodify(file, ":t:r")
			local module_name = category_path .. "." .. filename

			local success, plugin_config = pcall(require, module_name)
			if success and type(plugin_config) == "table" then
				-- Ensure plugin_config is an array of plugins
				for _, plugin in ipairs(plugin_config) do
					table.insert(category_plugins, plugin)
				end
			else
				vim.notify("Failed to load plugin module: " .. module_name, vim.log.levels.WARN)
			end
		end
	end

	return category_plugins
end

-- Load all plugins from all categories
local all_plugins = {}

for _, category in ipairs(plugin_categories) do
	local category_plugins = load_plugin_category(category)
	vim.list_extend(all_plugins, category_plugins)
end

return all_plugins

