-- ===== NEOVIM UNIFIED CONFIGURATION =====
-- Stable版とNightly版の統合設定システム
-- バージョン自動検出により適切な設定を読み込み
-- ===================================================

-- ===== Tree-sitter設定 =====
-- HEAD版でbundled Tree-sitterが有効化済み
vim.g.skip_ts_context_commentstring_module = true

-- 基本設定の読み込み
require("base")         -- 基本設定（オプション、変数等）

-- VSCode環境での分岐処理
if vim.g.vscode then
  require("vscode")     -- VSCode専用設定
else
  require("mapping")    -- 通常のキーマッピング
  require("plugins")    -- 統合プラグインシステム（バージョン自動検出）
  require("colorscheme") -- カラースキーム
end