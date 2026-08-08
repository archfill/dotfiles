# Hyprland configuration

Hyprland 0.55 以降の Lua 設定です。メインの読み込み先は
`~/.config/hypr/hyprland.lua` です。設定の追加・変更は Lua に行います。

## ファイル構成

```
.config/hypr/
├── hyprland.lua             # メイン設定（Git 管理）
├── colors.lua               # 配色の安定ラッパーと既定値（Git 管理）
├── colors_generated.lua     # Matugen の配色（.gitignore）
├── modules/                 # 役割別の Lua モジュール（Git 管理）
│   ├── appearance.lua       # 入力・見た目・アニメーション
│   ├── autostart.lua        # セッション起動処理
│   ├── environment.lua      # 環境変数
│   ├── monitors.lua         # モニターとローカル規則の読み込み
│   ├── rules.lua            # 共有ウィンドウ規則
│   └── keybinds.lua         # キーバインド
├── monitors.lua.example     # モニター設定の雛形（Git 管理）
├── monitors.lua             # このマシンのモニター配置（.gitignore）
├── auto-detect-monitors.sh  # monitors.lua の生成器
├── hypridle.conf            # hypridle 用の hyprlang 設定
└── README.md
```

`hyprland.lua` は各モジュールを順に読み込むだけの入口です。`monitors.lua` がない
クリーンなチェックアウトでも、Hyprland は既定のモニター設定で起動できます。

`colors.lua` は `colors_generated.lua` を優先します。後者は Matugen が壁紙・配色変更時に
生成するローカルファイルで、Git 管理の既定色を上書きしません。

## モニター設定

モニター名・配置は機器固有なので Git 管理しません。自動生成するか、雛形から作成します。

```bash
cd ~/.config/hypr
./auto-detect-monitors.sh

# または手動で作成
cp monitors.lua.example monitors.lua
nvim monitors.lua
```

自動生成用の Make ターゲットも使えます。

```bash
make monitors
make monitors-auto
make monitors-single
make monitors-dual
```

最小構成は次の形です。

```lua
return {
  cursor_default_monitor = "DP-1",
  monitors = {
    {
      output = "DP-1",
      mode = "preferred",
      position = "auto",
      scale = 1,
    },
  },
  workspace_groups = {},
  window_rules = {},
}
```

複数モニターでは `monitors` に出力を追加し、`workspace_groups` に範囲を指定します。
出力名に依存するウィンドウ規則も `window_rules` に置きます。

```lua
workspace_groups = {
  { first = 1, last = 5, monitor = "DP-1" },
  { first = 6, last = 10, monitor = "HDMI-A-1" },
}

window_rules = {
  { match = { class = "gamescope" }, monitor = "DP-1" },
}
```

モニター名と現在の解像度は `hyprctl monitors` で確認できます。回転は各モニターに
`transform = 0`（通常）から `7` の値を指定します。

## 反映と確認

Lua は保存時に再読み込みされます。明示的には以下を使えます。

```bash
hyprctl reload
hyprctl configerrors
```

再読み込み前に Lua の構文だけを確認するには、リポジトリから次を実行します。

```bash
stylua --check .config/hypr/hyprland.lua .config/hypr/colors.lua .config/hypr/modules/*.lua ~/.config/hypr/monitors.lua
```

`hyprctl reload` は稼働中のセッション設定を変えるため、モニター配置やキーバインドを
変更した直後は、別の TTY またはログインに使える入力手段を確保してから実行してください。

## hypridle の設定

`hypridle.conf` は Hyprland 本体の Lua 移行対象ではなく、引き続き hypridle の設定として
使います。

## トラブルシューティング

- Lua の読み込みエラー: `hyprctl configerrors` と
  `~/.local/state/hypr/` 配下のログを確認します。
- モニターが表示されない: `hyprctl monitors all` で出力名を確認し、
  `monitors.lua` を修正します。
- 画面を戻せない: `monitors.lua` を削除または `monitors.lua.example` から作り直して、
  `hyprctl reload` を実行します。

公式仕様は [Hyprland の設定開始ガイド](https://wiki.hypr.land/Configuring/Start/) と
[Lua バインド](https://wiki.hypr.land/Configuring/Basics/Binds/) を参照してください。
