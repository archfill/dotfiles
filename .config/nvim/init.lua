-- ===== NEOVIM UNIFIED CONFIGURATION =====
-- Stable版とNightly版の統合設定システム
-- バージョン自動検出により適切な設定を読み込み
-- ===================================================

-- 基本設定の読み込み
require("base")         -- 基本設定（オプション、変数等）
require("mapping")      -- キーマッピング
require("plugins")      -- 統合プラグインシステム（バージョン自動検出）
require("colorscheme")  -- カラースキーム