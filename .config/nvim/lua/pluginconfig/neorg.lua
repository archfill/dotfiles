-- require("packer").loader("nvim-cmp")

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
		-- ["core.integrations.telescope"] = {},
		["core.norg.concealer"] = {
			config = {
				icon_preset = "diamond",
			},
		},
		["core.norg.completion"] = {
			config = {
				engine = "nvim-cmp",
			},
		},
	},
})
