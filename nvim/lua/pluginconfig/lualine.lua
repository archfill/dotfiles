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

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {},
		always_divide_middle = true,
		globalstatus = false,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename", { 'require("lspsaga.symbolwinbar"):get_winbar()', cond = is_available_lspsaga } },
		lualine_x = { "encoding", "fileformat", "filetype" },
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
