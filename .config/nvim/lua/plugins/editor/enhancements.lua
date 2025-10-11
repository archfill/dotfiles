-- ================================================================
-- EDITOR: Editor Enhancements - Priority 200
-- ================================================================

return {
  -- High-performance color highlighting (pluginconfigから完全移行)
  {
    "norcalli/nvim-colorizer.lua",
    priority = 200,
    event = "BufReadPost",
    config = function()
      local status_ok, colorizer = pcall(require, "colorizer")
      if not status_ok then
        return
      end
      
      colorizer.setup({
        filetypes = {
          "*", -- 全ファイルタイプでカラー表示を有効
          css = { css = true, css_fn = true }, -- CSS関数も対応
          scss = { css = true, css_fn = true },
          sass = { css = true, css_fn = true },
          javascript = { css = true },
          typescript = { css = true },
          html = { css = true },
          vue = { css = true },
          svelte = { css = true },
          lua = { names = false }, -- Lua色名は無効（パフォーマンス重視）
        },
        user_default_options = {
          RGB = true, -- #RGB hex codes
          RRGGBB = true, -- #RRGGBB hex codes
          names = true, -- "Name" codes like Blue or blue
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          AARRGGBB = false, -- 0xAARRGGBB hex codes
          rgb_fn = true, -- CSS rgb() and rgba() functions
          hsl_fn = true, -- CSS hsl() and hsla() functions
          css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          mode = "background", -- Set the display mode (foreground/background/virtualtext)
          tailwind = true, -- Enable tailwind colors
          sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■", -- Virtual text character
          always_update = false, -- パフォーマンス重視で自動更新無効
        },
        buftypes = {}, -- 全バッファタイプで有効
      })
      
      -- パフォーマンス向上のための遅延読み込み
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
          vim.defer_fn(function()
            require("colorizer").attach_to_buffer(0)
          end, 100)
        end,
      })
    end,
  },

  -- Smart cursor word highlighting (pluginconfigから完全移行)
  {
    "RRethy/vim-illuminate",
    priority = 190,
    event = "BufReadPost",
    config = function()
      local status_ok, illuminate = pcall(require, "illuminate")
      if not status_ok then
        return
      end
      
      illuminate.configure({
        -- プロバイダー優先順位（LSP > treesitter > regex）
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
        -- 遅延時間（ms）
        delay = 100,
        -- ファイルタイプ別設定
        filetypes_denylist = {
          "dirvish",
          "fugitive",
          "alpha",
          "NvimTree",
          "neo-tree",
          "lazy",
          "neogitstatus",
          "Trouble",
          "lir",
          "Outline",
          "spectre_panel",
          "toggleterm",
          "DressingSelect",
          "TelescopePrompt",
        },
        -- バッファタイプ別設定
        filetypes_allowlist = {},
        -- モード別設定
        modes_denylist = {},
        modes_allowlist = {},
        -- プロバイダー別設定
        providers_regex_syntax_denylist = {},
        providers_regex_syntax_allowlist = {},
        -- 大きなファイルの設定
        under_cursor = true,
        large_file_cutoff = 2000, -- 大きなファイルでのカットオフ
        large_file_overrides = {
          providers = { "lsp" }, -- 大きなファイルではLSPのみ使用
        },
        -- 最小一致長
        min_count_to_highlight = 1,
        -- 大文字小文字を区別するか
        case_insensitive_regex = false,
      })
      
      -- キーマップ設定
      vim.keymap.set("n", "<a-n>", function()
        require("illuminate").goto_next_reference(false)
      end, { desc = "Move to next reference" })
      
      vim.keymap.set("n", "<a-p>", function()
        require("illuminate").goto_prev_reference(false)
      end, { desc = "Move to previous reference" })
      
      -- ハイライトグループのカスタマイズ
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
    end,
  },

  -- 高機能末尾空白処理 (pluginconfigから完全移行)
  {
    "ntpeters/vim-better-whitespace",
    priority = 180,
    event = "BufReadPost",
    config = function()
      -- ===== 基本機能設定 =====
      -- 末尾空白ハイライトを有効化
      vim.g.better_whitespace_enabled = 1
      
      -- 保存時に自動で末尾空白を削除
      vim.g.strip_whitespace_on_save = 1
      
      -- 削除時の確認ダイアログを無効化（高速化）
      vim.g.strip_whitespace_confirm = 0
      
      -- 空行の末尾空白はスキップ（パフォーマンス向上）
      vim.g.better_whitespace_skip_empty_lines = 1
      
      -- ===== 視覚設定 =====
      -- ターミナルでの色設定
      vim.g.better_whitespace_ctermcolor = 'red'
      
      -- GUI（Neovim）での色設定（美しい赤色）
      vim.g.better_whitespace_guicolor = '#FF5555'
      
      -- ===== 除外設定 =====
      -- 特定のファイルタイプでは末尾空白ハイライトを無効化
      vim.g.better_whitespace_filetypes_blacklist = {
        -- Git関連
        'diff',
        'git',
        'gitcommit',
        'gitrebase',
        'gitconfig',
        
        -- ドキュメント・ヘルプ
        'markdown', -- Markdownでは末尾空白が意味を持つ場合がある
        'help',
        'man',
        'text',
        
        -- プラグイン・ツール
        'lazy',
        'mason',
        'TelescopePrompt',
        'neo-tree',
        'alpha',
        'dashboard',
        'Trouble',
        'qf',
        'fugitive',
        'startify',
        
        -- ログ・バイナリ
        'log',
        'binary',
        'xxd',
        
        -- 一時的・特殊ファイル
        'unite',
        'denite',
        'fzf',
        'ctrlp',
        'nofile',
        'terminal',
      }
      
      -- ===== 詳細設定 =====
      -- 現在行の末尾空白を挿入モード中は非表示にする（デフォルト動作を明示）
      vim.g.current_line_whitespace_disabled_hard = 0
      
      -- 非常に大きなファイル（100MB以上）では自動的に無効化
      vim.g.better_whitespace_verbosity = 1
      
      -- ===== カスタムコマンド設定 =====
      -- プラグイン読み込み後の追加設定
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- カスタムキーマップ（オプション）
          vim.keymap.set('n', '<leader>ws', ':StripWhitespace<CR>', { 
            desc = "Strip trailing whitespace",
            silent = true 
          })
          
          vim.keymap.set('n', '<leader>wt', ':ToggleWhitespace<CR>', { 
            desc = "Toggle whitespace highlighting",
            silent = true 
          })
          
          -- 特定のプロジェクトで一時的に無効化する場合のコマンド
          vim.api.nvim_create_user_command('WhitespaceDisable', function()
            vim.cmd('DisableWhitespace')
            vim.notify('Whitespace highlighting disabled for this session')
          end, { desc = 'Disable whitespace highlighting for this session' })
          
          vim.api.nvim_create_user_command('WhitespaceEnable', function()
            vim.cmd('EnableWhitespace')
            vim.notify('Whitespace highlighting enabled')
          end, { desc = 'Enable whitespace highlighting' })
        end,
      })
      
      -- ===== パフォーマンス最適化 =====
      -- 大きなファイルでの自動調整
      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          local line_count = vim.api.nvim_buf_line_count(0)
          -- 1000行以上の大きなファイルでは保存時削除のみ有効
          if line_count > 1000 then
            vim.b.better_whitespace_enabled = 0
            -- ただし保存時の自動削除は継続
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = 0,
              callback = function()
                vim.cmd('StripWhitespace')
              end,
            })
          end
        end,
      })
      
      -- 初回起動時の機能紹介メッセージ
      if vim.fn.has('vim_starting') == 1 then
        vim.defer_fn(function()
          vim.notify(
            '🚀 vim-better-whitespace が有効化されました\n' ..
            '✨ リアルタイムハイライト + 高機能削除が利用可能',
            vim.log.levels.INFO,
            { title = 'Whitespace Plugin Active' }
          )
        end, 1000)
      end
    end,
  },

  -- Session management
  {
    "jedrzejboczar/possession.nvim",
    keys = {
      { "<leader>sl", "<cmd>PossessionLoad<cr>", desc = "Load session" },
      { "<leader>ss", "<cmd>PossessionSave<cr>", desc = "Save session" },
      { "<leader>sd", "<cmd>PossessionDelete<cr>", desc = "Delete session" },
      { "<leader>sc", "<cmd>PossessionClose<cr>", desc = "Close session" },
    },
    cmd = { "PossessionSave", "PossessionLoad", "PossessionDelete", "PossessionClose" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      session_dir = vim.fn.expand("~/.local/share/nvim/sessions/"),
      silent = false,
      load_silent = true,
      debug = false,
      logfile = false,
      prompt_no_cr = false,
      autosave = {
        current = false,
        tmp = false,
        tmp_name = "tmp",
        on_load = true,
        on_quit = true,
      },
    },
    config = function(_, opts)
      require("possession").setup(opts)

      -- 入力キャンセル時のエラーを回避するカスタムコマンド
      vim.api.nvim_create_user_command("PossessionSaveSafe", function()
        local cwd = vim.fn.getcwd()
        local default_name = vim.fn.fnamemodify(cwd, ":t")

        vim.ui.input({
          prompt = "セッション名を入力 (Enter=デフォルト, Esc=キャンセル): ",
          default = default_name,
        }, function(name)
          if name and name ~= "" then
            require("possession.session").save(name)
            vim.notify("セッション '" .. name .. "' を保存しました", vim.log.levels.INFO)
          elseif name == "" then
            -- デフォルト名で保存
            require("possession.session").save(default_name)
            vim.notify("セッション '" .. default_name .. "' を保存しました", vim.log.levels.INFO)
          else
            -- キャンセルされた場合（nil）
            vim.notify("セッション保存をキャンセルしました", vim.log.levels.WARN)
          end
        end)
      end, { desc = "Save session with error handling" })

      -- ダッシュボード用のショートコマンド
      vim.keymap.set("n", "<leader>sS", "<cmd>PossessionSaveSafe<cr>", { desc = "Save session (safe)" })
    end,
  },
}