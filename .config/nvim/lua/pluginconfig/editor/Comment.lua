require("Comment").setup({
	padding = true,
	sticky = true,
	ignore = nil,
	toggler = {
		line = LK_COMMENT .. "cc",
		block = LK_COMMENT .. "bc",
	},
	opleader = {
		line = LK_COMMENT .. "c",
		block = LK_COMMENT .. "b",
	},
	extra = {
		above = LK_COMMENT .. "cO",
		below = LK_COMMENT .. "co",
		eol = LK_COMMENT .. "cA",
	},
	mappings = {
		basic = true,
		extra = true,
	},
	pre_hook = nil,
	post_hook = nil,
})
