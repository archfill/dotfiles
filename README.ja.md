# 🏠 Dotfiles リポジトリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-NixOS%20%7C%20macOS%20%7C%20Linux%20%7C%20Windows-blue)](#プラットフォーム対応)
[![English](https://img.shields.io/badge/lang-en-red)](README.md)

日本語環境対応のクロスプラットフォーム dotfiles です。モダンな開発環境を自動構築します。

## ✨ 特徴

- **マルチプラットフォーム**: NixOS、macOS、Linux、Windows
- **モダンツール**: Neovim、WezTerm、Zsh の最適化設定
- **日本語サポート**: SKK 入力方式、技術文書用 textlint
- **Nix 管理**: NixOS、nix-darwin、Home Manager でパッケージと dotfiles リンクを管理

## 🚀 クイックスタート

### 1. クローン

```bash
git clone ssh://git@forgejo.archfill.com:2222/archfill/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Nix 設定の反映

Nix と `nh` が使える状態なら、通常運用は `make nix-rebuild` で反映します。これは初回セットアップ完了後の日常コマンドです。

```bash
make nix-rebuild
```

初回セットアップでは先に Nix を導入してから `make init` を実行します。`make init` は bootstrap 用の入口なので、この時点で `nh` がまだ使えなくても構いません。

- macOS: `make doctor` 相当の前提チェック後、`darwin-rebuild` があれば実行し、なければ `nix run nix-darwin` で初回 bootstrap。**新しい Mac の手順は [docs/macos-setup.md](docs/macos-setup.md) を参照**
- NixOS: `nh os switch` があれば使い、なければ `nixos-rebuild` に fallback
- Arch / Ubuntu / WSL: `nh home switch`、`home-manager switch`、`nix run home-manager` の順で fallback

```bash
# NixOS / macOS の flake 定義済みホスト
make doctor   # macOS: 前提条件チェック (何もインストールしない)
make init

# standalone Home Manager ホスト
make init NIX_ATTR='archfill@arch-desktop'
make init NIX_ATTR='archfill@ubuntu-desktop'
make init NIX_ATTR='archfill@wsl-ubuntu'
```

Nix 導入前に最低限の OS パッケージだけ入れたい場合のみ、legacy モードを使います。

```bash
make init DOTFILES_INSTALL_MODE=legacy
```

`make init` で Nix / Home Manager 設定が反映されると、共通 Nix パッケージとして `nh` が入ります。その後は `make nix-rebuild` / `make nix-diff` を通常の運用コマンドとして使います。

### 3. 基本コマンド

```bash
make nix-rebuild      # nh 経由で Nix flake を反映
make nix-diff         # 次の switch 差分を確認
make nix-update       # Codex と flake.lock を更新して switch
make nix-clean        # 最新 5 世代を残して掃除
make config           # Git ユーザー設定
make status           # 状態確認
make help             # 全コマンド表示
```

## 📁 主要設定

- **Neovim**: `.config/nvim/` - 50+ プラグイン、LSP サポート
- **Zsh**: `.config/zsh/` - 最適化シェル、補完機能
- **ターミナル**: `.config/wezterm/` - モダンターミナル設定
- **Git**: グローバル git 設定、lazygit 統合

## 🌍 プラットフォーム対応

| プラットフォーム | 管理レイヤー | デスクトップ / WM | 備考 |
| ---------------- | ------------ | ----------------- | ---- |
| NixOS            | NixOS + Home Manager | GNOME / Hyprland | メイン Linux 環境 |
| macOS            | nix-darwin + Home Manager + Homebrew module | Hammerspoon / Rectangle | 宣言的にパッケージ管理 |
| Linux            | Home Manager | Hyprland 向けユーザー設定 | Arch / Ubuntu / WSL |
| Windows          | 手動スクリプト | Native | WSL2 設定管理 |

### Hyprland セットアップ (NixOS / Arch Linux)

Hyprland は GPU アクセラレーションによるアニメーションと豊富なカスタマイズが可能な、モダンな Wayland コンポジタです。

#### インストール

```bash
# NixOS: 宣言済みの Hyprland デスクトップを反映
make nix-rebuild

# インストール状態を確認
make hyprland-status
```

#### インストールされるパッケージ

**Hyprland コアパッケージ:**

- `hyprland` - メインコンポジタ
- `hyprcursor` - カーソル管理
- `hypridle` - アイドルデーモン
- `hyprpicker` - カラーピッカー
- `hyprshot` - スクリーンショットユーティリティ
- `hyprpolkitagent` - Polkit 認証エージェント
- `xdg-desktop-portal-hyprland` - デスクトップポータル統合

**Shell / Wayland ツール:**

- `dms` - バー、ランチャー、ダッシュボード、電源メニュー、壁紙選択、通知、クリップボード、ロック UI
- `rofi` - クリップボード履歴とキーバインド一覧の fallback UI
- `wl-clipboard` - クリップボードユーティリティ
- `cliphist` - クリップボード履歴
- `matugen` - デスクトップテーマと既存テンプレート用の Material 配色生成

**スクリーンショットツール:**

- `satty` - スクリーンショット編集・注釈ツール

**デスクトップ補助ツール:**

- `pavucontrol` - オーディオコントロール GUI
- `brightnessctl` - 画面輝度制御
- `playerctl` - メディアプレーヤー制御 (MPRIS)
- `network-manager-applet` - ネットワーク管理 GUI
- `overskride` - Bluetooth 管理

**NVIDIA 専用パッケージ:**

- `egl-wayland` - NVIDIA 向け Wayland EGL サポート
- `libva-nvidia-driver` - NVIDIA ハードウェアアクセラレーション

#### GPU 別設定

NixOS の共通設定は Nix module で宣言します。ホスト固有の差分は `nix/hosts/<host>/` に置き、モニター配置は `~/.config/hypr/monitors.lua` に残します。

**NVIDIA GPU (RTX 4070 など):**

- Hyprland 向け NVIDIA / VA-API 環境変数を設定
- VA-API ハードウェアアクセラレーション対応
- NixOS では `NIXOS_OZONE_WL=1` で Electron / Chromium 系アプリの Wayland 利用を有効化

**Intel/AMD GPU:**

- 追加設定不要

**複数 PC での利用:**

- ホスト固有の Nix 設定は `nix/hosts/<host>/` に配置
- GPU 構成が違っても同じ dotfiles を共有
- ハードウェア差分で不要な git diff を作らない

#### インストール後の手順

**全ユーザー向け:**

1. 設定ファイルを確認: `~/.config/hypr/hyprland.lua`
2. 必要に応じてキーバインド調整（デフォルト: Super/Windows キー）
3. 複数ディスプレイ使用時はモニターレイアウトを設定

**NVIDIA ユーザー向け:**

NixOS では NVIDIA DRM modeset、fbdev、early modules、Hyprland 環境変数を Nix 設定で宣言します。Arch Linux など NixOS 以外では、必要に応じて各 OS 側の NVIDIA 設定を別途行います。

詳細な NVIDIA セットアップ手順: https://wiki.hyprland.org/Nvidia/

#### Hyprland の起動

**TTY から:**

```bash
Hyprland
```

**ディスプレイマネージャー使用:**

- GDM、SDDM、LightDM が自動的に Hyprland を検出
- セッションメニューから「Hyprland」を選択

#### 設定ファイル

設定ファイルは Nix / Home Manager から symlink されます。

- `~/.config/hypr/hyprland.lua` - メイン設定
- `~/.config/hypr/hypridle.conf` - ロールバック用に残す旧 Hypridle 設定
- `~/.config/niri/config.kdl` - Niri コンポジタと DMS キーバインド
- `~/.config/DankMaterialShell/` - DMS が作成するユーザー設定
- `~/.config/rofi/` - クリップボード / キーバインド一覧の fallback menu
- `~/.config/matugen/` - 配色生成テンプレート

#### デスクトップ責務

- `dms` がバー、ランチャー、ダッシュボード、電源メニュー、壁紙選択、通知、クリップボード、ロック UI、idle policy を担当
- Hyprland を既定 session として維持し、Niri を追加 session として選択できる
- `rofi` と `cliphist` は DMS 評価中の fallback 用に残す
- `matugen` は既存の Hyprland、rofi、terminal テンプレート用に利用可能な状態を保つ

#### NixOS Hyprland 管理範囲

| 用途 | NixOS 宣言 |
| ---- | ---------- |
| Hyprland、XWayland、portal | `nix/modules/desktop/hyprland.nix` の `programs.hyprland` / `xdg.portal` |
| Hyprland ツール | `hyprcursor`、`hypridle`、`hyprpicker`、`hyprshot`、`hyprpolkitagent` |
| クリップボード / picker | `rofi`、`wl-clipboard`、`cliphist` |
| スクリーンショット / 配色 | `satty`、`matugen`、`gettext` |
| デスクトップ補助 | `pavucontrol`、`brightnessctl`、`playerctl`、`networkmanagerapplet`、`nwg-look`、`overskride` |
| NVIDIA Wayland 対応 | `egl-wayland`、`nvidia-vaapi-driver`。driver / kernel は `nix/hosts/<host>/configuration.nix` |
| ネットワーク / 音声 | `nix/modules/nixos-common.nix` の NetworkManager / PipeWire |
| 日本語入力 | `nix/modules/nixos-common.nix` の `i18n.inputMethod.fcitx5` |
| GNOME 連携 | GDM、GNOME、Nautilus、GNOME keyring |
| DMS | `nix/modules/desktop/dms.nix` のネイティブ `programs.dms-shell` module |
| Niri | `nix/modules/desktop/niri.nix` の `programs.niri` / `xwayland-satellite` |

#### 主なデフォルトキーバインド（DMS/Niri）

| キー                              | 動作                               |
| --------------------------------- | ---------------------------------- |
| `Super + Return`                   | ターミナル起動（ghostty）          |
| `Super + Space`                   | DMS ランチャー切り替え             |
| `Alt + Space`                     | DMS Spotlight バー切り替え         |
| `Super + V`                       | DMS クリップボード                 |
| `Super + M`                       | DMS タスクマネージャー             |
| `Super + X`                       | DMS 電源メニュー                   |
| `Super + ,`                       | DMS 設定                           |
| `Super + Y`                       | DMS 壁紙ブラウザ                   |
| `Super + N`                       | DMS 通知センター                   |
| `Super + Shift + N`               | DMS メモ帳                         |
| `Super + Alt + L`                 | 画面ロック                         |
| `Super + Tab`                     | Niri Overview                      |
| `Super + Shift + /`               | Niri キーバインド一覧              |
| `Super + Q`                       | アクティブウィンドウを閉じる       |
| `Super + F`                       | カラム最大化                       |
| `Super + Shift + F`               | フルスクリーン                     |
| `Super + Shift + T`               | フローティング切り替え             |
| `Super + W`                       | タブ表示切り替え                   |
| `Super + Shift + W`               | DMS ウィンドウルール               |
| `Super + Ctrl + ,`                | 左カラムとの間で取り込み / 排出     |
| `Super + Ctrl + .`                | 右カラムとの間で取り込み / 排出     |
| `Super + .`                       | カラムからウィンドウを排出          |
| `Super + h/j/k/l`                 | フォーカス移動（vim スタイル）     |
| `Super + Shift + h/j/k/l`         | ウィンドウ / カラム移動            |
| `Super + Ctrl + h/j/k/l`          | モニター間フォーカス移動            |
| `Super + Ctrl + Shift + h/j/k/l`  | カラムをモニターへ移動             |
| `Super + 1-9`                     | ワークスペース切り替え             |
| `Super + Shift + 1-9`             | カラムをワークスペースへ移動       |
| `Super + U/I`                     | 上下のワークスペースへ移動         |
| `Super + Shift + U/I`             | ワークスペースを上下に並べ替え     |
| `Super + P`                       | ディスプレイプロファイル切り替え   |
| `Super + S`                       | 範囲スクリーンショット             |
| `Super + Ctrl + S`                | 画面全体スクリーンショット         |
| `Super + Alt + S`                 | ウィンドウスクリーンショット       |

#### トラブルシューティング

**起動後に画面が真っ黒:**

- ジャーナルを確認: `journalctl -b | grep hyprland`
- NVIDIA カーネルパラメータを確認: `cat /sys/module/nvidia_drm/parameters/modeset`（`Y` と表示されるべき）

**Electron アプリが Wayland を使わない:**

- NixOS では Hyprland Nix module で `NIXOS_OZONE_WL=1` を設定済み

**画面ティアリング:**

- NVIDIA driver と Hyprland log を確認: `journalctl -b -k | grep -i nvidia`

**モニターが検出されない:**

- モニター一覧: `hyprctl monitors`
- `~/.config/hypr/monitors.lua` を編集

詳細なヘルプ:

- Hyprland Wiki: https://wiki.hyprland.org
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr

## 🇯🇵 日本語機能

- **日本語入力**: エディタとデスクトップの日本語入力設定
- **文章校正**: 技術文書用 textlint
- **メディアスタイル**: WEB+DB PRESS、TechBooster スタイルガイド

## 🛠️ 開発ツール

### プログラミング言語

- **Python**: Nix 提供の Python と uv / pipx によるパッケージ運用
- **Node.js**: Nix 提供のNode.jsをfallbackとし、miseでプロジェクト単位に上書き
- **pnpm**: miseでプロジェクトのバージョンを選択し、非interactive shellではshimsを利用
- **Rust**: Nix 提供の cargo / rustc / clippy / rustfmt
- **Go**: Nix 提供の Go と必要に応じたプロジェクト単位の上書き
- **Java**: Nix 提供の OpenJDK と必要に応じたプロジェクト単位の上書き

### 開発環境

- **エディタ**: Neovim（LSP、補完、デバッグ）
- **ターミナル**: WezTerm（カスタムテーマ、SSH 統合）
- **Git**: 高度設定、lazygit インターフェース
- **コンテナ**: Docker、Docker Compose セットアップ
- **モバイル**: Flutter、FVM バージョン管理

### Node.js / pnpm のプロジェクト単位解決

グローバルのfallbackはNixが提供し、プロジェクトの`mise.toml`に定義したバージョンを優先します。
Zshはinteractive shellではmiseの実体PATHを、login/non-interactive shellではプロジェクトを認識するshimsを読み込みます。

```bash
cd ~/git/<project>
node --version
pnpm --version
```

## 📄 ライセンス

[MIT License](LICENSE) - 自由に使用・改変してください。
