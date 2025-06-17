# Dotfiles共通ライブラリ

このディレクトリには、dotfilesリポジトリ全体で使用される共通ライブラリが含まれています。

## ライブラリ一覧

### `common.sh` - 基本ユーティリティ
プラットフォーム検出、ログ出力、エラーハンドリングなど、すべてのスクリプトで共通して使用される基本機能を提供します。

**主要機能：**
- `setup_error_handling()` - 統一されたエラーハンドリング設定
- `log_info()`, `log_success()`, `log_warning()`, `log_error()` - ログ出力
- `detect_platform()` - プラットフォーム検出（macos/linux/cygwin）
- `detect_architecture()` - アーキテクチャ検出（x86_64/arm64/etc）
- `get_os_distribution()` - Linuxディストリビューション検出
- `is_macos()`, `is_linux()`, `is_cygwin()` - プラットフォーム判定
- `detect_package_manager()` - パッケージマネージャー検出

**使用例：**
```bash
source "${SCRIPT_DIR}/lib/common.sh"
setup_error_handling

if is_macos; then
    log_info "Running on macOS"
fi
```

### `config_loader.sh` - 設定管理
バージョン管理、個人設定、環境変数の読み込みを統一的に行います。

**主要機能：**
- `load_config()` - 設定ファイルの一括読み込み
- `validate_config()` - 設定値の検証
- `show_config()` - 現在の設定表示（デバッグ用）
- `init_config()` - 初期設定ファイルの作成

**設定ファイル：**
- `config/versions.conf` - ツールバージョン設定
- `config/personal.conf` - 個人設定（Git除外）
- `.env.local` - 環境変数（Git除外）

**使用例：**
```bash
source "${SCRIPT_DIR}/lib/config_loader.sh"
load_config

echo "Using NVM version: ${NVM_VERSION}"
echo "Git user: ${USER_NAME} <${USER_EMAIL}>"
```

### `uv_installer.sh` - Python環境管理
uvインストールと設定を統一的に管理します。

**主要機能：**
- `install_uv()` - プラットフォーム別uvインストール
- `verify_uv_installation()` - インストール確認
- `cleanup_old_python_tools()` - 古いPythonツールのクリーンアップ

**使用例：**
```bash
source "${SCRIPT_DIR}/lib/uv_installer.sh"
install_uv
verify_uv_installation
```

### `volta_installer.sh` - JavaScript環境管理
Voltaインストールと設定を統一的に管理します。

**主要機能：**
- `install_volta()` - VoltaのインストールとPATH設定
- `install_nodejs_toolchain()` - Node.js LTSとnpmのインストール
- `setup_volta_complete()` - 完全なVoltaセットアップ
- `is_volta_installed()` - Voltaインストール状況の確認
- `setup_volta_environment()` - 環境変数とシェル設定の構成

**使用例：**
```bash
source "${SCRIPT_DIR}/lib/volta_installer.sh"
setup_volta_complete  # Volta + Node.js toolchainの完全セットアップ
```

### `symlink_manager.sh` - シンボリックリンク管理
dotfilesのシンボリックリンク作成を統一的に管理します。

**主要機能：**
- `create_symlink()` - 汎用シンボリックリンク作成
- `create_symlink_from_dotfiles()` - dotfilesからのリンク作成
- `create_symlinks_batch()` - バッチリンク作成
- `backup_existing_file()` - 既存ファイルのバックアップ
- `create_platform_specific_symlinks()` - プラットフォーム固有リンク

**使用例：**
```bash
source "${SCRIPT_DIR}/lib/symlink_manager.sh"

# 個別リンク作成
create_symlink_from_dotfiles ".config/nvim"

# バッチリンク作成
CONFIGS=(".vimrc" ".config/alacritty" ".config/kitty")
create_symlinks_batch "${CONFIGS[@]}"
```

## 使用方法

### 基本的な使用パターン

```bash
#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config_loader.sh"

# エラーハンドリング設定
setup_error_handling

# 設定読み込み
load_config

# メイン処理
log_info "Starting script execution"

if is_macos; then
    log_info "macOS specific processing"
elif is_linux; then
    log_info "Linux specific processing"
fi

log_success "Script completed successfully"
```

### 設定ファイルの作成

初回セットアップ時に個人設定ファイルを作成してください：

```bash
# テンプレートから個人設定ファイルを作成
cp config/personal.conf.template config/personal.conf

# 個人情報を編集
vi config/personal.conf
```

## 設計原則

1. **後方互換性** - 既存のスクリプトとの互換性を維持
2. **プラットフォーム対応** - macOS/Linux/Cygwin/Termuxに対応
3. **エラーハンドリング** - 統一されたエラー処理とログ出力
4. **設定外部化** - ハードコーディングの排除
5. **再利用性** - 機能の共通化と重複排除

## 開発者向け情報

### 新しいライブラリの追加

1. `bin/lib/` 下に新しいライブラリファイルを作成
2. 既存の命名規則に従う（snake_case）
3. 適切なコメントとドキュメントを追加
4. このREADMEを更新

### 命名規則

- **ファイル名**: `snake_case.sh`
- **関数名**: `verb_noun_format()`
- **変数名**: 
  - 定数: `UPPER_SNAKE_CASE`
  - ローカル変数: `lower_snake_case`
  - 環境変数: `UPPER_SNAKE_CASE` (export)

### テスト

ライブラリの動作確認は以下のコマンドで行えます：

```bash
# 設定の確認
source bin/lib/config_loader.sh && load_config && show_config

# プラットフォーム情報の確認
source bin/lib/common.sh && echo "Platform: $(detect_detailed_platform)"
```