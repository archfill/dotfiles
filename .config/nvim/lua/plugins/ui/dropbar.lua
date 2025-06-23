-- ================================================================
-- UI: Dropbar - IDE-Style Breadcrumbs Navigation
-- ================================================================
-- Modern breadcrumb navigation with beautiful Catppuccin integration

return {
  {
    "Bekaboo/dropbar.nvim",
    priority = 600,           -- nvim-cokeline (700) より後にロード
    event = "BufReadPost",    -- VeryLazy → BufReadPost で同期化
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- ================================================================
      -- GENERAL SETTINGS - Performance & Behavior (Updated API)
      -- ================================================================
      -- general設定はbar設定に移行済み
      
      -- ================================================================
      -- ICONS CONFIGURATION - Beautiful Nerd Font Icons
      -- ================================================================
      icons = {
        kinds = {
          symbols = {
            Array = "󰅪 ",
            Boolean = " ",
            BreakStatement = "󰙧 ",
            Call = "󰃷 ",
            CaseStatement = "󱃙 ",
            Class = " ",
            Color = "󰏘 ",
            Constant = "󰏿 ",
            Constructor = " ",
            ContinueStatement = "→ ",
            Copilot = " ",
            Declaration = "󰙠 ",
            Delete = "󰩺 ",
            DoStatement = "󰑖 ",
            Enum = " ",
            EnumMember = " ",
            Event = " ",
            Field = " ",
            File = "󰈔 ",
            Folder = "󰉋 ",
            ForStatement = "󰑖 ",
            Function = "󰊕 ",
            H1Marker = "󰉫 ", -- Markdown
            H2Marker = "󰉬 ",
            H3Marker = "󰉭 ",
            H4Marker = "󰉮 ",
            H5Marker = "󰉯 ",
            H6Marker = "󰉰 ",
            Identifier = "󰀫 ",
            IfStatement = "󰇉 ",
            Interface = " ",
            Keyword = "󰌋 ",
            List = "󰅪 ",
            Log = "󰦪 ",
            Lsp = " ",
            Macro = "󰁌 ",
            MarkdownH1 = "󰉫 ",
            MarkdownH2 = "󰉬 ",
            MarkdownH3 = "󰉭 ",
            MarkdownH4 = "󰉮 ",
            MarkdownH5 = "󰉯 ",
            MarkdownH6 = "󰉰 ",
            Method = "󰊕 ",
            Module = "󰏗 ",
            Namespace = "󰅩 ",
            Null = "󰢤 ",
            Number = "󰎠 ",
            Object = "󰅩 ",
            Operator = "󰆕 ",
            Package = "󰆦 ",
            Pair = "󰅪 ",
            Property = " ",
            Reference = "󰦾 ",
            Regex = " ",
            Repeat = "󰑖 ",
            Scope = "󰅩 ",
            Snippet = "󰩫 ",
            Specifier = "󰦪 ",
            Statement = "󰅩 ",
            String = "󰉾 ",
            Struct = " ",
            SwitchStatement = "󰺟 ",
            Terminal = " ",
            Text = " ",
            Type = " ",
            TypeParameter = "󰆩 ",
            Unit = " ",
            Value = "󰎠 ",
            Variable = "󰀫 ",
            WhileStatement = "󰑖 ",
          },
        },
        ui = {
          bar = {
            separator = "  ", -- 美しい区切り文字
            extends = "…",
          },
          menu = {
            separator = " ",
            indicator = " ",
          },
        },
      },
      
      -- ================================================================
      -- SYMBOL CONFIGURATION - Enhanced Display
      -- ================================================================
      symbol = {
        preview = {
          -- プレビュー設定
          reorient = function(_, range)
            local invisible = range['end'].line - vim.fn.line('w$') + 1
            if invisible > 0 then
              local view = vim.fn.winsaveview()
              view.topline = view.topline + invisible
              vim.fn.winrestview(view)
            end
          end,
        },
        jump = {
          reorient = function(_, range)
            local invisible = range['end'].line - vim.fn.line('w$') + 1
            if invisible > 0 then
              local view = vim.fn.winsaveview()
              view.topline = view.topline + invisible
              vim.fn.winrestview(view)
            end
          end,
        },
      },
      
      -- ================================================================
      -- BAR CONFIGURATION - Beautiful Appearance
      -- ================================================================
      bar = {
        hover = true, -- ホバー効果
        -- 新API: general.update_interval → bar.update_debounce
        update_debounce = 100, -- 高速更新 for スムーズなUX
        -- 新API: general.enable → bar.enable (競合回避強化)
        enable = function(buf, win, _)
          -- 厳密な競合チェックでnvim-cokeline干渉回避
          local buftype = vim.bo[buf].buftype
          local wintype = vim.fn.win_gettype(win)
          local winbar = vim.wo[win].winbar
          local bufname = vim.api.nvim_buf_get_name(buf)
          
          -- 基本条件チェック
          if buftype ~= "" then return false end
          if wintype ~= "" then return false end  
          if winbar ~= "" then return false end
          if bufname == "" then return false end
          
          -- nvim-cokeline バッファフィルター連携
          if buftype == "terminal" then return false end
          
          return true
        end,
        -- sources関数はconfig内で安全に設定される
        padding = {
          left = 1,
          right = 1,
        },
        pick = {
          pivots = 'etovxqpdwfghjklmnprbciuaosyzESHTNBCYPVXQRD',
        },
        truncate = true,
      },
      
      -- ================================================================
      -- MENU CONFIGURATION - Interactive Navigation
      -- ================================================================
      menu = {
        preview = false, -- パフォーマンス重視でプレビュー無効
        quick_navigation = true,
        entry = {
          padding = {
            left = 1,
            right = 1,
          },
        },
        -- 美しいスクロールバー
        scrollbar = {
          enable = true,
          background = true,
        },
        keymaps = {
          ['<LeftMouse>'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            local mouse = vim.fn.getmousepos()
            local clicked_menu = utils.menu.get({ win = mouse.winid })
            if clicked_menu then
              clicked_menu:click_at({ mouse.line, mouse.column - 1 }, nil, 1, 'l')
              return
            end
          end,
          ['<CR>'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
            if component then
              menu:click_on(component, nil, 1, 'l')
            end
          end,
          ['<MouseMove>'] = function()
            local menu = utils.menu.get_current()
            if not menu then
              return
            end
            local mouse = vim.fn.getmousepos()
            utils.menu.update_hover_hl(mouse.line)
          end,
          ['q'] = function()
            local menu = utils.menu.get_current()
            if menu then
              menu:close()
            end
          end,
          ['<Esc>'] = function()
            local menu = utils.menu.get_current()
            if menu then
              menu:close()
            end
          end,
        },
      },
      
      -- ================================================================
      -- SOURCES CONFIGURATION - Data Sources
      -- ================================================================
      sources = {
        path = {
          relative_to = function(_, _)
            return vim.fn.getcwd()
          end,
          modified = function(sym)
            return sym:merge({
              name = sym.name .. ' [+]',
              name_hl = 'DiffAdded',
            })
          end,
        },
        treesitter = {
          -- 新API: name_pattern → name_regex (vim regex)
          name_regex = '.*',
          valid_types = {
            'array',
            'boolean',
            'break_statement',
            'call',
            'case_statement',
            'class',
            'constant',
            'constructor',
            'continue_statement',
            'delete',
            'do_statement',
            'enum',
            'enum_member',
            'event',
            'field',
            'file',
            'folder',
            'for_statement',
            'function',
            'h1_marker',
            'h2_marker',
            'h3_marker',
            'h4_marker',
            'h5_marker',
            'h6_marker',
            'identifier',
            'if_statement',
            'interface',
            'keyword',
            'list',
            'log',
            'lsp',
            'macro',
            'markdown_h1',
            'markdown_h2',
            'markdown_h3',
            'markdown_h4',
            'markdown_h5',
            'markdown_h6',
            'method',
            'module',
            'namespace',
            'null',
            'number',
            'object',
            'operator',
            'package',
            'pair',
            'property',
            'reference',
            'regex',
            'repeat',
            'scope',
            'snippet',
            'specifier',
            'statement',
            'string',
            'struct',
            'switch_statement',
            'terminal',
            'text',
            'type',
            'type_parameter',
            'unit',
            'value',
            'variable',
            'while_statement',
          },
        },
        lsp = {
          request = {
            -- LSP request timeout
            ttl_init = 60,
            interval = 1000,
          },
        },
        markdown = {
          parse = {
            -- Markdown見出し解析
            look_ahead = 200,
          },
        },
      },
    },
    config = function(_, opts)
      -- ================================================================
      -- SAFE DEFERRED INITIALIZATION (競合回避)
      -- ================================================================
      
      -- nvim-cokeline初期化完了を待機して競合回避
      vim.defer_fn(function()
        -- nvim-cokeline ロード確認
        local cokeline_loaded = pcall(require, 'cokeline')
        if not cokeline_loaded then
          vim.notify("dropbar.nvim: Waiting for nvim-cokeline initialization...", vim.log.levels.INFO)
        end
        
        -- 安全なrequire with エラーハンドリング
        local ok_dropbar, dropbar = pcall(require, 'dropbar')
        if not ok_dropbar then
          vim.notify("dropbar.nvim: Main module not available", vim.log.levels.ERROR)
          return
        end
        
        local ok_utils, utils = pcall(require, 'dropbar.utils')
        local ok_sources, sources = pcall(require, 'dropbar.sources')
        
        if not ok_utils or not ok_sources then
          vim.notify("dropbar.nvim: Required modules not available", vim.log.levels.WARN)
          return
        end
      
      -- ================================================================
      -- SOURCES CONFIGURATION - 安全にutils使用
      -- ================================================================
      opts.bar.sources = function(buf, _)
        -- Markdown files: path + markdown parser
        if vim.bo[buf].ft == 'markdown' then
          return {
            sources.path,
            sources.markdown,
          }
        end
        
        -- Terminal buffers: terminal source only
        if vim.bo[buf].buftype == 'terminal' then
          return {
            sources.terminal,
          }
        end
        
        -- Default: path + LSP/treesitter fallback
        return {
          sources.path,
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
      end
      
        -- ================================================================
        -- SAFE SETUP EXECUTION
        -- ================================================================
        local ok_setup, setup_result = pcall(dropbar.setup, opts)
        if not ok_setup then
          vim.notify("dropbar.nvim: Setup failed - " .. tostring(setup_result), vim.log.levels.ERROR)
          return
        end
        
        -- ================================================================
        -- HIGHLIGHT NAMESPACE ISOLATION (競合回避)
        -- ================================================================
        -- Catppuccin統合のカスタムハイライト（遅延適用で競合回避）
        vim.defer_fn(function()
          local highlights = {
            DropBarIconKindFile = { fg = '#89b4fa' },      -- Blue
            DropBarIconKindFolder = { fg = '#fab387' },    -- Peach
            DropBarIconKindFunction = { fg = '#a6e3a1' },  -- Green
            DropBarIconKindMethod = { fg = '#a6e3a1' },    -- Green
            DropBarIconKindClass = { fg = '#f9e2af' },     -- Yellow
            DropBarIconKindInterface = { fg = '#f9e2af' }, -- Yellow
            DropBarIconKindVariable = { fg = '#cdd6f4' },  -- Text
            DropBarIconKindConstant = { fg = '#f38ba8' },  -- Red
            DropBarCurrentContext = { fg = '#f2cdcd', bg = '#313244' }, -- Current
            DropBarHover = { bg = '#45475a' },             -- Hover
            DropBarMenuCurrentContext = { fg = '#f2cdcd', bg = '#45475a' },
            DropBarMenuHoverEntry = { fg = '#cdd6f4', bg = '#45475a' },
            DropBarMenuHoverIcon = { fg = '#89b4fa' },
            DropBarMenuNormalFloat = { bg = '#1e1e2e' },
            DropBarMenuFloatBorder = { fg = '#89b4fa', bg = '#1e1e2e' },
          }
          
          -- 安全なハイライト設定
          for name, opts_hl in pairs(highlights) do
            pcall(vim.api.nvim_set_hl, 0, name, opts_hl)
          end
        end, 50) -- ハイライト競合回避のため50ms遅延
        
      end, 100) -- 初期化競合回避のため100ms遅延
    end,
  },
}