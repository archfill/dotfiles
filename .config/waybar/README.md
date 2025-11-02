# Waybar Configuration

環境固有のモニター設定を分離管理するWaybar設定です。シングル/デュアルディスプレイ両対応。

## 📁 ファイル構成

```
.config/waybar/
├── config.template.jsonc   # テンプレート（Git管理）
├── config.jsonc            # 生成ファイル（.gitignore）
├── monitors.env.example    # サンプル設定（Git管理）
├── monitors.env            # 環境固有設定（.gitignore）
├── build-config.sh         # ビルドスクリプト
├── style.css               # スタイルシート
└── README.md               # このファイル
```

## 🚀 セットアップ

### 1. モニター設定ファイルを作成

```bash
cd ~/.config/waybar
cp monitors.env.example monitors.env
```

### 2. モニター名を確認

```bash
hyprctl monitors
```

出力例:
```
Monitor DP-6 (ID 1):
    3440x1440@99.98200 at 1920x0
    ...

Monitor HDMI-A-2 (ID 0):
    1920x1080@60.00000 at 0x0
    ...
```

### 3. monitors.env を編集

```bash
nvim monitors.env
```

**シングルディスプレイの場合（デフォルト）:**
```bash
# Main monitor (Workspaces 1-10)
MONITOR_MAIN=DP-1  # 実際のモニター名に変更

# Sub monitor (leave empty for single display)
MONITOR_SUB=""
```

**デュアルディスプレイの場合:**
```bash
# Main monitor (Workspaces 1-5)
MONITOR_MAIN=DP-1  # 実際のモニター名に変更

# Sub monitor (Workspaces 6-10)
MONITOR_SUB=HDMI-A-1  # 実際のモニター名に変更
```

### 4. 設定をビルド

```bash
./build-config.sh
```

これで以下が自動実行されます：
- `config.jsonc` の生成
- waybar の再起動

### 📊 ワークスペース割り当て

ビルドスクリプトは自動的にディスプレイ構成を検出します：

**シングルディスプレイ:**
- ワークスペース 1-10: すべてメインモニターに割り当て

**デュアルディスプレイ:**
- ワークスペース 1-5: メインモニター
- ワークスペース 6-10: サブモニター

## 🔄 設定変更時

### テンプレートを編集した場合

```bash
# config.template.jsonc を編集後
./build-config.sh
```

### モニター構成が変わった場合

```bash
# monitors.env を編集後
./build-config.sh
```

## 💡 トラブルシューティング

### Q: シングル/デュアルディスプレイを切り替えたい

**A:** `monitors.env` の `MONITOR_SUB` を編集してビルドし直してください。

**デュアル → シングル:**
```bash
# monitors.env を編集
MONITOR_SUB=""  # 空にする

# 再ビルド
./build-config.sh
```

**シングル → デュアル:**
```bash
# monitors.env を編集
MONITOR_SUB=HDMI-A-1  # 実際のモニター名を設定

# 再ビルド
./build-config.sh
```

### Q: GPU追加後にwaybarが正しく表示されない

**A:** モニター名が変わった可能性があります。

```bash
# 現在のモニター名を確認
hyprctl monitors

# monitors.env を更新
nvim monitors.env

# 再ビルド
./build-config.sh
```

### Q: envsubst コマンドが見つからない

**A:** gettext パッケージをインストールしてください。

```bash
# Arch Linux
sudo pacman -S gettext

# Ubuntu/Debian
sudo apt install gettext-base
```

### Q: waybarが起動しない

**A:** 設定ファイルの構文エラーを確認してください。

```bash
# waybarをフォアグラウンドで起動（エラーを確認）
waybar

# ログを確認
journalctl -u waybar --user -f
```

## 🎨 カスタマイズ

### ワークスペース割り当てを変更

`config.template.jsonc` の `persistent-workspaces` セクションを編集：

```jsonc
"persistent-workspaces": {
  "${MONITOR_MAIN}": [1, 2, 3],  // メインモニターに3つ
  "${MONITOR_SUB}": [4, 5, 6]    // サブモニターに3つ
}
```

編集後、`./build-config.sh` を実行してください。

## 📝 Git管理

### 追跡されるファイル
- `config.template.jsonc` - テンプレート
- `monitors.env.example` - サンプル設定
- `build-config.sh` - ビルドスクリプト
- `style.css` - スタイルシート

### 追跡されないファイル（.gitignore）
- `config.jsonc` - 生成ファイル
- `monitors.env` - 環境固有設定

## 🔗 関連ドキュメント

- [Hyprland monitors.conf](../hypr/monitors.conf.example)
- [Waybar公式ドキュメント](https://github.com/Alexays/Waybar/wiki)
