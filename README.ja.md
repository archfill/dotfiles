# 🏠 Dotfiles リポジトリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)

日本語環境対応のクロスプラットフォーム dotfiles です。モダンな開発環境を自動構築します。

## ✨ 特徴

- **マルチプラットフォーム**: macOS、Linux、Windows (Cygwin)、Android (Termux)
- **モダンツール**: Neovim、WezTerm、Zsh の最適化設定
- **日本語サポート**: SKK 入力方式、技術文書用 textlint
- **開発対応**: Python (uv)、Node.js (volta)、Flutter、Docker サポート

## 🚀 クイックスタート

### 1. クローンとセットアップ

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 個人設定の構成
cp config/personal.conf.template config/personal.conf
$EDITOR config/personal.conf  # USER_NAME と USER_EMAIL を設定

# 完全セットアップ
make init
```

### 2. 基本コマンド

```bash
make init     # 完全インストール
make test     # セットアップ検証
make status   # 状態確認
make help     # 全コマンド表示
```

## 📁 主要設定

- **Neovim**: `.config/nvim/` - 50+ プラグイン、LSP サポート
- **Zsh**: `.config/zsh/` - 最適化シェル、補完機能
- **ターミナル**: `.config/wezterm/` - モダンターミナル設定
- **Git**: グローバル git 設定、lazygit 統合

## 🌍 プラットフォーム対応

| プラットフォーム | パッケージマネージャー | ウィンドウマネージャー |
|------------------|------------------------|------------------------|
| macOS            | Homebrew               | yabai/skhd             |
| Linux            | apt/pacman/dnf         | i3/polybar             |
| Windows          | Cygwin                 | Native                 |
| Android          | Termux                 | Native                 |

## 🇯🇵 日本語機能

- **SKK 入力**: yaskkserv2 サーバー、包括的辞書
- **文章校正**: 技術文書用 textlint
- **メディアスタイル**: WEB+DB PRESS、TechBooster スタイルガイド

## 🛠️ 開発ツール

### プログラミング言語
- **Python**: uv パッケージマネージャー（pyenv の現代的代替）
- **Node.js**: volta ツールチェーン管理（nvm/fnm 代替）
- **Rust**: rustup と基本ツール（clippy、rustfmt）
- **Go**: g バージョン管理、開発ツール
- **Java**: SDKMAN! による JDK 管理

### 開発環境
- **エディタ**: Neovim（LSP、補完、デバッグ）
- **ターミナル**: WezTerm（カスタムテーマ、SSH 統合）
- **Git**: 高度設定、lazygit インターフェース
- **コンテナ**: Docker、Docker Compose セットアップ
- **モバイル**: Flutter、FVM バージョン管理

## 📖 ドキュメント

詳細なセットアップとトラブルシューティング:
- [English Documentation](README.md)
- [CLAUDE.md](CLAUDE.md) - AI アシスタント用ガイダンス
- [Makefile](Makefile) - 利用可能コマンド

## 🤝 コントリビューション

1. リポジトリをフォーク
2. フィーチャーブランチを作成
3. `make test` で変更をテスト
4. 必要に応じてドキュメント更新
5. プルリクエストを送信

## 📄 ライセンス

[MIT License](LICENSE) - 自由に使用・改変してください。