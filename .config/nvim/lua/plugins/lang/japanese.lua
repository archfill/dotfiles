-- ================================================================
-- LANG: Japanese Input System with SKK (skkeleton + blink.cmp)
-- ================================================================
-- 完全自動化SKK日本語入力システム
-- - 辞書自動ダウンロード・管理
-- - blink.cmp統合
-- - 透明な初期化

return {
  -- ================================================================
  -- SKK日本語入力システム（完全自動）
  -- ================================================================
  {
    "vim-skk/skkeleton",
    dependencies = {
      "vim-denops/denops.vim",
      "rinx/cmp-skkeleton",
      "nvim-lua/plenary.nvim", -- 辞書管理必須
    },
    keys = {
      -- ===== SKK基本操作 =====
      { "<C-j>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" }, desc = "Enable SKK" },
      { "<C-l>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" }, desc = "Disable SKK" },
    },
    cmd = { 
      "SKKDictUpdate", 
      "SKKDictStatus", 
      "SKKDictClean",
      "SKKHealthCheck"
    },
    config = function()
      -- 辞書管理ユーティリティ読み込み
      local skk_dict = require('utils.skk-dict')
      
      -- ================================================================
      -- SKK設定関数
      -- ================================================================
      local function configure_skkeleton()
        local dict_paths = skk_dict.get_dict_paths()
        
        if #dict_paths.available_dicts > 0 then
          vim.fn["skkeleton#config"]({
            -- ===== 基本設定 =====
            eggLikeNewline = true,
            
            -- ===== 辞書設定 =====
            globalDictionaries = dict_paths.available_dicts,
            userDictionary = dict_paths.user_dict,
            completionRankFile = dict_paths.rank_file,
            
            -- ===== 表示設定 =====
            showCandidatesCount = 1,
            markerHenkan = "▽",
            markerHenkanSelect = "▼",
            
            -- ===== 変換設定 =====
            immediatelyCancel = false,
            keepState = true,
            selectCandidateKeys = "asdfjkl",
            
            -- ===== 学習設定 =====
            registerConvertResult = true,
          })
          
          vim.notify(string.format('🎌 SKK設定完了（%d辞書利用）', #dict_paths.available_dicts), vim.log.levels.INFO)
        else
          vim.notify('⚠️ SKK辞書が見つかりません。辞書ダウンロードを待機中...', vim.log.levels.WARN)
        end
      end
      
      -- ================================================================
      -- 自動初期化実行
      -- ================================================================
      skk_dict.auto_init()
      
      -- 初回設定試行（既存辞書がある場合）
      configure_skkeleton()
      
      -- 辞書準備完了時の再設定
      vim.api.nvim_create_autocmd('User', {
        pattern = 'SKKDictReady',
        callback = configure_skkeleton,
        desc = 'SKK辞書準備完了時の自動設定'
      })
      
      -- ================================================================
      -- ユーザーコマンド（手動管理用）
      -- ================================================================
      vim.api.nvim_create_user_command('SKKDictUpdate', function()
        skk_dict.force_update()
      end, { 
        desc = 'SKK辞書を強制更新（全辞書再ダウンロード）' 
      })
      
      vim.api.nvim_create_user_command('SKKDictStatus', function()
        skk_dict.status()
      end, { 
        desc = 'SKK辞書ステータス確認' 
      })
      
      vim.api.nvim_create_user_command('SKKDictClean', function()
        skk_dict.clean()
        vim.notify('🔄 SKK辞書をクリアしました。次回起動時に再ダウンロードされます', vim.log.levels.INFO)
      end, { 
        desc = 'SKK辞書ディレクトリをクリア' 
      })
      
      vim.api.nvim_create_user_command('SKKHealthCheck', function()
        local health = skk_dict.health_check()
        local health_lines = {
          '🏥 SKK システム健全性チェック',
          '',
          '📦 依存関係:',
          '  plenary.nvim: ' .. (health.plenary_available and '✅ 利用可能' or '❌ 未インストール'),
          '  curl: ' .. (health.curl_available and '✅ 利用可能' or '❌ 未インストール'),
          '',
          '📁 ディレクトリ:',
          '  データディレクトリ書き込み可能: ' .. (health.data_dir_writable and '✅ OK' or '❌ NG'),
          '',
          '📚 辞書:',
          string.format('  利用可能辞書: %d/%d', health.dict_count, health.total_dict_count),
        }
        
        local health_msg = table.concat(health_lines, '\n')
        vim.notify(health_msg, vim.log.levels.INFO)
      end, { 
        desc = 'SKKシステム健全性チェック' 
      })
    end,
  },
  
  -- ================================================================
  -- blink.cmp互換性ブリッジ
  -- ================================================================
  {
    'saghen/blink.compat',
    version = '*',
    lazy = true,
    opts = {
      debug = false,
    },
  },
  
  -- ================================================================
  -- SKK状態インジケーター
  -- ================================================================
  {
    "delphinus/skkeleton_indicator.nvim",
    dependencies = { "vim-skk/skkeleton" },
    event = "VeryLazy",
    opts = {},
  },
}