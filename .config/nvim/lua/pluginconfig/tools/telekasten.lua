local home = vim.fn.expand("~/zettelkasten")
local templ_dir = home .. "/templates"
require("telekasten").setup({
	home = home,

	-- if true, telekasten will be enabled when opening a note within the configured home
	take_over_my_home = true,

	-- auto-set telekasten filetype: if false, the telekasten filetype will not be used
	--                               and thus the telekasten syntax will not be loaded either
	auto_set_filetype = true,

	-- auto-set telekasten syntax: if false, the telekasten syntax will not be used
	-- this syntax setting is independent from auto-set filetype
	auto_set_syntax = true,

	dailies = home .. "/" .. "daily",
	weeklies = home .. "/" .. "weekly",
	templates = templ_dir,

	-- image (sub)dir for pasting
	-- dir name (absolute path or subdir name)
	-- or nil if pasted images shouldn't go into a special subdir
	image_subdir = "img",

	-- markdown file extension
	extension = ".md",

	-- Generate note filenames. One of:
	-- "title" (default) - Use title if supplied, uuid otherwise
	-- "uuid" - Use uuid
	-- "uuid-title" - Prefix title by uuid
	-- "title-uuid" - Suffix title with uuid
	new_note_filename = "title",

	--[[ file UUID type
    - "rand"
    - string input for os.date()
    - or custom lua function that returns a string
   --]]
	uuid_type = "%Y%m%d%H%M",
	-- UUID separator
	uuid_sep = "-",

	-- if not nil, this string replaces spaces in the title when generating filenames
	filename_space_subst = nil,

	-- following a link to a non-existing note will create it
	follow_creates_nonexisting = true,
	dailies_create_nonexisting = true,
	weeklies_create_nonexisting = true,

	-- skip telescope prompt for goto_today and goto_thisweek
	journal_auto_open = false,

	-- template for new notes (new_note, follow_link)
	template_new_note = templ_dir .. "/new_note.md",

	-- template for newly created daily notes (goto_today)
	template_new_daily = templ_dir .. "/daily.md",

	-- template for newly created weekly notes (goto_thisweek)
	template_new_weekly = templ_dir .. "/weekly.md",

	-- image link style
	-- wiki:     ![[image name]]
	-- markdown: ![](image_subdir/xxxxx.png)
	image_link_style = "markdown",

	-- default sort option: 'filename', 'modified'
	sort = "filename",

	-- integrate with calendar-vim
	plug_into_calendar = true,
	calendar_opts = {
		-- calendar week display mode: 1 .. 'WK01', 2 .. 'WK 1', 3 .. 'KW01', 4 .. 'KW 1', 5 .. '1'
		weeknm = 4,
		-- use monday as first day of week: 1 .. true, 0 .. false
		calendar_monday = 1,
		-- calendar mark: where to put mark for marked days: 'left', 'right', 'left-fit'
		calendar_mark = "left-fit",
	},

	-- telescope actions behavior
	close_after_yanking = false,
	insert_after_inserting = true,

	-- tag notation: '#tag', ':tag:', 'yaml-bare'
	tag_notation = "#tag",

	-- command palette theme: dropdown (window) or ivy (bottom panel)
	command_palette_theme = "ivy",

	-- tag list theme:
	-- get_cursor: small tag list at cursor; ivy and dropdown like above
	show_tags_theme = "ivy",

	-- when linking to a note in subdir/, create a [[subdir/title]] link
	-- instead of a [[title only]] link
	subdirs_in_links = true,

	-- template_handling
	-- What to do when creating a new note via `new_note()` or `follow_link()`
	-- to a non-existing note
	-- - prefer_new_note: use `new_note` template
	-- - smart: if day or week is detected in title, use daily / weekly templates (default)
	-- - always_ask: always ask before creating a note
	template_handling = "smart",

	-- path handling:
	--   this applies to:
	--     - new_note()
	--     - new_templated_note()
	--     - follow_link() to non-existing note
	--
	--   it does NOT apply to:
	--     - goto_today()
	--     - goto_thisweek()
	--
	--   Valid options:
	--     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
	--              all other ones in home, except for notes/with/subdirs/in/title.
	--              (default)
	--
	--     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
	--                    except for notes with subdirs/in/title.
	--
	--     - same_as_current: put all new notes in the dir of the current note if
	--                        present or else in home
	--                        except for notes/with/subdirs/in/title.
	new_note_location = "smart",

	-- should all links be updated when a file is renamed
	rename_update_links = true,

	-- how to preview media files
	-- "telescope-media-files" if you have telescope-media-files.nvim installed
	-- "catimg-previewer" if you have catimg installed
	media_previewer = "catimg-previewer",

	-- A customizable fallback handler for urls.
	follow_url_fallback = nil,
})

vim.keymap.set("n", "<Leader>zf", "<Cmd>lua require('telekasten').find_notes()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<Leader>zd",
	"<Cmd>lua require('telekasten').find_daily_notes()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<Leader>zg",
	"<Cmd>lua require('telekasten').search_notes()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<Leader>zz", "<Cmd>lua require('telekasten').follow_link()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>zT", "<Cmd>lua require('telekasten').goto_today()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>zW",
	"<Cmd>lua require('telekasten').goto_thisweek()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zw",
	"<Cmd>lua require('telekasten').find_weekly_notes()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>zn", "<Cmd>lua require('telekasten').new_note()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>zN",
	"<Cmd>lua require('telekasten').new_templated_note()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zy",
	"<Cmd>lua require('telekasten').yank_notelink()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zc",
	"<Cmd>lua require('telekasten').show_calendar()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>zC", "<Cmd>CalendarT<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>zi",
	"<Cmd>lua require('telekasten').paste_img_and_link()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>zt", "<Cmd>lua require('telekasten').toggle_todo()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>zb",
	"<Cmd>lua require('telekasten').show_backlinks()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zF",
	"<Cmd>lua require('telekasten').find_friends()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zI",
	"<Cmd>lua require('telekasten').insert_img_link({ i=true })<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>zp", "<Cmd>lua require('telekasten').preview_img()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"<leader>zm",
	"<Cmd>lua require('telekasten').browse_media()<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>za", "<Cmd>lua require('telekasten').show_tags()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>#", "<Cmd>a require('telekasten').show_tags()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>zr", "<Cmd>lua require('telekasten').rename_note()<CR>", { noremap = true, silent = true })

-- on hesitation, bring up the panel
vim.keymap.set("n", "<Leader>zp", "<Cmd>lua require('telekasten').panel()<CR>", { noremap = true, silent = true })

-- we could define [[ in **insert mode** to call insert link
-- inoremap [[ <cmd>:lua require('telekasten').insert_link()<CR>
-- alternatively: leader [
vim.keymap.set(
	"n",
	"<leader>[",
	"<Cmd>:lua require('telekasten').insert_link({ i=true })<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader>zt",
	"<Cmd>:lua require('telekasten').toggle_todo({ i=true })<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"<leader># ",
	"<Cmd>lua require('telekasten').show_tags({i = true})<cr>",
	{ noremap = true, silent = true }
)

-- ----- the following are for syntax-coloring [[links]] and ==highlighted text==
-- ----- (see the section about coloring in README.md)

-- for gruvbox
-- vim.cmd("hi tklink ctermfg=72 guifg=#689d6a cterm=bold,underline gui=bold,underline")
-- vim.cmd("hi tkBrackets ctermfg=gray guifg=gray")

-- real yellow
vim.cmd("hi tkHighlight ctermbg=yellow ctermfg=darkred cterm=bold guibg=yellow guifg=darkred gui=bold")
-- gruvbox
-- hi tkHighlight ctermbg=214 ctermfg=124 cterm=bold guibg=#fabd2f guifg=#9d0006 gui=bold

vim.cmd("hi link CalNavi CalRuler")
vim.cmd("hi tkTagSep ctermfg=gray guifg=gray")
vim.cmd("hi tkTag ctermfg=175 guifg=#d3869B")
