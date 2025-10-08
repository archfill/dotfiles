# 🏠 Dotfiles リポジトリ

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)
[![English](https://img.shields.io/badge/lang-en-red)](README.md)

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
| Linux            | apt/pacman/dnf         | i3/polybar/Hyprland    |
| Windows          | Cygwin                 | Native                 |
| Android          | Termux                 | Native                 |

### Hyprland セットアップ (Arch Linux)

Hyprland は GPU アクセラレーションによるアニメーションと豊富なカスタマイズが可能な、モダンな Wayland コンポジタです。

#### インストール

```bash
# Hyprland とエコシステムをインストール
make hyprland-install

# インストール状態を確認
make hyprland-status
```

#### インストールされるパッケージ

**Hyprland コアパッケージ (8個):**
- `hyprland` - メインコンポジタ
- `hyprcursor` - カーソル管理
- `hypridle` - アイドルデーモン
- `hyprlock` - スクリーンロック
- `hyprpaper` - 壁紙マネージャー
- `hyprpicker` - カラーピッカー
- `hyprshot` - スクリーンショットユーティリティ
- `xdg-desktop-portal-hyprland` - デスクトップポータル統合

**必須 Wayland ツール (4個):**
- `waybar` - カスタマイズ可能なステータスバー
- `fuzzel` - 高速アプリケーションランチャー
- `swaync` - 通知センター付き通知デーモン
- `wl-clipboard` - クリップボードユーティリティ

**スクリーンショットツール (1個):**
- `satty` - スクリーンショット編集・注釈ツール

**オプションパッケージ (4個):**
- `pavucontrol` - オーディオコントロール GUI
- `brightnessctl` - 画面輝度制御
- `playerctl` - メディアプレーヤー制御 (MPRIS)
- `network-manager-applet` - ネットワーク管理 GUI

**NVIDIA 専用パッケージ (2個、NVIDIA GPU 検出時):**
- `egl-wayland` - NVIDIA 向け Wayland EGL サポート
- `libva-nvidia-driver` - NVIDIA ハードウェアアクセラレーション

#### GPU 別設定

インストールスクリプトが自動的に GPU を検出し、`~/.config/hypr/local.conf` を作成します：

**NVIDIA GPU (RTX 4070 など):**
- 最適なパフォーマンスのため 7 つの環境変数を自動設定
- VA-API ハードウェアアクセラレーション対応
- Electron/Chromium の Wayland サポート有効化（VSCode、Discord など）
- VRR/G-Sync 制御設定

**Intel/AMD GPU:**
- デフォルト Wayland 設定で空の `local.conf` を作成
- 追加設定不要

**複数 PC での利用:**
- `local.conf` は git 管理外（環境固有ファイル）
- 異なる GPU 構成でも同じ dotfiles が動作
- ハードウェアが異なっても git diff の競合なし

#### インストール後の手順

**全ユーザー向け:**
1. 設定ファイルを確認: `~/.config/hypr/hyprland.conf`
2. 必要に応じてキーバインド調整（デフォルト: Super/Windows キー）
3. 複数ディスプレイ使用時はモニターレイアウトを設定

**NVIDIA ユーザー向け（必須）:**

インストール後、スクリプトが包括的なセットアップガイドを表示します。主な手順：

1. **カーネルパラメータ**（必須）:
   ```bash
   sudo vim /etc/default/grub
   # GRUB_CMDLINE_LINUX_DEFAULT に追加:
   # nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1

   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo reboot
   ```

2. **Modprobe 設定**（推奨）:
   ```bash
   sudo tee /etc/modprobe.d/nvidia.conf <<EOF
   options nvidia_drm modeset=1
   options nvidia NVreg_PreserveVideoMemoryAllocations=1
   EOF
   ```

3. **Early KMS**（推奨）:
   ```bash
   sudo vim /etc/mkinitcpio.conf
   # 追加: MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

   sudo mkinitcpio -P
   ```

4. **サスペンド/レジューム対応**（任意）:
   ```bash
   sudo systemctl enable nvidia-suspend.service
   sudo systemctl enable nvidia-hibernate.service
   sudo systemctl enable nvidia-resume.service
   ```

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

すべての設定ファイルは `make links` でシンボリックリンクされます：

- `~/.config/hypr/hyprland.conf` - メイン設定
- `~/.config/hypr/hyprpaper.conf` - 壁紙設定
- `~/.config/hypr/hypridle.conf` - アイドル管理（画面減光、ロック、サスペンド）
- `~/.config/hypr/hyprlock.conf` - ロック画面の外観
- `~/.config/waybar/` - ステータスバー設定
- `~/.config/fuzzel/fuzzel.ini` - アプリケーションランチャー
- `~/.config/swaync/` - 通知センター
- `~/.config/hypr/local.conf` - 自動生成、GPU 固有（git 管理外）

#### デフォルトキーバインド

| キー | 動作 |
|-----|------|
| `Super + Return` | ターミナル起動（ghostty）|
| `Super + D` | アプリケーションランチャー（fuzzel）|
| `Super + Q` | アクティブウィンドウを閉じる |
| `Super + M` | Hyprland 終了 |
| `Super + F` | フルスクリーン |
| `Super + V` | フローティング切り替え |
| `Super + 1-9` | ワークスペース切り替え |
| `Super + Shift + 1-9` | ウィンドウを別ワークスペースへ移動 |
| `Super + h/j/k/l` | フォーカス移動（vim スタイル）|
| `Super + N` | 通知センター切り替え |
| `Print` | 領域スクリーンショット |
| `Shift + Print` | ウィンドウスクリーンショット |
| `Ctrl + Print` | 注釈付きスクリーンショット |

#### トラブルシューティング

**起動後に画面が真っ黒:**
- ジャーナルを確認: `journalctl -b | grep hyprland`
- NVIDIA カーネルパラメータを確認: `cat /sys/module/nvidia_drm/parameters/modeset`（`Y` と表示されるべき）

**カーソルが表示されない（NVIDIA）:**
- `local.conf` で `WLR_NO_HARDWARE_CURSORS=1` により既に設定済み

**Electron アプリが Wayland を使わない:**
- `local.conf` で `ELECTRON_OZONE_PLATFORM_HINT=auto` により既に設定済み

**画面ティアリング:**
- `local.conf` の VRR 設定を確認: `__GL_VRR_ALLOWED=0`
- G-Sync/FreeSync モニター使用時は `__GL_VRR_ALLOWED=1` を試す

**モニターが検出されない:**
- モニター一覧: `hyprctl monitors`
- `~/.config/hypr/hyprland.conf` のモニターセクションを編集

詳細なヘルプ:
- Hyprland Wiki: https://wiki.hyprland.org
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr

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

## 📄 ライセンス

[MIT License](LICENSE) - 自由に使用・改変してください。