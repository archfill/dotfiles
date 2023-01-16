require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.norg.dirman"] = {
			config = {
				workspaces = {
					work = "~/neorg/work",
				},
			},
		},
		["core.norg.concealer"] = {},
		-- ["core.norg.completion"] = {
		-- 	config = {
		-- 		engine = "nvim-cmp",
		-- 	},
		-- },
	},
})
