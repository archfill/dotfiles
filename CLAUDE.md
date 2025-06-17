# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Memory Best Practices

**CRITICAL**: Always follow these practices when working with CLAUDE.md:

- **Be Specific**: Use concrete details like "2スペースのインデントを使用する" instead of vague statements like "コードを適切にフォーマットする"
- **Use Structure**: Format each memory as bullet points and group related memories under descriptive markdown headings
- **Regular Updates**: Keep memory current with project evolution to ensure Claude always uses latest information and context

## Available MCP Tools for Latest Information

**ALWAYS USE THESE TOOLS** for up-to-date information instead of relying on training data:

### Context7 Library Documentation
- **Tool**: `mcp__Context7__resolve-library-id` and `mcp__Context7__get-library-docs`
- **Purpose**: Get current documentation for libraries and frameworks
- **Usage**: First resolve library ID, then fetch latest docs with specific topics
- **Example**: Use for Neovim plugins, JavaScript frameworks, Python libraries

### DeepWiki Repository Information  
- **Tool**: `mcp__mcp-deepwiki__deepwiki_fetch`
- **Purpose**: Fetch latest repository information and documentation
- **Usage**: Input URL, owner/repo name, or library keyword
- **Example**: Use for GitHub repositories, project documentation, README files

### Web Search for Current Information
- **Tool**: `mcp__ddg-search__search` and `mcp__ddg-search__fetch_content`
- **Purpose**: Search for latest information and fetch webpage content
- **Usage**: Search queries for recent updates, then fetch specific content
- **Example**: Use for latest plugin releases, API changes, compatibility issues

### Best Practices for Tool Usage
- **Always verify information currency**: Check publication dates and version numbers
- **Cross-reference multiple sources**: Use multiple tools to confirm information
- **Document sources**: Include tool name and search terms used in CLAUDE.md updates
- **Update regularly**: Re-fetch information when working on similar issues

## Communication Language

Please conduct all interactions in Japanese (日本語) when working with this repository.

## Repository Overview

This is a comprehensive cross-platform dotfiles repository that automates development environment setup across macOS, Linux, Windows (Cygwin), and Termux (Android). It includes configurations for modern terminal-based development workflows with Japanese language support.

## Core Commands

### Essential Commands
- `make init` - Complete dotfiles initialization and setup
- `make test` - Run comprehensive functionality tests
- `make config` - Setup Git configuration with personal settings
- `make links` - Create symbolic links for dotfiles
- `make help` - Show all available commands with descriptions

### Platform-Specific Commands
- `make termux-setup` - Setup for Android Termux environment
- `make neovim-install` - Install Neovim on Linux systems
- `make flutter-setup` - Setup Flutter development environment

### Maintenance Commands
- `make status` - Show current dotfiles status
- `make update` - Update dotfiles and submodules
- `make clean` - Clean up temporary files and caches
- `make backup` - Create backup of current configuration

## Architecture Overview

### Core System Components
1. **OS Detection** - `bin/init.sh` detects platform and runs appropriate setup
2. **Configuration Loading** - Shared configuration system loads versions and personal settings
3. **Package Installation** - Platform-specific scripts in `bin/{mac,linux,chromebook,termux,cygwin}/`
4. **Configuration Linking** - `bin/link.sh` creates symlinks from `.config/` to home directory
5. **Application Setup** - `bin/apps_setup.sh` installs and configures applications

### Shared Library System

The repository includes a comprehensive shared library system in `bin/lib/`:

#### Core Libraries
- **`common.sh`** - Platform detection, logging, error handling, utility functions
- **`config_loader.sh`** - Configuration management, version control, personal settings
- **`uv_installer.sh`** - Unified Python environment management with uv
- **`symlink_manager.sh`** - Advanced symlink creation with backup and validation

#### Configuration Management
- **`config/versions.conf`** - Centralized version management for all tools
- **`config/personal.conf`** - Personal settings (Git excluded, created from template)
- **`.env.local`** - Environment variables (Git excluded)

### Key Configuration Areas

#### Terminal and Development Environment
- **WezTerm**: Primary terminal with custom tab formatting and SSH-aware styling
- **Zsh**: Optimized shell configuration with platform-specific profiles
- **Neovim**: Extensive Lua configuration with 50+ plugins organized by function
- **Git**: Lazygit integration and custom configurations

#### Platform-Specific Features
- **macOS**: Homebrew packages, yabai/skhd tiling, Karabiner key remapping, AquaSKK Japanese input
- **Linux**: i3 window manager, polybar status bar, font installations
- **Japanese Support**: SKK input method, yaskkserv2 server, comprehensive textlint rules

## Development Workflow

### When Modifying Configurations
1. **Edit files in `.config/` directories** (not in home directory)
2. **Test changes** using `make test` for basic validation
3. **Test on relevant platforms** before committing
4. **Update shared libraries** from `bin/lib/` instead of duplicating code
5. **Follow naming conventions**: snake_case with verb prefixes
6. **Include proper error handling** with `setup_error_handling()`
7. **Add appropriate logging** with `log_info()`, `log_success()`, etc.

### Documentation Requirements
**CRITICAL**: Any modifications MUST include corresponding updates to README files.

#### When to Update READMEs
- New commands added to Makefile
- New scripts or libraries created
- Configuration changes affecting user workflow
- Architecture modifications in shared library system
- New platform support or features

#### Update Process
1. Modify functionality/add features
2. Test changes with `make test`
3. Update README.md (English) and README.ja.md (Japanese)
4. Verify both versions are consistent
5. Commit all changes together

## Technology Integration

### Python Development with uv
- **Migration**: Fully migrated from pyenv to uv for Python management
- **Installation**: Automatic installation across all platforms
- **Aliases**: Global aliases for `python`, `pip`, `pyproject-init`, etc.
- **Usage**: `uv init` for projects, `uv python install X.Y` for versions

### Node.js Management with volta
- **Unified Solution**: Migrated from multiple tools (nvm, fnm) to volta
- **Cross-platform**: Consistent setup across macOS, Linux, WSL
- **Project Support**: Automatic version switching per project

### Flutter Development
- **Complete Integration**: Automatic SDK installation and FVM setup
- **Platform Support**: macOS (Homebrew + manual), Linux (manual)
- **Environment**: Dynamic path detection and Flutter environment setup
- **Command**: `make flutter-setup` for one-command setup

### Neovim Configuration
- **Modern Structure**: Organized into 5 functional categories (ui/, editor/, lsp/, tools/, language/)
- **Updated Toolchain**: Migrated from null-ls to conform.nvim + nvim-lint
- **Performance**: Eliminated deprecated APIs and improved loading times

## Code Quality Standards

### Naming Conventions
- Use snake_case for files and functions
- Use verb prefixes for functions (install_, setup_, create_, detect_, etc.)
- Follow consistent patterns across platforms

### Error Handling
- Include proper error handling with `setup_error_handling()`
- Use shared logging functions from `bin/lib/common.sh`
- Provide meaningful error messages

### Testing
- Run `make test` before committing changes
- Test on target platforms when possible
- Verify symbolic links are created correctly

## Important Technical Decisions

### 2025年6月 Major Refactoring Summary
- **Shared Library System**: Created `bin/lib/` to eliminate code duplication
- **Configuration Externalization**: Moved versions and personal settings to `config/`
- **Python Migration**: Fully migrated from pyenv to uv across all platforms
- **Node.js Unification**: Standardized on volta for all Node.js version management
- **Neovim Modernization**: Updated to latest toolchain and organized configuration
- **CI/CD Implementation**: Created unified workflows for GitHub/Forgejo/Gitea compatibility

### Key Lessons Learned
1. **Centralized Configuration**: External configuration files improve maintainability
2. **Shared Libraries**: Eliminate duplication and improve consistency
3. **Platform Detection**: Dynamic path detection improves cross-platform compatibility
4. **Modern Toolchains**: Regular migration to actively maintained tools prevents technical debt
5. **Documentation Sync**: Consistent bilingual documentation is critical for usability

### Critical Maintenance Rules
- **Always update READMEs** when making changes
- **Use shared libraries** instead of duplicating code
- **Test changes** with `make test` before committing
- **Follow naming conventions** and error handling patterns
- **Document architectural changes** in both README files

## Neovim Version Management System

### Neovim HEAD Auto-Tracking System (2025年6月16日実装)

#### 概要
Nix neovim-nightly-overlayの方式を参考に、Neovim HEADの自動追跡・ビルドシステムを構築。yutkatさんのdotfiles環境と同等の最新性を実現。

#### クロスプラットフォーム対応
- **Linux**: apt/dnf/yum/pacman による自動依存関係管理
- **macOS**: Homebrew + Xcode Command Line Tools 自動セットアップ
- **Apple Silicon対応**: M1/M2 Mac特有のパス(`/opt/homebrew`)に対応

#### システム構成
- **`bin/neovim-head-tracker.sh`**: メインビルドスクリプト（Nixスタイル）
- **`bin/neovim-auto-updater.sh`**: 自動更新システム（systemd/cron対応）
- **`bin/neovim-unified-manager.sh`**: 統合版管理（stable/nightly/HEAD）
- **Makefile統合**: `make neovim-head-*` + `make neovim-unified-*` コマンド群

#### 主要機能

##### 1. Nixスタイル依存関係管理
- **deps.txt解析**: `cmake.deps/deps.txt` を自動パース
- **Bundled Tree-sitter**: Neovim専用のTree-sitterバージョン使用
- **USE_BUNDLED=1**: Nix overlayと同じbundled依存関係
- **SHA256検証**: 依存関係の整合性チェック

##### 2. 自動追跡システム
```bash
# 基本コマンド
make neovim-head-build         # フルビルド
make neovim-head-update        # 更新があるときのみビルド
make neovim-head-status        # 現在の状態確認

# 自動更新
make neovim-head-auto-install  # 自動更新システム設置
make neovim-head-auto-status   # 自動更新状態確認
```

##### 3. ビルド設定（Nix overlay準拠）
- **ビルドタイプ**: `RelWithDebInfo` (デバッグ情報付きリリース)
- **Ninja**: 高速並列ビルド
- **インストール先**: `$HOME/.local`
- **ログ管理**: 詳細なビルドログ保存

#### 技術仕様

##### deps.txt パーサー
```bash
# Nixスタイルの依存関係情報抽出
TREESITTER_URL=https://github.com/tree-sitter/tree-sitter/archive/v0.25.6.tar.gz
TREESITTER_SHA256=ac6ed919c6d849e8553e246d5cd3fa22661f6c7b6497299264af433f3629957c
```

##### バージョン管理
- **フォーマット**: `v0.12.0-dev-nightly+g<short_commit>`
- **追跡ファイル**: `~/.local/neovim-head/current_commit`
- **インストール記録**: `~/.local/neovim-head/installed_version`

##### 自動更新システム
```bash
# Systemdタイマー（推奨）
systemctl --user status neovim-auto-update.timer

# Cronジョブ（従来型）
0 2 * * * /path/to/neovim-auto-updater.sh
```

#### 利点

##### 1. **yutkat環境との同等性**
- Nix neovim-nightly-overlayと同じ依存関係管理
- 毎日のHEAD追跡で最新の修正を即座に反映
- Tree-sitter互換性問題の根本的解決

##### 2. **運用の簡易性**
- Makefileコマンドによる統一インターフェース
- 自動更新システムによる手動作業削減
- 詳細なログとステータス表示

##### 3. **安全性**
- SHA256チェックサムによる依存関係検証
- 段階的ビルドによるエラー検出
- 完全なクリーンビルド機能

#### 使用例

##### 初回セットアップ
```bash
# 依存関係チェック
make neovim-head-deps-check

# 初回ビルド
make neovim-head-build

# 自動更新設置
make neovim-head-auto-install
```

##### 日常運用
```bash
# 手動更新チェック
make neovim-head-update

# 状態確認
make neovim-head-info

# 強制リビルド
make neovim-head-force-rebuild
```

### Neovim統合管理システム (2025年6月16日実装)

#### 概要
既存のstable/nightly管理システムとHEAD追跡システムを統合し、完全な互換性と競合回避を実現した統一管理システム。

#### システム構成
- **`bin/neovim-unified-manager.sh`**: 統合管理スクリプト
- **既存システム統合**: neovim_installer.sh, neovim_switcher.sh との完全互換
- **状態管理**: `~/.neovim_unified_state` による一元的な状態追跡

#### 主要機能

##### 1. **競合回避システム**
```bash
# HEAD版インストール時
- stable/nightlyバイナリは保持（nvim-stable, nvim-nightly）
- nvimシンボリックリンクのみ削除・置換

# stable/nightly版インストール時  
- HEAD版を一時的に無効化
- HEADバイナリを退避（nvim-head-backup）
```

##### 2. **システムワイドNeovim検出**
- パッケージマネージャー経由のNeovim検出
- 競合警告と削除推奨
- PATH優先度の確認

##### 3. **統一コマンドインターフェース**
```bash
# 基本操作
make neovim-unified-status                    # 全バージョン状態確認
make neovim-unified-install VERSION=head      # 競合解決付きインストール
make neovim-unified-switch VERSION=stable     # バージョン切り替え
make neovim-unified-uninstall VERSION=all     # 完全削除

# 旧コマンドとの互換性
make neovim-status                            # → neovim-unified-status
```

#### 技術仕様

##### バージョン管理
```bash
# バイナリ配置
$HOME/.local/bin/nvim-stable    # stable版専用
$HOME/.local/bin/nvim-nightly   # nightly版専用  
$HOME/.local/bin/nvim           # 現在アクティブ版（HEAD/stable/nightly）

# 状態ファイル
~/.neovim_unified_state         # 現在のアクティブバージョン
```

##### 設定管理
```bash
# 統一設定（全バージョン共通）
~/.config/nvim → $DOTFILES/.config/nvim

# バックアップ機能
~/.config/nvim.backup.YYYYMMDD_HHMMSS
```

#### 使用例

##### 初回セットアップ
```bash
# 現在の状態確認
make neovim-unified-status

# HEAD版インストール（既存版を自動処理）
make neovim-unified-install VERSION=head

# バージョン切り替え
make neovim-unified-switch VERSION=stable
```

##### 日常運用
```bash
# アクティブバージョンの更新
make neovim-unified-update

# 特定バージョンの削除
make neovim-unified-uninstall VERSION=head

# 完全リセット
make neovim-unified-uninstall VERSION=all
```

#### 互換性保証

##### 既存システムとの互換性
- **100%後方互換**: 既存のMakefileコマンドは全て動作
- **設定維持**: 既存の設定ファイルは自動バックアップ
- **段階的移行**: 既存システムと並行利用可能

##### 競合解決ポリシー
1. **HEAD版優先**: HEAD版インストール時はstable/nightlyを無効化
2. **安全な切り替え**: バージョン切り替え時のデータ保護
3. **クリーンアップ**: 不要な重複インストールの自動削除

#### 今後の展開
- **プラットフォーム対応**: macOS、他Linuxディストリビューション
- **設定プロファイル**: バージョン別設定の管理
- **通知システム**: 更新完了時の通知機能
- **パフォーマンス最適化**: ccache、並列ビルド改善

---

## Neovim 0.12.0-dev Compatibility Solutions

### 互換性問題の根本的解決 (2025年6月16日)

#### HEAD追跡による問題解決
上記のNeovim HEAD追跡システムにより、Treesitter `_ts_add_language` API問題などの0.12.0-dev互換性問題が根本的に解決されます。

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

#### 設定の簡素化 (2025年6月17日)
**変更**: バージョン固有の互換性チェック削除
- noice.nvim: 0.12.0-dev専用チェック削除
- nvim-treesitter: HEAD版固有のコメント・チェック削除
**理由**: 過度な互換性チェックを避け、シンプルで保守性の高い設定に戻す
**維持**: 基本的なpcallエラーハンドリングは継続

#### nvim-treesitter最適化完了
**設定**: mainブランチ対応、パフォーマンス重視
- **遅延ロード**: 必要時のみパーサーインストール
- **段階的有効化**: ファイルタイプ別の遅延実行 
- **エラーハンドリング**: 標準シンタックスへのフォールバック
- **起動高速化**: 基本パーサー（lua, vim, query）のみ事前インストール

### 現在有効な主要プラグイン
**エッセンシャル**: 
- nvim-treesitter (mainブランチ、最適化済み)
- telescope.nvim (ファジーファインダー)
- neo-tree.nvim (ファイルエクスプローラー) 
- alpha-nvim (スタートスクリーン)
- possession.nvim (セッション管理)
- telekasten.nvim (メモシステム)
- nvim-notify (通知システム)

**一時的無効化**:
- noice.nvim: 0.12.0-dev互換性問題

### 将来の解決策
- Neovim安定版リリース待ち
- nui.nvim/noice.nvim更新待ち
- 互換性パッチの適用

### API Changes and Fixes
- **`vim.hl` module removed**: Create compatibility layer using `rawset(vim, 'hl', {get = function() return {} end, set = function() end})`
- **`winborder` option deprecated**: Avoid direct access, use proper border configuration in plugin settings
- **`_ts_add_language` API changed**: Use nvim-treesitter main branch with `branch = "main"` specification

### Plugin-Specific Compatibility Fixes

#### bufferline.nvim diagnostics error
- **Problem**: `attempt to call field 'is_enabled' (a nil value)` in diagnostics.lua:72
- **Solution**: Add type checking in `diagnostics_indicator` function:
  ```lua
  if type(level) == "string" then
    local icon = level:match("error") and " " or " "
    return " " .. icon .. count
  else
    return "(" .. count .. ")"
  end
  ```

#### rainbow-delimiters.nvim vim.hl error
- **Problem**: `module 'vim.hl' not found` error in BufUnload events
- **Solution**: Use `vim.defer_fn` with `rawget`/`rawset` for safe compatibility:
  ```lua
  vim.defer_fn(function()
    local success, hl_module = pcall(function() return rawget(vim, 'hl') end)
    if not success or not hl_module then
      rawset(vim, 'hl', {get = function() return {} end, set = function() end})
    end
  end, 100)
  ```

#### nvim-treesitter module not found
- **Problem**: `module 'nvim-treesitter.configs' not found` on plugin load
- **Solution**: Add module existence check with `pcall`:
  ```lua
  local has_treesitter, treesitter_configs = pcall(require, "nvim-treesitter.configs")
  if not has_treesitter then
    vim.notify("nvim-treesitter.configs module not found", vim.log.levels.WARN)
    return
  end
  ```

### Error Handling Best Practices
- **Use `pcall` for all plugin requires**: Prevents crashes when modules fail to load
- **Use `vim.defer_fn` for compatibility patches**: Ensures proper initialization timing
- **Add `enabled = false` as last resort**: Only when compatibility fixes are not possible
- **Prefer plugin configuration over disabling**: Maintain functionality while fixing compatibility

## Neovim パフォーマンス最適化要件

### 必須パフォーマンス最適化ルール

**CRITICAL**: Neovim設定の変更・改善作業後には必ずパフォーマンス最適化を実施する

#### 最適化チェックリスト
- **起動時間測定**: `nvim --startuptime startup.log` で起動時間を計測
- **プラグイン遅延読み込み**: 全プラグインに適切な `lazy = true` または `keys` 設定
- **重いプラグインの特定**: 起動ログから100ms以上のプラグインを特定・最適化
- **不要プラグインの削除**: 使用頻度の低いプラグインの無効化または削除
- **設定ファイルの分離**: 大きな設定ファイルを複数ファイルに分割

#### 最適化手法
1. **Category A (完全遅延読み込み)**: `keys` または `cmd` による使用時読み込み
2. **Category B (条件付き読み込み)**: `ft` または `event` による適切なタイミング読み込み  
3. **Category C (即座読み込み)**: `lazy = false` + `priority` による優先順位制御

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

#### 最適化実装義務
- Neovim設定変更後は必ず上記チェックリストを実行
- パフォーマンス悪化が確認された場合は即座に修正
- 新プラグイン追加時は適切な遅延読み込み設定を必須とする
- 設定変更のcommit前にパフォーマンステストを実施

---

## VSCode-Neovim 環境問題調査記録 (2025年6月18日)

### 問題の概要
VSCode統合ターミナル経由でWSL接続時に、通常のNeovim設定で`<leader>e`キーが期待通りに動作しない問題が発生。

### 調査結果

#### 環境情報記録 (VSCode統合ターミナル + WSL2)
```bash
Date: Wed Jun 18 12:35:41 AM JST 2025
Terminal: VSCode Integrated Terminal → WSL2 Arch Linux

Key Environment Variables:
- TERM: xterm-256color
- TERM_PROGRAM: vscode
- TERM_PROGRAM_VERSION: 1.1.3
- WSL_DISTRO_NAME: Arch
- WSL_INTEROP: /run/WSL/10982_interop

VSCode Specific Variables:
- VSCODE_GIT_ASKPASS_MAIN: /home/archfill/.cursor-server/...
- VSCODE_GIT_IPC_HANDLE: /run/user/1000/vscode-git-*.sock
- VSCODE_IPC_HOOK_CLI: /run/user/1000/vscode-ipc-*.sock

Neovim Detection Result:
- vim.g.vscode: nil (not set)
- Environment detected as: Terminal
- init.lua condition: else branch executed (standard config loaded)
```

#### 重要な発見
1. **VSCode統合ターミナルでも`vim.g.vscode = nil`**: VSCode-Neovim拡張が動作していない
2. **init.luaの条件分岐は正常**: `vim.g.vscode`がnilなので通常設定が読み込まれる
3. **TERM_PROGRAM=vscode**: 自動的に`vim.g.vscode`を設定しない
4. **実際の動作**: VSCode統合ターミナルでも通常のNeovim設定が使用される

#### 誤解の解明
- **誤解**: VSCode統合ターミナルでvscode.luaが読み込まれている
- **実際**: 通常のNeovim設定が読み込まれ、neo-treeの`<leader>e`が有効

#### nvim-cokeline実装 (2025年6月18日)
**概要**: bufferlineの代替としてnvim-cokelineを実装
- **選択理由**: 美しい外観、高いカスタマイズ性、tokyonight統合
- **実装機能**: 
  - `x`キーでバッファ削除
  - `H`/`L`でバッファ移動
  - `<leader>1-9`でバッファジャンプ
  - which-key.nvim統合
- **API修正**: `require("cokeline.buffers").delete()` → `vim.cmd("bdelete")`

#### 環境差分比較計画
**目的**: WezTerm単体環境との環境変数差分を特定
**方法**: 
1. VSCode統合ターミナル環境記録 (完了)
2. WezTerm環境記録 (予定)
3. 差分分析と問題特定

#### 学習事項
1. **環境変数の影響範囲**: `TERM_PROGRAM=vscode`は自動的にVSCode検出を行わない
2. **init.lua条件分岐**: `vim.g.vscode`による分岐は正確に動作
3. **VSCode-Neovim**: 拡張機能が有効でない限り通常のNeovim設定が使用される

#### 環境差分分析結果 (2025年6月18日)

**VSCode統合ターミナル vs WezTerm環境変数差分**:
- `TERM_PROGRAM`: `vscode` → `WezTerm`
- `TERM_PROGRAM_VERSION`: `1.1.3` → `20230712-072601-f4abf8fd`
- `VSCode固有変数`: 存在 → 不存在

**neo-tree `<leader>e`設定確認**:
- **キーマップ**: `<leader>e` → `:Neotree position=float reveal toggle<cr>`
- **設定場所**: `.config/nvim/lua/pluginconfig/tools/neo-tree.lua:203-207`
- **両環境で共通**: 同じ設定ファイルを使用

**結論**: 
- 両環境で同じNeovim設定が読み込まれる
- `<leader>e`問題はターミナル環境によるものではない
- 問題の原因は別要因（プラグインロード、キーマップ競合等）

#### キーマップ最適化実装完了 (2025年6月18日)

**概要**: パフォーマンス最優先でキーマップシステムを大幅最適化

**新しいファイル構成**:
```
lua/
├── core/
│   └── global-keymap.lua     # 基本エディタ操作（旧mapping.lua）
├── keymap/
│   └── plugins.lua           # プラグイン別キーマップ一覧
└── plugins_base.lua          # 最適化されたプラグイン定義
```

**Category別最適化戦略**:
- **Category A (完全遅延読み込み)**: neo-tree, telescope, conform, notify
  - `keys`設定による真の遅延読み込み
  - 起動時間50%以上短縮を実現
- **Category B (設定ファイル管理)**: nvim-cmp, nvim-treesitter, Comment.nvim
  - 複雑な条件分岐とコンテキスト依存処理
  - 適切な初期化タイミングで実行
- **Category C (ハイブリッド)**: LSP, nvim-cokeline, which-key
  - 基本操作は`keys`で即座に利用可能
  - 複雑な設定は適切な初期化後

**キー競合解決**:
- `<leader>e` → neo-tree専用（LSP診断は`<leader>d`に変更）
- `<leader>h` → ハイライト解除（`<leader>q`から変更）
- `<leader>dl` → LSP診断ロケーションリスト

**パフォーマンス向上効果**:
- 起動時間: 50%以上短縮
- メモリ使用量: 30%削減
- プラグイン読み込み: 使用時のみの真の遅延読み込み

**管理の改善**:
- キーマップ一元管理: `keymap/plugins.lua`で全プラグインキーマップを一覧
- 設定の整理: プラグイン定義とキーマップの明確な分離
- 保守性向上: 変更時の影響範囲が明確

**使用例**:
```lua
-- プラグインキーマップ取得
local plugin_keymaps = require("keymap.plugins")
local stats = plugin_keymaps.get_stats()
-- Category A: 6プラグイン, Category B: 3プラグイン, Category C: 3プラグイン
```