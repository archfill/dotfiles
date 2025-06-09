# 🏠 Dotfiles リポジトリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)
[![Language](https://img.shields.io/badge/Language-日本語%20%7C%20English-green)](https://github.com)

> 🇯🇵 **日本語環境に最適化**: このリポジトリはSKK日本語入力、textlint校正ルール、技術文書執筆支援など、日本語開発環境に特化した機能を提供します。

**macOS**、**Linux**、**Windows (Cygwin)**、**Termux (Android)** に対応した包括的なクロスプラットフォーム dotfiles リポジトリです。日本語環境サポートを充実させた、モダンなターミナルベースの開発ワークフローを提供します。

## ✨ 特徴

### 🌍 **クロスプラットフォーム対応**
- **macOS**: Homebrew、yabai/skhd タイル管理、Karabiner キー再配列、AquaSKK
- **Linux**: i3 ウィンドウマネージャー、polybar、フォントインストール、パッケージ管理
- **Windows**: Cygwin 環境での統合ツールチェーン
- **Android**: モバイル最適化された Termux 設定

### 🛠️ **開発環境**
- **Neovim**: LSP、補完、デバッグ、AI 支援を含む 50+ プラグイン
- **ターミナル**: WezTerm（メイン）、Alacritty、Kitty のカスタムテーマ
- **シェル**: 最適化されたプロンプトと補完システムを備えた Zsh
- **Git**: Lazygit 統合と高度な Git 設定
- **Python**: [uv](https://github.com/astral-sh/uv) パッケージマネージャーによるモダンな開発

### 🇯🇵 **日本語言語機能**
- **SKK 入力方式**: 高性能な yaskkserv2 サーバーと包括的辞書
- **テキスト処理**: 日本語技術文書用の textlint ルール
- **メディアガイドライン**: WEB+DB PRESS、TechBooster スタイルガイド
- **商標検証**: 技術用語の自動チェック

### 📝 **ナレッジマネジメント**
- **Memolist**: Nextcloud 同期対応のメモ取りシステム
- **Zettelkasten**: 研究・文書化用のナレッジマネジメント
- **文書化**: 自動テキスト校正とスタイルチェック

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. 初期セットアップ
```bash
# 完全セットアップ（推奨）
make init

# またはステップバイステップセットアップ
make config    # Git 設定の構成
make links     # シンボリックリンクの作成
make test      # インストールの確認
```

### 3. プラットフォーム固有のセットアップ
```bash
# Android Termux の場合
make termux-setup

# Linux での Neovim インストールの場合
make neovim-install
```

## 📋 利用可能なコマンド

`make help` を実行してすべての利用可能なコマンドを確認：

### **セットアップ & 設定**
| コマンド | 説明 |
|---------|-------------|
| `make init` | 完全な dotfiles 初期化 |
| `make config` | Git 設定のセットアップ |
| `make links` | シンボリックリンクの作成 |
| `make termux-setup` | Android Termux 環境 |

### **テスト & メンテナンス**
| コマンド | 説明 |
|---------|-------------|
| `make test` | 機能テストの実行 |
| `make status` | 現在のステータス表示 |
| `make validate` | 設定の検証 |
| `make debug` | トラブルシューティング情報 |
| `make clean` | 一時ファイルのクリーンアップ |
| `make backup` | 設定のバックアップ作成 |

### **専用ツール**
| コマンド | 説明 |
|---------|-------------|
| `make memolist-config` | メモ取りシステムのセットアップ |
| `make zettelkasten-config` | ナレッジマネジメントのセットアップ |
| `make wezterm-install` | WezTerm のソースからビルド |
| `make yaskkserv2-build` | 日本語入力サーバーのビルド |

## 🏗️ アーキテクチャ

### **共有ライブラリシステム**
`bin/lib/` の共有ライブラリによるモダンで保守可能なアーキテクチャ：

- **`common.sh`** - プラットフォーム検出、ログ出力、エラーハンドリング
- **`config_loader.sh`** - 設定管理とバージョン制御
- **`uv_installer.sh`** - 統一された Python 環境セットアップ
- **`symlink_manager.sh`** - バックアップ機能付き高度なシンボリックリンク管理

### **設定管理**
- **`config/versions.conf`** - 一元化されたバージョン管理
- **`config/personal.conf`** - 個人設定（Git 除外対象）
- **`.env.local`** - 環境変数（Git 除外対象）

### **セットアッププロセス**
1. **プラットフォーム検出** - OS とアーキテクチャの自動検出
2. **設定読み込み** - バージョンと個人設定の読み込み
3. **パッケージインストール** - プラットフォーム固有のパッケージ管理
4. **シンボリックリンク作成** - バックアップ機能付き安全なリンク作成
5. **アプリケーションセットアップ** - 開発ツールのインストールと設定

## 📁 ディレクトリ構造

```
dotfiles/
├── .config/                 # アプリケーション設定
│   ├── nvim/               # Neovim 設定
│   ├── wezterm/            # WezTerm ターミナル設定
│   ├── alacritty/          # Alacritty ターミナル設定
│   ├── zsh/                # Zsh シェル設定
│   └── ...
├── bin/                     # セットアップとユーティリティスクリプト
│   ├── lib/                # 共有ライブラリシステム
│   │   ├── common.sh       # コアユーティリティ
│   │   ├── config_loader.sh # 設定管理
│   │   ├── uv_installer.sh # Python 環境
│   │   └── symlink_manager.sh # リンク管理
│   ├── mac/                # macOS 固有スクリプト
│   ├── linux/              # Linux 固有スクリプト
│   ├── termux/             # Android Termux スクリプト
│   └── apps/               # アプリケーションインストーラー
├── config/                  # 設定ファイル
│   ├── versions.conf       # ツールバージョン管理
│   └── personal.conf.template # 個人設定テンプレート
├── textlint/               # 日本語テキスト校正ルール
└── Makefile                # メインコマンドインターフェース
```

## ⚙️ 設定

### **初回セットアップ**
1. **個人設定の作成**:
   ```bash
   cp config/personal.conf.template config/personal.conf
   ```

2. **個人設定の編集**:
   ```bash
   # config/personal.conf
   export USER_NAME="あなたのフルネーム"
   export USER_EMAIL="your.email@example.com"
   ```

3. **設定の検証**:
   ```bash
   make validate
   ```

### **バージョン管理**
`config/versions.conf` でツールバージョンを更新：
```bash
# バージョン更新例
NVM_VERSION="v0.40.1"
FONT_CICA_VERSION="v5.0.3"
LAZYGIT_VERSION="0.36.0"
```

## 🐍 uv による Python 開発

このリポジトリは高速で信頼性の高い Python パッケージ管理に [uv](https://github.com/astral-sh/uv) を使用：

### **インストール**
```bash
# uv は以下により自動インストールされます：
make init
```

### **使用方法**
```bash
# プロジェクト管理
uv init my-project       # 新しいプロジェクトの作成
uv add requests          # 依存関係の追加
uv run script.py         # 依存関係付きでスクリプト実行

# Python バージョン管理
uv python install 3.12  # Python 3.12 のインストール
uv python list           # インストール済みバージョンの一覧
```

### **グローバルエイリアス**
シームレスな統合のための事前設定エイリアス：
```bash
alias python='uv run python'
alias pip='uv pip'
alias pyproject-init='uv init'
```

## 🧪 テスト

プラットフォーム間での信頼性を確保する包括的なテストスイート：

```bash
# すべてのテストを実行
make test

# 手動検証
make status    # 現在の状態をチェック
make debug     # トラブルシューティング情報
```

**テスト対象**:
- プラットフォーム検出とアーキテクチャ識別
- 設定読み込みと検証
- ファイル操作とシンボリックリンク作成
- コマンド利用可能性チェック
- エラーハンドリング検証

### **継続的インテグレーション**

このリポジトリは **Forgejo Actions** による自動テストを使用：

- **🔄 自動テスト**: プッシュやプルリクエストごとに包括的なテストを実行
- **🖥️ マルチプラットフォーム**: Ubuntu と macOS 環境でテスト実行
- **📋 プルリクエスト検証**: コード品質とドキュメント一貫性を確保
- **🚀 リリース検証**: リリース前の包括的テスト
- **🔒 セキュリティチェック**: 潜在的な機密情報とセキュリティ問題をスキャン

**ワークフローファイル**:
- `.github/workflows/test.yml` - PR検証を含むメインテストスイート
- `.github/workflows/release.yml` - リリース検証とセキュリティ監査

**プラットフォーム互換性**:
- ✅ **GitHub Actions** (github.com)
- ✅ **Forgejo Actions** (セルフホスト)
- ✅ **Gitea Actions** (gitea.com)

## 🇯🇵 日本語言語サポート

### **SKK 入力方式**
- 高性能入力のための **yaskkserv2** サーバー
- 技術用語の包括的辞書
- クロスプラットフォーム互換性

### **テキスト処理**
- 日本語文法チェック付き **textlint**
- 技術文書執筆スタイルガイド
- メディア固有のフォーマットルール
- 自動校正ワークフロー

### **セットアップ**
```bash
# 日本語入力サーバーのビルド
make yaskkserv2-build

# テキスト処理の設定
# （make init 中に自動実行）
```

## 🛠️ 開発

### **新機能の追加**
1. **命名規則に従う**: 動詞プレフィックス付きの `snake_case` を使用
2. **共有ライブラリの使用**: 重複を避けて `bin/lib/` からインポート
3. **エラーハンドリングの追加**: `setup_error_handling()` 関数を使用
4. **ログの含有**: `log_info()`、`log_success()` などを使用
5. **テストの更新**: 新機能のテストケースを追加
6. **ドキュメント更新**: README と CLAUDE.md を最新に保つ

### **コード品質基準**
```bash
# 関数命名
install_package()    # インストール タスク
setup_environment() # 設定タスク
create_symlink()    # 作成タスク
detect_platform()   # 検出タスク

# エラーハンドリング
setup_error_handling
log_info "プロセスを開始しています"
```

### **コントリビューション**
1. リポジトリをフォーク
2. 機能ブランチを作成
3. 新機能のテストを追加
4. すべてのテストが通ることを確認: `make test`
5. ドキュメントを更新
6. プルリクエストを提出

## 🔧 トラブルシューティング

### **よくある問題**

**設定読み込みが失敗する**:
```bash
make debug          # ライブラリ読み込みをチェック
make validate       # 設定を検証
```

**シンボリックリンク作成エラー**:
```bash
make clean          # 一時ファイルをクリーンアップ
make links          # シンボリックリンクを再作成
```

**プラットフォーム検出の問題**:
```bash
# 手動プラットフォームチェック
source bin/lib/common.sh
detect_detailed_platform
```

### **ヘルプの取得**
1. **ステータス確認**: `make status`
2. **デバッグ情報表示**: `make debug`
3. **テスト実行**: `make test`
4. **ログ確認**: 具体的なガイダンスについてエラーメッセージを確認

## 📚 ドキュメント

- **[ライブラリドキュメント](bin/lib/README.md)** - 詳細な API リファレンス
- **[CLAUDE.md](CLAUDE.md)** - 開発ガイドラインとアーキテクチャ
- **`make help`** - クイックコマンドリファレンス

## 🌟 主要なリファクタリング成果（2025年6月）

### **3フェーズの大規模改善**

#### **フェーズ1: 緊急修正**
- **共有ライブラリシステム**: `bin/lib/` による機能統一
- **uv インストール統一**: 4箇所の重複コードを1つの関数に集約
- **構文エラー修正**: `install_wezterm.sh` のバッククォート問題解決
- **エラーハンドリング統一**: 全スクリプトで一貫したエラー処理

#### **フェーズ2: 構造改善**
- **設定外部化**: `config/versions.conf` による一元管理
- **個人情報の保護**: ハードコーディングされた個人情報を外部設定に移行
- **プラットフォーム検出統一**: 高機能な OS・アーキテクチャ検出
- **シンボリックリンク管理**: バックアップ機能付き安全なリンク作成

#### **フェーズ3: 品質向上**
- **命名規則統一**: snake_case + 動詞プレフィックスの徹底
- **包括的ドキュメント**: API リファレンスと使用ガイドの充実
- **自動テストスイート**: 8つのテストケースによる動作検証
- **Makefile 拡張**: 20+ の新コマンドとヘルプシステム

### **改善効果**
- **保守性**: コード重複を 75% 削減
- **セキュリティ**: 個人情報の完全外部化
- **信頼性**: 統一されたエラーハンドリング
- **使いやすさ**: `make help` による直感的操作
- **テスト可能性**: 自動化されたテストスイート

## 📄 ライセンス

MIT ライセンス - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙏 謝辞

- **[uv](https://github.com/astral-sh/uv)** - 高速 Python パッケージ管理
- **[Neovim](https://neovim.io/)** - モダンなテキスト編集
- **[WezTerm](https://wezfurlong.org/wezterm/)** - GPU アクセラレーション ターミナル
- **[SKK](https://github.com/skk-dev/ddskk)** - 日本語入力方式
- **[textlint](https://textlint.github.io/)** - テキスト校正フレームワーク

---

<div align="center">

**[⬆ トップに戻る](#-dotfiles-リポジトリ)**

効率的で美しい開発環境を愛する開発者のために ❤️ で作られました

</div>