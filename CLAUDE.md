# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📚 Detailed Documentation

For detailed information on specific topics, see:

- **[Neovim Configuration](docs/claude/neovim.md)** - Neovim設定、プラグイン管理、パフォーマンス最適化
- **[Development Environment](docs/claude/development.md)** - Python/uv、Node.js/mise、Flutter開発環境
- **[Policies and Rules](docs/claude/policies.md)** - シェル環境設定ポリシー、ドキュメント要件
- **[Historical Records](docs/claude/archives/history.md)** - 過去の調査記録、解決済み問題

## 🛠️ Available MCP Tools for Latest Information

**ALWAYS USE THESE TOOLS** for up-to-date information instead of relying on training data:

### Context7 Library Documentation

- **Tool**: `mcp__Context7__resolve-library-id` and `mcp__Context7__get-library-docs`
- **Purpose**: Get current documentation for libraries and frameworks
- **Example**: Use for Neovim plugins, JavaScript frameworks, Python libraries

### DeepWiki Repository Information

- **Tool**: `mcp__mcp-deepwiki__deepwiki_fetch`
- **Purpose**: Fetch latest repository information and documentation
- **Example**: Use for GitHub repositories, project documentation, README files

### Web Search for Current Information

- **Tool**: `mcp__ddg-search__search` and `mcp__ddg-search__fetch_content`
- **Purpose**: Search for latest information and fetch webpage content
- **Example**: Use for latest plugin releases, API changes, compatibility issues

## 🌍 Communication Language

Please conduct all interactions in **Japanese (日本語)** when working with this repository.

## 📋 Repository Overview

This is a comprehensive **cross-platform dotfiles repository** that automates development environment setup across macOS, Linux, Windows (Cygwin), and Termux (Android). It includes configurations for modern terminal-based development workflows with Japanese language support.

## ⚡ Essential Commands

### Core Setup

- `make init` - Complete dotfiles initialization and setup
- `make test` - Run comprehensive functionality tests
- `make config` - Setup Git configuration with personal settings
- `make links` - Create symbolic links for dotfiles
- `make help` - Show all available commands

### Platform-Specific

- `make termux-setup` - Android Termux environment
- `make neovim-install` - Install Neovim on Linux
- `make flutter-setup` - Setup Flutter development

### Maintenance

- `make status` - Current dotfiles status
- `make update` - Update dotfiles and submodules
- `make clean` - Clean temporary files and caches
- `make backup` - Backup current configuration

⚠️ **For detailed documentation on specific topics, see the linked documents above.**

---

## 📁 Repository Structure

```
dotfiles/
├── .config/           # アプリケーション設定ファイル (20+ configs)
│   ├── nvim/          # Neovim設定
│   ├── zsh/           # Zsh設定
│   ├── tmux/          # tmux設定
│   ├── wezterm/       # WezTerm設定
│   ├── kitty/         # Kitty設定
│   ├── ghostty/       # Ghostty設定
│   ├── alacritty/     # Alacritty設定
│   ├── starship.toml  # Starshipプロンプト
│   ├── sheldon/       # Sheldon (zshプラグイン管理)
│   ├── aerc/          # Aerc (メールクライアント)
│   ├── lazygit/       # Lazygit
│   └── ...            # その他20+の設定
│
├── bin/               # インストール・セットアップスクリプト (詳細は次セクション)
│   ├── apps/          # クロスプラットフォーム開発ツール
│   ├── platform/      # プラットフォーム固有処理
│   ├── install-methods/ # 特殊インストール方法
│   └── lib/           # 共通ライブラリ
│
├── config/            # dotfiles設定
│   ├── versions.conf  # パッケージバージョン管理
│   └── personal.conf  # 個人設定 (Git user/email)
│
├── docs/              # ドキュメント
│   └── claude/        # Claude Code向けドキュメント
│
├── macos/             # macOS固有ファイル
├── windows/           # Windows固有ファイル
├── archive/           # アーカイブ済み設定
│
├── Makefile           # メインコマンドインターフェース
├── CLAUDE.md          # このファイル
└── README.md          # プロジェクト説明
```

---

## 🔧 bin/ Directory Architecture

### 📊 概要

インストールスクリプトを**3つの軸**で整理:

1. **apps/** - クロスプラットフォーム開発ツール（何をインストールするか）
2. **platform/** - プラットフォーム固有処理（どこで動かすか）
3. **install-methods/** - 特殊インストール方法（どうやってインストールするか）

### 📂 詳細構造

```
bin/
├── apps/                           # クロスプラットフォーム開発ツール (19スクリプト)
│   │
│   ├── languages/                  # プログラミング言語 (8スクリプト)
│   │   ├── go.sh                   # Go (g version manager)
│   │   ├── rust.sh                 # Rust (rustup)
│   │   ├── java.sh                 # Java 21 LTS (mise)
│   │   ├── python.sh               # Python (uv)
│   │   ├── nodejs.sh               # Node.js (mise)
│   │   ├── php.sh                  # PHP 8.3
│   │   ├── ruby.sh                 # Ruby 3.2 (rbenv)
│   │   └── deno.sh                 # Deno runtime
│   │
│   ├── devops/                     # DevOpsツール (3スクリプト)
│   │   ├── docker.sh               # Docker Engine
│   │   ├── terraform.sh            # Terraform CLI
│   │   └── flutter.sh              # Flutter SDK
│   │
│   └── tools/                      # CLI開発ツール (8スクリプト)
│       ├── eza.sh                  # モダンls代替
│       ├── starship.sh             # プロンプト
│       ├── sheldon.sh              # zshプラグイン管理
│       ├── tmux.sh                 # tmuxプラグイン管理
│       ├── ghq.sh                  # リポジトリ管理
│       ├── abbr.sh                 # zsh略語展開
│       ├── lazydocker.sh           # Docker管理TUI
│       └── fonts.sh                # フォント管理
│
├── platform/                       # プラットフォーム固有処理 (13スクリプト)
│   │
│   ├── macos/                      # macOS (3スクリプト)
│   │   ├── packages.sh             # Homebrewパッケージ (78個 + 25 casks)
│   │   ├── link.sh                 # macOS専用シンボリックリンク
│   │   └── config.sh               # macOS設定 (ghq等)
│   │
│   ├── linux/                      # Linux (1スクリプト)
│   │   └── packages.sh             # apt/pacman/yayパッケージ
│   │
│   ├── chromebook/                 # Chromebook (3スクリプト)
│   │   ├── chromebook_install.sh
│   │   ├── alacritty_install.sh
│   │   └── lazygit_install.sh
│   │
│   ├── termux/                     # Android Termux (3スクリプト)
│   │   ├── init.sh
│   │   ├── install.sh
│   │   └── link.sh
│   │
│   ├── wsl/                        # Windows WSL (2スクリプト)
│   │   ├── wsl_enhancements.sh
│   │   └── windows_integration.sh
│   │
│   └── cygwin/                     # Windows Cygwin (1スクリプト)
│       └── install_cygwin.sh
│
├── install-methods/                # 特殊インストール方法 (4スクリプト)
│   │
│   ├── appimage/                   # Linux AppImage (2スクリプト)
│   │   ├── neovim.sh               # Neovim AppImage管理 (stable/nightly)
│   │   └── winboat.sh              # Winboat AppImage
│   │
│   └── binary/                     # バイナリ配布版 (2スクリプト)
│       ├── neovim-macos.sh         # Neovim macOS tar.gz版
│       └── sketchybar.sh           # SketchyBar (SbarLua)
│
├── lib/                            # 共通ライブラリ (9モジュール)
│   ├── common.sh                   # 基本関数・ログ・プラットフォーム検出
│   ├── config_loader.sh            # 設定ファイル読込 (versions.conf等)
│   ├── install_checker.sh          # インストール状態管理・スキップ判定
│   ├── symlink_manager.sh          # シンボリックリンク管理
│   ├── font_manager.sh             # フォント管理 (Nerd Fonts等)
│   ├── appimage_manager.sh         # AppImage管理
│   └── uv_installer.sh             # uv専用インストーラー
│
├── init.sh                         # メインエントリーポイント (make init)
├── apps_setup.sh                   # apps/配下を順次実行
├── link.sh                         # シンボリックリンク作成
├── config.sh                       # Git設定
├── appimage-manager.sh             # AppImage一括管理
├── neovim-unified-manager.sh       # Neovim統合管理
└── test.sh                         # テストスクリプト
```

### 🔄 実行フロー

```
make init
  ↓
bin/init.sh
  ├─ bin/link.sh (シンボリックリンク)
  │
  ├─ プラットフォーム別セットアップ
  │   ├─ [macOS]   bin/platform/macos/packages.sh
  │   ├─ [Linux]   bin/platform/linux/packages.sh
  │   └─ [Cygwin]  bin/platform/cygwin/install_cygwin.sh
  │
  ├─ bin/apps_setup.sh
  │   ├─ apps/languages/* (依存順)
  │   ├─ apps/devops/*
  │   └─ apps/tools/*
  │
  └─ bin/config.sh (Git設定)
```

### 💡 設計原則

1. **責務の分離**: 3軸（apps/platform/install-methods）で明確に分類
2. **依存関係管理**: languages → devops → tools の順で実行
3. **クロスプラットフォーム**: apps/は全環境で動作
4. **Git履歴保持**: git mv使用でファイル履歴を完全保持
5. **スキップロジック**: 既存インストールを自動検出・スキップ

### 📦 アプリインストールポリシー

新しいアプリを追加する際の判断基準と優先順位：

#### **基本方針**

- **プラットフォームごとの慣習を尊重**
- クロスプラットフォーム対応だが、各環境の標準的な方法を優先
- 不要な依存関係や並行システムを作らない

#### **プラットフォーム別インストール優先順位**

**macOS:**

```
1. Homebrew（標準パッケージマネージャー）
2. 公式インストーラー/スクリプト
3. バイナリ直接配置
```

**Arch Linux:**

```
1. pacman（公式リポジトリ）
2. yay/AUR（Arch User Repository）
3. 公式スクリプト/バイナリ
```

**⚠️ pacman/yay 使い分けの重要性:**

公式リポジトリパッケージは**必ずpacmanで明示的にインストール**すること。yay一本化は避ける。

**理由:**

- yayは公式リポジトリパッケージが削除されると、**警告なしで**同名のAURパッケージに自動切り替えする（[Issue #2375](https://github.com/Jguer/yay/issues/2375)）
- ユーザーが公式版を使っているつもりで、実際は非公式AUR版になるセキュリティリスク
- Arch Linuxコミュニティ推奨: 公式パッケージは公式ツール（pacman）で管理

**実装例:**

```bash
# 公式リポジトリパッケージ（pacmanで明示的にインストール）
official_packages=(mise ripgrep git-delta wget ...)
sudo pacman -S --needed --noconfirm "${official_packages[@]}"

# AUR専用パッケージ（yayでのみインストール）
aur_packages=(urlscan khard ...)
yay -S --needed --noconfirm "${aur_packages[@]}"
```

**メリット:**

- 公式パッケージが意図せずAUR版に置換されない
- どこから何がインストールされるか明確
- セキュリティと信頼性の向上

**Ubuntu/Debian:**

```
1. APT（公式リポジトリ）
2. サードパーティリポジトリ（信頼できるもののみ）
3. 公式インストールスクリプト/バイナリ（~/.local/binに配置）
❌ Linux版Homebrew（不要 - 大多数のユーザーが使用していない）
```

#### **重要な考え方**

**❌ 避けるべきこと:**

- Ubuntu/DebianでLinux版Homebrewを必須にする
  - 理由: Ubuntu利用者の大多数は使っていない
  - 理由: 並行システムを作り、ディスク容量を浪費
  - 理由: Ubuntuエコシステムから外れる

**✅ 推奨すること:**

- 公式パッケージマネージャーを最優先
- 公式が提供するインストール方法を尊重
- `~/.local/bin`へのユーザーローカルインストール
- プラットフォームごとに最適な方法を選択

#### **実装例: lazydocker**

```bash
# macOS
brew install lazydocker

# Arch Linux
pacman -S lazydocker  # または yay -S lazydocker

# Ubuntu/Debian
# 公式スクリプト（~/.local/binに配置）
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
```

#### **判断フローチャート**

新しいツールを追加する際：

1. **公式リポジトリを確認**
   - macOS: `brew search <tool>`
   - Arch: `pacman -Ss <tool>` / `yay -Ss <tool>`
   - Ubuntu: `apt search <tool>`

2. **公式ドキュメントを確認**
   - 推奨インストール方法をチェック
   - プラットフォームごとの対応状況を確認

3. **優先順位に従って実装**
   - 各プラットフォームで最適な方法を選択
   - 統一性よりも、各環境での自然さを優先

---

## 📝 Recent Changes

### 2025-10-25: Windows設定管理の最適化（ターミナル設定の分離）

**背景:**

- Windows Terminal設定にデバイス固有情報（ユーザー名、WSLディストリビューション名、パス等）が含まれる
- デバイス間で共有すると設定が壊れるリスクがある
- WezTermとAlacrittyはポータブルな設定が可能

**問題点:**
`windows_terminal.json`に含まれるデバイス固有情報：

- デフォルトプロファイルのGUID
- WSLディストリビューション名とユーザー名（例: `//wsl$/Arch/home/archfill`）
- ユーザー固有のパス（例: `C:\Users\uiyiu\scoop\...`）
- デバイス固有のフォント設定

**変更内容:**

1. **Windows Terminal設定を管理対象から除外**
   - `windows_terminal.json` → `windows_terminal.template.json`（参考用テンプレート）
   - `setup.ps1`からWindows Terminal設定のシンボリックリンク作成を削除
   - `status.ps1`からWindows Terminalチェックを削除
   - 各デバイスで個別に設定することを推奨

2. **ポータブルなターミナルエミュレータの個別管理スクリプト追加**

   **`windows/link-wezterm.ps1`** - WezTerm設定専用
   - ソース: `$env:USERPROFILE\dotfiles\.config\wezterm\`
   - ターゲット: `$env:USERPROFILE\.config\wezterm\`
   - 環境変数と相対パスを使用したポータブルな設定
   - `.config`ディレクトリの自動作成
   - 既存設定の自動バックアップ

   **`windows/link-alacritty.ps1`** - Alacritty設定専用
   - ソース: `$env:USERPROFILE\dotfiles\.config\alacritty\`
   - ターゲット: `$env:APPDATA\alacritty\`
   - プラットフォーム固有設定（`windows.toml`）をサポート
   - 既存設定の自動バックアップ

3. **ドキュメントの更新**
   - `windows/README.md`にWindows Terminal除外の理由を明記
   - テンプレートファイルの使用方法を説明
   - setup.ps1の管理対象を明確化

**影響:**

- ✅ デバイス固有設定の誤上書きを防止
- ✅ ポータブルな設定（WezTerm/Alacritty）は個別管理可能
- ✅ Windows Terminalは各デバイスで自由にカスタマイズ
- ✅ テンプレートで共通設定（カラースキーム等）は共有

**実行方法:**

```powershell
# 基本セットアップ（WSL, PS7, GlazeWM, Zebar）
cd $env:USERPROFILE\dotfiles\windows
.\setup.ps1

# オプション: WezTerm設定
.\link-wezterm.ps1

# オプション: Alacritty設定
.\link-alacritty.ps1
```

**設計哲学:**
デバイス固有の設定は管理しない = より柔軟で安全なdotfiles管理

---

### 2025-10-08: toolboxリポジトリ設計とnpm管理の追加

**背景:**

- claude-codeのようなオプショナルなツール（AI、実験的ツール）の管理方法を検討
- npmグローバルパッケージ管理は一般的だが、既存の設計方針（バイナリ、公式スクリプト優先）と矛盾
- AIツールは個人の選択に依存し、必須ではない

**採用した解決策:**
**サブモジュール化 + 最小限npm管理**

```
dotfiles/                               # 親リポジトリ
├── bin/apps/tools/
│   └── npm-essentials.sh               # 必須npmパッケージ（typescript, eslint）
├── .gitmodules                         # サブモジュール設定
└── toolbox/                            # サブモジュール（オプショナルツール）
    ├── bin/
    │   ├── ai/                         # AIツール（claude-code等）
    │   ├── npm-globals/                # 汎用npmツール
    │   └── experimental/
    └── Makefile
```

**判断基準:**

- **dotfiles**: 必須の開発環境、最小限のnpmパッケージ（typescript, eslint）
- **toolbox**: オプショナルなツール（AI、実験的、個人的好み）

**新規コマンド:**

```bash
make toolbox-init    # サブモジュール初期化
make toolbox-update  # toolbox最新版に更新
make toolbox-ai      # AIツールのみインストール
```

**メリット:**

1. 一般的慣習への対応（npm管理を最小限追加）
2. 設計方針の維持（コアは従来通り）
3. 統合管理（1つのクローンで完結）
4. オプショナル性（必要な人だけ追加）
5. 拡張性（開発ツール以外も管理可能）

**詳細設計:**
詳細は `toolbox-repository-design.md` を参照

**影響:**

- ✅ make initは変更なし（必須ツールのみ）
- ✅ toolboxはオプション（デフォルトで無効）
- ✅ 設計方針の一貫性を維持

---

### 2025-10-08: Arch Linux パッケージ管理の改善

**背景:**

- pacman/yayのパッケージリストが二重管理されており保守性が悪い
- yayによる意図しないAURパッケージへの切り替えリスク

**変更内容:**

1. **パッケージリスト統合** - 公式リポジトリ（37個）とAUR（2個）を明確に分離
2. **pacman優先** - 公式パッケージは必ずpacmanで明示的にインストール
3. **セキュリティ強化** - yayによる警告なしのAUR切り替えを防止

**技術的背景:**

- yayは公式パッケージが削除されると警告なしにAUR版に自動切り替え（GitHub Issue #2375）
- Arch Linuxコミュニティ推奨: 公式パッケージは公式ツール（pacman）で管理

**実装:**

```bash
# bin/platform/linux/packages.sh
official_packages=(...)  # pacmanでインストール
aur_packages=(...)       # yayでインストール
```

**影響:**

- ✅ セキュリティ向上（意図しないAURパッケージ使用を防止）
- ✅ 保守性向上（パッケージリスト一元管理）
- ✅ 透明性向上（パッケージソースが明確）

---

### 2025-10-08: bin/配下の大規模再構成

**背景:**

- アプリインストールスクリプトの重複と分散
- 不明確なディレクトリ構造（apps/, linux/apps/, mac/, appimages/, installers/）
- uv/miseの二重インストール問題

**変更内容:**

1. **カテゴリ別整理** - `bin/apps/` を `languages/`, `devops/`, `tools/` に分類
2. **プラットフォーム統一** - `bin/platform/` 配下に全プラットフォーム集約
3. **インストール方法分離** - `bin/install-methods/` でAppImageとバイナリ配布を分離
4. **重複解消** - uv/miseの重複インストールを削除、fonts.shを統合
5. **命名統一** - `brew.sh` → `packages.sh`, `install_linux.sh` → `packages.sh`

**変更統計:**

- **変更ファイル数**: 43ファイル
- **削除行数**: 408行 → **追加行数**: 120行
- **コード削減**: -288行 (70%減)

**影響:**

- ✅ ユーザー向けコマンドは変更なし（Makefile互換性維持）
- ✅ Git履歴完全保持（git mv使用）
- ✅ 全スクリプトの構文チェック済み
- ✅ 既存機能は完全互換

**詳細**: Commit [e58e913](https://github.com/yourusername/dotfiles/commit/e58e913)
