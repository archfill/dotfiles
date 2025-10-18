# Hyprland Configuration

環境固有のモニター設定を分離管理するHyprland設定です。シングル/デュアルディスプレイ両対応。

## 📁 ファイル構成

```
.config/hypr/
├── hyprland.conf           # メイン設定（Git管理）
├── monitors.conf.example   # シングルディスプレイのデフォルト（Git管理）
├── monitors.conf           # 環境固有設定（.gitignore）
├── local.conf              # GPU固有環境変数（.gitignore）
├── hypridle.conf           # アイドル管理設定
├── hyprlock.conf           # スクリーンロック設定
├── hyprpaper.conf          # 壁紙設定
├── examples/               # 設定例集
│   ├── monitors.conf.dual  # デュアルディスプレイの例
│   └── monitors.conf.all-examples  # 全例文集（シングル/デュアル/トリプル等）
└── README.md               # このファイル
```

## 🚀 セットアップ

### オプション A: 自動検出（推奨）⭐

接続されているモニターを自動検出して、Hyprland と Waybar の設定を自動生成します。

#### 基本的な使い方

**makeコマンド経由（推奨）:**

```bash
# インタラクティブメニューで選択
make monitors

# 自動検出（メニューをスキップ）
make monitors-auto

# シングルディスプレイを強制
make monitors-single

# デュアルディスプレイを強制
make monitors-dual
```

**スクリプト直接実行:**

```bash
cd ~/.config/hypr
./auto-detect-monitors.sh
```

スクリプトを引数なしで実行すると、**インタラクティブメニュー**が表示されます：

**ステップ1: ディスプレイモード選択**
```
═══════════════════════════════════════════════════════════
  Display Mode Selection
═══════════════════════════════════════════════════════════

Detected: 2 monitor(s)

Please select display mode:

  1) Auto (recommended - Dual display)
  2) Single display (use DP-6 only)
  3) Dual display (use both monitors)
  4) Cancel

Enter your choice [1-4]:
```

**ステップ2: モニター向き選択**

各モニターの向き（landscape/portrait）を個別に選択できます：

```
═══════════════════════════════════════════════════════════
  Primary Monitor Orientation
═══════════════════════════════════════════════════════════

Monitor: DP-6

Select orientation:

  1) Landscape (0°) - Normal horizontal
  2) Portrait Right (90°) - Rotated right
  3) Upside Down (180°) - Flipped
  4) Portrait Left (270°) - Rotated left [Recommended for portrait]

Enter your choice [1-4] (default: 1):
```

デュアルディスプレイの場合、セカンダリモニターの向きも選択します（デフォルト: Portrait Left）。

**ステップ3: サブディスプレイの配置選択（デュアルモードのみ）**

サブディスプレイをメインディスプレイに対してどこに配置するか選択できます：

```
═══════════════════════════════════════════════════════════
  Secondary Monitor Position
═══════════════════════════════════════════════════════════

Select where to place the secondary monitor:

  1) Left of primary (default)
  2) Right of primary
  3) Above primary
  4) Below primary

Enter your choice [1-4] (default: 1):
```

**自動検出モードのデフォルト:**
- プライマリモニター: Landscape (0°)
- セカンダリモニター: Portrait Left (270°)
- セカンダリ配置: Left of primary（メインの左側）

#### コマンドラインオプション

**非対話的に実行する場合（スクリプトやログイン時に便利）:**

```bash
# 自動検出（メニューをスキップ）
./auto-detect-monitors.sh --auto

# シングルディスプレイを強制
./auto-detect-monitors.sh --mode single

# デュアルディスプレイを強制
./auto-detect-monitors.sh --mode dual

# ヘルプを表示
./auto-detect-monitors.sh --help
```

**利用可能なオプション:**
- `-h, --help` - ヘルプメッセージを表示
- `-a, --auto, -y` - インタラクティブメニューをスキップして自動検出
- `-m, --mode MODE` - 表示モードを強制 (`single` または `dual`)

#### このスクリプトは何をしますか？

- 接続されているモニターを自動検出
- シングル/デュアルを自動判定（またはユーザー選択）
- **各モニターの向き（landscape/portrait）を個別に選択可能**
- **サブディスプレイの配置（上下左右）を選択可能**
- Hyprland `monitors.conf` を自動生成
- Waybar `monitors.env` を自動生成 + ビルド
- Waybar を自動再起動

**出力例:**
```
ℹ  Detecting connected monitors...
ℹ  Found 2 monitor(s)
ℹ  Primary monitor: DP-6

ℹ  Detected monitors:
  ○ HDMI-A-2 - 1920x1080@60Hz
  ● DP-6 - 3440x1440@164Hz (primary)

✓  Monitor configuration completed!
```

### オプション B: 手動設定

#### 1. モニター設定ファイルを作成

`make init` 実行時に自動的に `monitors.conf.example` から `monitors.conf` が作成されます。

手動で作成する場合:
```bash
cd ~/.config/hypr
cp monitors.conf.example monitors.conf
```

#### 2. モニター名を確認

```bash
hyprctl monitors
```

出力例:
```
Monitor DP-6 (ID 1):
    3440x1440@99.98200 at 1920x0
    description: Huawei Technologies Co., Inc. ZQE-CAA
    ...

Monitor HDMI-A-2 (ID 0):
    1920x1080@60.00000 at 0x0
    description: BenQ BenQ RL2455
    ...
```

#### 3. monitors.conf を編集

```bash
nvim ~/.config/hypr/monitors.conf
```

**シングルディスプレイの場合（デフォルト）:**
```bash
# Monitor configuration
monitor=DP-6,preferred,auto,1  # 実際のモニター名に変更
```

**デュアルディスプレイの場合:**
```bash
# 例をコピー
cp ~/.config/hypr/examples/monitors.conf.dual ~/.config/hypr/monitors.conf

# 編集
nvim ~/.config/hypr/monitors.conf
```

#### 4. Hyprlandを再起動

```bash
# Hyprland設定を再読み込み
hyprctl reload

# または Hyprlandを再起動
# Super + M (exit) → 再ログイン
```

## 💡 トラブルシューティング

### Q: GPU追加後にHyprlandが正しく表示されない

**A:** モニター名が変わった可能性があります。自動検出スクリプトで再設定するのが最も簡単です。

**方法1: makeコマンド経由（推奨）**
```bash
# インタラクティブメニューで選択
make monitors

# または自動検出（メニューをスキップ）
make monitors-auto
```

**方法2: スクリプト直接実行**
```bash
cd ~/.config/hypr
./auto-detect-monitors.sh

# または自動検出
./auto-detect-monitors.sh --auto
```

**方法3: 手動修正**
```bash
# 現在のモニター名を確認
hyprctl monitors

# monitors.conf を更新
nvim ~/.config/hypr/monitors.conf

# Hyprlandを再起動
hyprctl reload
```

### Q: シングル/デュアルディスプレイを切り替えたい

**A:** 自動検出スクリプトを実行して、希望のモードを選択します。

**makeコマンド経由（推奨）:**
```bash
# インタラクティブメニューで選択
make monitors

# または直接モードを指定
make monitors-single  # シングルディスプレイ
make monitors-dual    # デュアルディスプレイ
make monitors-auto    # 自動検出
```

**スクリプト直接実行:**
```bash
# インタラクティブモード
cd ~/.config/hypr
./auto-detect-monitors.sh

# コマンドラインで直接指定
./auto-detect-monitors.sh --mode single  # シングル
./auto-detect-monitors.sh --mode dual    # デュアル
./auto-detect-monitors.sh --auto         # 自動検出
```

**メニュー選択肢:**
- `1) Auto` - 接続されているモニター数に基づいて自動判定
- `2) Single` - プライマリモニターのみ使用
- `3) Dual` - 両方のモニターを使用

### Q: モニターの向き（縦置き/横置き）を変更したい

**A:** インタラクティブモードで各モニターの向きを個別に選択できます。

**方法1: インタラクティブモード（推奨）**
```bash
make monitors
```

メニューでディスプレイモードを選択後、各モニターの向きを選択：
- **Landscape (0°)** - 通常の横置き
- **Portrait Right (90°)** - 右に90°回転
- **Upside Down (180°)** - 180°反転
- **Portrait Left (270°)** - 左に90°回転（縦置き推奨）

**方法2: 手動で設定を編集**
```bash
# monitors.confを編集
nvim ~/.config/hypr/monitors.conf

# transform値を追加:
# monitor=HDMI-A-2,1920x1080@60,0x0,1,transform,3
# 0=landscape, 1=90°, 2=180°, 3=270°

# Hyprlandを再読み込み
hyprctl reload
```

**自動検出モードのデフォルト:**
- `make monitors-auto` を実行すると、セカンダリモニターは自動的に Portrait Left (270°) に設定されます

### Q: サブディスプレイの配置（上下左右）を変更したい

**A:** インタラクティブモードで配置を選択できます。

**方法1: インタラクティブモード（推奨）**
```bash
make monitors
```

ステップ3で配置を選択：
- **Left of primary** - メインの左側（デフォルト）
- **Right of primary** - メインの右側
- **Above primary** - メインの上
- **Below primary** - メインの下

**方法2: 手動で座標を編集**
```bash
# monitors.confを編集
nvim ~/.config/hypr/monitors.conf

# 座標を変更（例: 右側に配置）
# Primary: 0x0 (左)
# Secondary: 3440x0 (プライマリの幅分右にオフセット)

# Hyprlandを再読み込み
hyprctl reload
```

**配置例:**
```bash
# 左右配置（横並び）
monitor=HDMI-A-2,1920x1080@60,0x0,1,transform,3      # 左
monitor=DP-6,3440x1440@99,1080x0,1                   # 右 (x=1080はセカンダリの表示幅)

# 上下配置（縦並び）
monitor=HDMI-A-2,1920x1080@60,0x0,1,transform,3      # 上
monitor=DP-6,3440x1440@99,0x1920,1                   # 下 (y=1920はセカンダリの表示高さ)
```

### Q: 複数のモニター設定例が欲しい

**A:** `examples/monitors.conf.all-examples` に多数の例があります。

```bash
# 全例文集を確認
cat ~/.config/hypr/examples/monitors.conf.all-examples

# 例:
# - シングルモニター（ラップトップ/デスクトップ）
# - デュアルモニター（横配置/縦配置/ポートレート）
# - トリプルモニター
# - ラップトップ + 外部モニター
```

## 🎨 カスタマイズ

### ワークスペース割り当てを変更

monitors.confでワークスペースをモニターに割り当てできます:

```bash
# Main monitor: Workspaces 1-5
workspace=1,monitor:DP-6
workspace=2,monitor:DP-6
workspace=3,monitor:DP-6
workspace=4,monitor:DP-6
workspace=5,monitor:DP-6

# Sub monitor: Workspaces 6-10
workspace=6,monitor:HDMI-A-2
workspace=7,monitor:HDMI-A-2
workspace=8,monitor:HDMI-A-2
workspace=9,monitor:HDMI-A-2
workspace=10,monitor:HDMI-A-2
```

### モニターの回転

縦置きモニターの場合:

```bash
# transform: 0=normal, 1=90°, 2=180°, 3=270°
monitor=HDMI-A-1,1920x1080@60,0x0,1,transform,3  # 90° counter-clockwise
```

## 📝 Git管理

### 追跡されるファイル
- `hyprland.conf` - メイン設定
- `monitors.conf.example` - シングルディスプレイのデフォルト
- `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf` - その他設定
- `examples/` - 設定例集

### 追跡されないファイル（.gitignore）
- `monitors.conf` - 環境固有のモニター設定
- `local.conf` - GPU固有の環境変数

## 🔗 関連設定

- **Waybar**: モニター設定は [`~/.config/waybar/monitors.env`](../waybar/README.md) で管理
- **Hyprland公式ドキュメント**: https://wiki.hyprland.org

## 🚨 NVIDIA GPU使用時の注意

NVIDIA GPUを使用している場合、`local.conf` に環境変数が自動設定されます。

詳細は `bin/apps/tools/hyprland.sh` のインストールログを参照してください。
