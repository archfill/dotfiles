-- ================================================================
-- TOOLS: Telekasten - Zettelkasten Note Management System
-- ================================================================

return {
  -- Telekasten: Zettelkasten方式ノート管理システム
  {
    "renerocksai/telekasten.nvim",
    keys = {
      -- ===== CORE NOTE OPERATIONS =====
      { "<leader>zf", "<cmd>lua require('telekasten').find_notes()<cr>", desc = "Find Notes" },
      { "<leader>zd", "<cmd>lua require('telekasten').find_daily_notes()<cr>", desc = "Find Daily Notes" },
      { "<leader>zg", "<cmd>lua require('telekasten').search_notes()<cr>", desc = "Search Notes" },
      { "<leader>zt", "<cmd>lua require('telekasten').goto_today()<cr>", desc = "Go to Today" },
      { "<leader>zw", "<cmd>lua require('telekasten').find_weekly_notes()<cr>", desc = "Find Weekly Notes" },
      { "<leader>zW", "<cmd>lua require('telekasten').goto_thisweek()<cr>", desc = "Go to This Week" },
      
      -- ===== NOTE CREATION =====
      { "<leader>zn", "<cmd>lua require('telekasten').new_note()<cr>", desc = "New Note" },
      { "<leader>zN", "<cmd>lua require('telekasten').new_templated_note()<cr>", desc = "New Templated Note" },
      { "<leader>zz", "<cmd>lua require('telekasten').follow_link()<cr>", desc = "Follow Link" },
      
      -- ===== NOTE UTILITIES =====
      { "<leader>zy", "<cmd>lua require('telekasten').yank_notelink()<cr>", desc = "Yank Note Link" },
      { "<leader>zr", "<cmd>lua require('telekasten').rename_note()<cr>", desc = "Rename Note" },
      { "<leader>zb", "<cmd>lua require('telekasten').show_backlinks()<cr>", desc = "Show Backlinks" },
      { "<leader>zF", "<cmd>lua require('telekasten').find_friends()<cr>", desc = "Find Friends" },
      
      -- ===== MEDIA & LINKS =====
      { "<leader>zi", "<cmd>lua require('telekasten').paste_img_and_link()<cr>", desc = "Paste Image and Link" },
      { "<leader>zI", "<cmd>lua require('telekasten').insert_img_link({ i=true })<cr>", desc = "Insert Image Link" },
      { "<leader>zp", "<cmd>lua require('telekasten').preview_img()<cr>", desc = "Preview Image" },
      { "<leader>zm", "<cmd>lua require('telekasten').browse_media()<cr>", desc = "Browse Media" },
      { "<leader>[", "<cmd>lua require('telekasten').insert_link({ i=true })<cr>", desc = "Insert Link" },
      
      -- ===== TAGS & CALENDAR =====
      { "<leader>za", "<cmd>lua require('telekasten').show_tags()<cr>", desc = "Show Tags" },
      { "<leader>#", "<cmd>lua require('telekasten').show_tags()<cr>", desc = "Show Tags" },
      { "<leader>zc", "<cmd>lua require('telekasten').show_calendar()<cr>", desc = "Show Calendar" },
      { "<leader>zC", "<cmd>CalendarT<cr>", desc = "Calendar Toggle" },
      
      -- ===== TODO MANAGEMENT =====
      { "<leader>zt", "<cmd>lua require('telekasten').toggle_todo()<cr>", desc = "Toggle Todo" },
      
      -- ===== CONTROL PANEL =====
      { "<leader>zp", "<cmd>lua require('telekasten').panel()<cr>", desc = "Telekasten Panel" },
    },
    cmd = { "Telekasten" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      -- Optional calendar integration
      -- "mattn/calendar-vim",
    },
    config = function()
      local home = vim.fn.expand("~/zettelkasten")
      local templ_dir = home .. "/templates"
      
      require("telekasten").setup({
        home = home,
        
        -- if true, telekasten will be enabled when opening a note within the configured home
        take_over_my_home = true,
        
        -- auto-set telekasten filetype: if false, the telekasten filetype will not be used
        auto_set_filetype = true,
        
        -- auto-set telekasten syntax: if false, the telekasten syntax will not be used
        auto_set_syntax = true,
        
        dailies = home .. "/" .. "daily",
        weeklies = home .. "/" .. "weekly",
        templates = templ_dir,
        
        -- image (sub)dir for pasting
        image_subdir = "img",
        
        -- markdown file extension
        extension = ".md",
        
        -- Generate note filenames. One of:
        -- "title" (default) - Use title if supplied, uuid otherwise
        -- "uuid" - Use uuid
        -- "uuid-title" - Prefix title by uuid
        -- "title-uuid" - Suffix title with uuid
        new_note_filename = "title",
        
        -- file UUID type
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
      
      -- Custom highlighting for Zettelkasten
      vim.cmd("hi tkHighlight ctermbg=yellow ctermfg=darkred cterm=bold guibg=yellow guifg=darkred gui=bold")
      vim.cmd("hi link CalNavi CalRuler")
      vim.cmd("hi tkTagSep ctermfg=gray guifg=gray")
      vim.cmd("hi tkTag ctermfg=175 guifg=#d3869B")
    end,
  },
}