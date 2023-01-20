-- local function is_available_navic()
-- 	local ok, _ = pcall(require, "nvim-navic")
-- 	if not ok then
-- 		return false
-- 	end
-- 	return require("nvim-navic").is_available()
-- end

local function is_available_lspsaga()
	local ok, _ = pcall(require, "lspsaga")
	if not ok then
		return false
	end
	return true
end

local function esc(x)
	return (
		x:gsub("%%", "%%%%")
			:gsub("^%^", "%%^")
			:gsub("%$$", "%%$")
			:gsub("%(", "%%(")
			:gsub("%)", "%%)")
			:gsub("%.", "%%.")
			:gsub("%[", "%%[")
			:gsub("%]", "%%]")
			:gsub("%*", "%%*")
			:gsub("%+", "%%+")
			:gsub("%-", "%%-")
			:gsub("%?", "%%?")
	)
end

local function get_cwd()
	local cwd = vim.fn.getcwd()
	local git_dir = require("lualine.components.branch.git_branch").find_git_dir(cwd)
	local root = vim.fs.dirname(git_dir)
	if cwd == root then
		return ""
	end
	local d, n = string.gsub(cwd, esc(root) .. "/", "")
	if n == 0 and d == nil then
		return ""
	end
	return "(./" .. d .. ")"
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {},
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{ "filename", path = 1 },
			{ get_cwd },
			{ 'require("lspsaga.symbolwinbar"):get_winbar()', cond = is_available_lspsaga },
		},
		lualine_x = {
			-- {
			-- 	require("noice").api.status.message.get_hl,
			-- 	cond = require("noice").api.status.message.has,
			-- },
			{
				require("noice").api.status.command.get,
				cond = require("noice").api.status.command.has,
				color = { fg = "#ff9e64" },
			},
			{
				require("noice").api.status.mode.get,
				cond = require("noice").api.status.mode.has,
				color = { fg = "#ff9e64" },
			},
			{
				require("noice").api.status.search.get,
				cond = require("noice").api.status.search.has,
				color = { fg = "#ff9e64" },
			},
			"encoding",
			"fileformat",
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
})
