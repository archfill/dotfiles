-- memo config
--
-- memodir = "${HOME}/Nextcloud/Notes/my"
-- editor = "nvim"
-- column = 20
-- width = 0
-- selectcmd = "fzf"
-- grepcmd = "grep -nH ${PATTERN} ${FILES}"
-- memotemplate = ""
-- assetsdir = "."
-- pluginsdir = "/Users/chill-rf/.config/memo/plugins"
-- templatedirfile = ""
-- templatebodyfile = ""

-- config
vim.g.memolist_path = "~/.memolist/memo"
vim.g.memolist_memo_suffix = "md"
vim.g.memolist_fzf = 1
vim.g.memolist_template_dir_path = "~/.memolist/memotemplates"

-- keymap
vim.keymap.set("n", "<leader>mn", "<cmd>MemoNew<cr>", { noremap = true, silent = false })
