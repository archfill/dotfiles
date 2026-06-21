# macOS Setup Guide

## 概要

このガイドでは、macOS（Intel Mac および Apple Silicon Mac）でのdotfiles環境構築について説明します。

## 前提条件

- macOS 10.15 (Catalina) 以降
- 管理者権限のあるユーザーアカウント

## クイックスタート

### 1. 基本セットアップ（選択肢）

```bash
# dotfilesリポジトリをクローン
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 【推奨】完全な開発環境セットアップ（全アプリ + 設定）
make macos-setup

# 【軽量】必要最小限の開発環境セットアップ
make macos-setup-essential

# 【最小】Neovimビルド依存関係のみ
make macos-setup-minimal
```

### 2. Nix 設定の反映

```bash
# Neovim を含む開発環境を反映
make rebuild
```

### 3. 環境テスト

```bash
# macOS固有のテスト実行
make macos-test
```

## 詳細手順

### Xcode Command Line Tools

一部の macOS 向け開発ツールや Homebrew パッケージには Xcode Command Line Tools が必要です。

```bash
# 手動インストール
xcode-select --install

# 自動インストール（必要なセットアップ実行時）
# 対話式でインストール確認が表示されます
```

### Homebrew

パッケージ管理にはHomebrewを使用します。

#### Apple Silicon Mac (M1/M2)

- インストール先: `/opt/homebrew`
- PATH: `/opt/homebrew/bin`

#### Intel Mac

- インストール先: `/usr/local`
- PATH: `/usr/local/bin`

```bash
# 手動インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 自動インストール（make macos-setup実行時）
# 未インストールの場合、自動的にインストールされます
```

### インストールされるパッケージ

#### 最小セット（minimal）

```bash
# 必須開発ツール
git curl wget jq yq fzf ripgrep bat tmux make coreutils openssl readline xz zlib

# プログラミング言語・ツール
uv mise deno go openjdk openjdk@11
```

#### 基本セット（essential）

最小セット + 以下：

```bash
# 開発ユーティリティ
ghq lazygit awscli stripe

# GUI アプリケーション（Cask）
wezterm aquaskk hammerspoon kitty android-platform-tools google-cloud-sdk brewlet cheatsheet
```

#### 完全セット（full）

基本セット + 以下：

```bash
# macOS専用ツール
yabai skhd displayplacer dmg2img wakeonlan

# 専門ツール
bazelisk qmk ranger sqlite3 tcl-tk

# オプションGUIアプリ
altserver appflowy biscuit yt-music utm via warp xcodes lapce nextcloud gitup など
```

## 利用可能なコマンド

### macOS専用コマンド

```bash
# セットアップコマンド
make macos-setup           # 完全な開発環境セットアップ（全パッケージ）
make macos-setup-essential # 必要最小限の開発環境セットアップ
make macos-setup-minimal   # Neovimビルド依存関係のみ

# テスト・診断
make macos-test            # macOS環境テスト
```

### Neovim

Neovim は Nix の `nix/modules/common.nix` で管理します。macOS でも個別の Homebrew/ビルドスクリプトは使わず、`make rebuild` で反映します。

## トラブルシューティング

### 1. Homebrew PATH問題

```bash
# Apple Silicon Macの場合
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc

# Intel Macの場合
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc

# 設定を反映
source ~/.zshrc
```

### 2. Xcode Command Line Toolsエラー

```bash
# 再インストール
sudo xcode-select --reset
xcode-select --install
```

### 3. 権限エラー

```bash
# Homebrewディレクトリの権限修正（Intel Mac）
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/sbin

# Apple Silicon Mac の場合
sudo chown -R $(whoami) /opt/homebrew
```

### 4. ninja コマンドが見つからない

```bash
# ninjaシンボリックリンクの手動作成
brew_prefix=$(brew --prefix)
ln -sf "$brew_prefix/bin/ninja-build" "$brew_prefix/bin/ninja"
```

## ログとデバッグ

### 環境診断

```bash
# 総合環境チェック
make macos-test

# システム情報表示
make info

# デバッグ情報表示
make debug
```

## 参考情報

- [Neovim公式ビルドドキュメント](https://github.com/neovim/neovim/wiki/Building-Neovim)
- [Homebrew公式サイト](https://brew.sh/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)

## サポートプラットフォーム

- ✅ macOS 14 (Sonoma) - Apple Silicon
- ✅ macOS 14 (Sonoma) - Intel
- ✅ macOS 13 (Ventura) - Apple Silicon
- ✅ macOS 13 (Ventura) - Intel
- ✅ macOS 12 (Monterey) - Apple Silicon
- ✅ macOS 12 (Monterey) - Intel
- ⚠️ macOS 11 (Big Sur) - 制限付きサポート
- ❌ macOS 10.15以前 - サポート対象外
