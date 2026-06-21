# Neovim Configuration Guide for Claude Code

このドキュメントはNeovim関連の詳細設定とメンテナンス情報をまとめています。

## 目次
- [Neovim Version Management](#neovim-version-management)
- [Compatibility Solutions](#compatibility-solutions)
- [Plugin Management](#plugin-management)
- [Performance Optimization](#performance-optimization)
- [LazyVim Standards](#lazyvim-standards)

---

## Neovim Version Management

Neovim は Nix で管理します。`nix/modules/common.nix` の `neovimPackage` が全 OS 共通の配布元です。

- 通常は `pkgs.neovim`
- nightly を使う場合は `useNeovimNightly = true` に変更し、`neovim-nightly-overlay` を使う
- 反映は `make rebuild`

旧来の Homebrew/AppImage/HEAD ビルド用スクリプトと Makefile ターゲットは削除済みです。

---

## Compatibility Solutions

### Neovim 0.12.0-dev互換性最適化完了 (2025年6月17日)

#### noice.nvim + nui.nvim互換性問題解決
**症状**: `module 'nui.popup' not found` 反復エラー → **解決済み**
**対策**:
- 互換性チェック機能を追加
- 0.12.0-dev専用の設定最適化
- noice.nvimを再有効化 (`enabled = true`)
**結果**: 美しいUI機能が完全復旧

#### nvim-treesitter設定エラー解決
**症状**: `nvim-treesitter.configs could not be loaded` エラー → **解決済み**
**対策**:
- プラグインロード順序の最適化 (`lazy = false`, `priority = 400`)
- 安全なエラーハンドリングの実装
- Lazy.nvim同期によるプラグイン更新
**結果**: Tree-sitterパーサーが正常にコンパイル・動作

### API Changes and Fixes
- **`vim.hl` module removed**: Create compatibility layer using `rawset(vim, 'hl', {get = function() return {} end, set = function() end})`
- **`winborder` option deprecated**: Avoid direct access, use proper border configuration in plugin settings
- **`_ts_add_language` API changed**: Use nvim-treesitter main branch with `branch = "main"` specification

### Error Handling Best Practices
- **Use `pcall` for all plugin requires**: Prevents crashes when modules fail to load
- **Use `vim.defer_fn` for compatibility patches**: Ensures proper initialization timing
- **Add `enabled = false` as last resort**: Only when compatibility fixes are not possible
- **Prefer plugin configuration over disabling**: Maintain functionality while fixing compatibility

---

## Plugin Management

### 現在有効な主要プラグイン
**エッセンシャル**:
- nvim-treesitter (mainブランチ、最適化済み)
- telescope.nvim (ファジーファインダー)
- neo-tree.nvim (ファイルエクスプローラー)
- snacks.nvim (dashboard, notifier, indent - LazyVim移行完了)
- possession.nvim (セッション管理)
- telekasten.nvim (メモシステム)
- noice.nvim (現代的UI、snacks.notifier統合)
- markview.nvim (マークダウンプレビュー、ハイブリッド編集)

### blink.cmp移行完了 (2025年6月22日)

#### パフォーマンス改善
- **起動時間**: 約24ms（非常に高速）
- **Rust実装**: fuzzy matchingの高速化
- **メモリ使用量**: 効率的なリソース管理

#### 主要機能
- **補完ソース**: LSP, path, snippets, buffer
- **キーマップ**: defaultプリセット（C-y accept）
- **外観**: nvim-cmp互換のアイコンとレイアウト
- **cmdline補完**: 検索とコマンド補完対応
- **snippet統合**: friendly-snippets標準搭載

### snacks.nvim Migration Complete - Phase 1 & 2 (2025年6月22日)

#### 🎉 Migration Summary
**Status**: ✅ Phase 1 & 2 Complete
**Startup Time**: **30.433ms** (Excellent performance maintained)

#### Phase 1: Core Plugin Replacements
1. **alpha-nvim → snacks.dashboard**
   - ✅ All 47 buttons preserved with emojis
   - ✅ Custom NEOVIM ASCII header maintained
   - ✅ Lazy.nvim statistics integration

2. **nvim-notify → snacks.notifier**
   - ✅ 100% keymap compatibility (`<leader>nc`, `<BS>`)
   - ✅ Enhanced animations and styling

3. **indent-blankline.nvim → snacks.indent**
   - ✅ Smooth animations (500ms total, 20ms steps)
   - ✅ Enhanced scope highlighting

### Mason 2.0 LSP管理システム (2025年6月22日完了)

#### 🚨 CRITICAL: Mason 2.0への完全移行済み

**重要**: このプロジェクトはMason 2.0とmason-lspconfig 2.0を使用しています。古いAPI情報を参照しないでください。

#### Mason 2.0の破壊的変更
**廃止されたAPI** (絶対に使用禁止):
- `setup_handlers()` - **完全削除済み**
- `automatic_installation` - **automatic_enableに変更**
- handlers パターン全般

**新しいAPI** (必須使用):
```lua
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright", ... },
    automatic_enable = true,  -- New API
})

-- サーバー設定は直接実行
require('lspconfig').lua_ls.setup({ settings = {...} })
```

---

## Performance Optimization

### 必須パフォーマンス最適化ルール

**CRITICAL**: Neovim設定の変更・改善作業後には必ずパフォーマンス最適化を実施する

#### 最適化チェックリスト
- **起動時間測定**: `nvim --startuptime startup.log` で起動時間を計測
- **プラグイン遅延読み込み**: 全プラグインに適切な `lazy = true` または `keys` 設定
- **重いプラグインの特定**: 起動ログから100ms以上のプラグインを特定・最適化
- **不要プラグインの削除**: 使用頻度の低いプラグインの無効化または削除
- **設定ファイルの分離**: 大きな設定ファイルを複数ファイルに分割

#### パフォーマンス目標
- **起動時間**: 200ms以下を維持
- **メモリ使用量**: 基本プラグインで50MB以下
- **プラグイン読み込み**: 使用するまで読み込まない真の遅延読み込み

#### 測定・検証コマンド
```bash
# 起動時間測定
nvim --startuptime startup.log && grep "TOTAL" startup.log

# メモリ使用量確認
nvim -c "lua print(collectgarbage('count') .. ' KB')" -c "q"

# プラグイン読み込み状況確認
nvim -c "Lazy profile" -c "q"
```

---

## LazyVim Standards

### 🏗️ NEW MANDATORY RULES: LazyVim-Based Dotfiles Standards (2025年6月22日)

**CRITICAL**: These rules are MANDATORY for all future Neovim maintenance and configuration changes

#### 📋 Rule 1: Plugin Organization Structure (REQUIRED)

**REPLACE** Category A/B/C system with functional categorization:

```
lua/plugins/
├── core/           # Priority 1000: Essential startup (colorschemes, fundamental UI)
├── editor/         # Priority 500: Text editing (treesitter, autopairs, comments)
├── ui/             # Priority 800: Interface (statusline, bufferline, notifications)
├── tools/          # Keys/Cmd: Development tools (telescope, neo-tree)
├── lsp/            # Event: Language servers and completion
├── lang/           # Filetype: Language-specific configurations
├── coding/         # Event: Code assistance (formatting, linting, snippets)
├── git/            # Tools: Git integration
├── util/           # VeryLazy: Utility plugins
└── optional/       # Extras: Optional features system
```

#### 📋 Rule 2: Priority-Based Loading System (MANDATORY)

**Loading Priority Order** (MUST follow exactly):
```lua
-- Priority 1000: Colorschemes (FIRST - no exceptions)
{ "folke/tokyonight.nvim", priority = 1000, lazy = false }

-- Priority 800: Core UI (SECOND - essential interface)
{ "nvim-lualine/lualine.nvim", priority = 800, event = "VeryLazy" }

-- Priority 500: Editor fundamentals (THIRD - basic editing)
{ "nvim-treesitter/nvim-treesitter", priority = 500, event = "BufRead" }

-- VeryLazy: Non-critical enhancements (FOURTH - optional)
{ "folke/which-key.nvim", event = "VeryLazy" }

-- Keys/Cmd: Tools (ON-DEMAND - performance critical)
{ "nvim-telescope/telescope.nvim", keys = { "<leader>ff" } }

-- Event: Context-dependent (SMART - when needed)
{ "hrsh7th/nvim-cmp", event = "InsertEnter" }

-- Filetype: Language-specific (TARGETED - specific languages)
{ "simrat39/rust-tools.nvim", ft = "rust" }
```

#### 📋 Rule 3: Integrated Keymap Management (REQUIRED)

**ELIMINATE** separate `keymap/plugins.lua` files. ALL keymaps MUST be defined within plugin specs:

```lua
-- ✅ CORRECT - Integrated approach
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
  },
  opts = { ... }
}

-- ❌ FORBIDDEN - Separate keymap files
-- NO MORE separate keymap management files
```

#### 📋 Rule 6: Performance Standards (NON-NEGOTIABLE)

**Mandatory Performance Targets**:
- **Startup Time**: <50ms (LazyVim standard)
- **Memory Usage**: <30MB for core plugins
- **Plugin Count**: Minimize while maintaining functionality
- **True Lazy Loading**: NO unnecessary eager loading

### 🚨 CRITICAL MAINTENANCE REMINDERS

**BEFORE ANY Neovim Configuration Changes**:
1. ✅ Check these rules compliance
2. ✅ Measure performance impact
3. ✅ Test startup time
4. ✅ Verify plugin categorization
5. ✅ Update documentation

**VIOLATION OF THESE RULES IS FORBIDDEN**
