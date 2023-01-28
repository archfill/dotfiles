require("translate").setup({
	default = {
		command = "google",
	},
	preset = {
		output = {
			split = {
				append = true,
			},
		},
	},
})

local mappings = {
	f = "-output=floating",
	s = "-output=split",
	i = "-output=insert",
	r = "-output=replace",
	c = "-comment",
}

for k, v in pairs(mappings) do
	vim.keymap.set({ "n", "x" }, "mj" .. k, ("<Cmd>Translate JA -source=EN %s<CR><Esc>"):format(v))
	vim.keymap.set({ "n", "x" }, "me" .. k, ("<Cmd>Translate EN -source=JA %s<CR><Esc>"):format(v))
end
