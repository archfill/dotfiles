# Hammerspoon設定ベストプラクティス

macOS自動化ツールHammerspoonの設定管理に関するベストプラクティス。

## 概要

Hammerspoonは、Luaスクリプトを使用してmacOSを自動化するツール。ウィンドウ管理、ホットキー設定、アプリケーション制御などが可能。

## ディレクトリ構造

### シンプルな構成（現在採用）

```
~/.hammerspoon/
└── init.lua              # 全設定を1ファイルに集約
```

### モジュラー構成（大規模設定向け）

```
~/.hammerspoon/
├── init.lua              # ブートストラップ（モジュール読み込み）
├── config.lua            # 設定値の集約
├── modules/              # 機能別モジュール
│   ├── reload.lua        # 設定リロード
│   ├── hotkeys.lua       # ホットキー定義
│   ├── windows.lua       # ウィンドウ管理
│   └── apps.lua          # アプリ起動
└── utils/                # ユーティリティ
    ├── import.lua        # カスタムrequire
    └── helpers.lua       # ヘルパー関数
```

## 設計原則

### 1. データ駆動設計

ホットキーや設定をテーブルで管理し、ループで処理する：

```lua
-- 設定をデータとして定義
local appLaunchers = {
    { key = "e", app = "Ghostty" },
    { key = "b", app = "Arc" },
}

-- ループで登録
for _, config in ipairs(appLaunchers) do
    hs.hotkey.bind(hyper, config.key, function()
        toggleApp(config.app)
    end)
end
```

**メリット:**
- 新しいアプリ追加時、テーブルに1行追加するだけ
- 設定と実装の分離
- 一覧性が高い

### 2. Hyper Keyパターン

キーボード (ZMK の MONA2) のキーマップに「Hyper Key」（Ctrl+Cmd+Alt+Shift同時押し）を割り当てる：

```lua
local hyper = { "ctrl", "cmd", "alt", "shift" }
hs.hotkey.bind(hyper, "e", function() ... end)
```

**メリット:**
- 他のアプリとショートカットが衝突しない
- 1キーで4修飾キーを同時に送れる
- 覚えやすいキーバインド

### 3. 関数の再利用

共通処理は関数として抽出：

```lua
local function toggleApp(appName)
    local app = hs.application.get(appName)
    if app == nil then
        hs.application.launchOrFocus("/Applications/" .. appName .. ".app")
    elseif app:isFrontmost() then
        app:hide()
    else
        hs.application.launchOrFocus("/Applications/" .. appName .. ".app")
    end
end
```

### 4. 自動リロード

設定ファイル変更時に自動リロード（オプション）：

```lua
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    hs.reload()
end):start()
hs.alert.show("Config loaded")
```

## Spoon（公式モジュール形式）

Spoonは再利用・共有可能なHammerspoonモジュール形式。

### 主要なSpoon

| Spoon | 機能 |
|-------|------|
| `ReloadConfiguration` | 設定自動リロード |
| `WindowHalfsAndThirds` | ウィンドウ分割 |
| `Caffeine` | スリープ防止 |
| `ClipboardTool` | クリップボード履歴 |

### Spoonのインストール

```lua
-- SpoonInstallを使用
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("ReloadConfiguration", {
    start = true
})
```

**公式リポジトリ:** https://www.hammerspoon.org/Spoons/

## 活用例・ユースケース

### ウィンドウ操作・管理

```lua
-- ウィンドウを画面左半分に配置
hs.hotkey.bind({"ctrl", "alt"}, "H", function()
    hs.window.focusedWindow():moveToUnit(hs.layout.left50)
end)

-- アプリごとに位置を固定（ワークスペース復元）
hs.layout.apply({
    {"Google Chrome", nil, "Screen 1", hs.geometry.rect(0, 0, 0.7, 1)},
    {"iTerm2",        nil, "Screen 1", hs.geometry.rect(0.7, 0, 0.3, 1)},
})
```

### ホットキー・キーマッピング

```lua
-- キーでアプリ起動（起動済みならフォアグラウンドに）
hs.hotkey.bind({"cmd", "alt"}, "T", function()
    hs.application.launchOrFocus("iTerm")
end)
```

### マウス・ポインタ操作

```lua
-- フォーカスウィンドウ中央へマウス移動
hs.hotkey.bind({"alt"}, "F", function()
    local win = hs.window.focusedWindow()
    if win then
        local p = win:frame().center
        hs.mouse.setAbsolutePosition(p)
    end
end)
```

### 自動化ワークフロー

```lua
-- 毎時通知で休憩リマインド
hs.timer.doEvery(3600, function()
    hs.notify.new({title="休憩", informativeText="立ち上がって一息つこう"}):send()
end)

-- ダウンロードフォルダ監視
hs.pathwatcher.new("/Users/you/Downloads", function(files)
    for _, file in ipairs(files) do
        print("changed:", file)
    end
end):start()
```

### 外部サービス・API連携

```lua
-- Home Assistant / IoT連携
hs.http.asyncPost("https://…/api/toggle_light", "{}", {["Authorization"]="Bearer …"})

-- Spotify制御
hs.spotify.playpause()
hs.spotify.next()
```

### 状態監視・イベントハンドリング

```lua
-- アクティブアプリ変化を監視
hs.application.watcher.new(function(appName, eventType)
    if eventType == hs.application.watcher.activated then
        hs.alert.show("Switched to: " .. appName)
    end
end):start()

-- Wi-Fi接続によるトリガ（プロファイル自動切替）
hs.wifi.watcher.new(function()
    local ssid = hs.wifi.currentNetwork()
    if ssid == "OfficeWiFi" then
        -- 仕事用環境セット
    end
end):start()
```

### GUI自作（HUD・ステータス）

```lua
-- カスタムHUD表示
local label = hs.drawing.text(hs.geometry.rect(100, 100, 200, 50), "NOTIFY")
label:show()
```

### システム情報取得

```lua
-- バッテリー残量を取得
local battery = hs.battery.percentage()

-- Wi-Fi情報を取得
local wifi = hs.wifi.currentNetwork()
```

## ユースケース早見表

| できること | 実例 |
|------------|------|
| 繰り返し作業を省略 | 特定ディレクトリの整理を自動化 |
| キーで何でも操作 | アプリ起動 → ウィンドウ配置 → ターミナル実行 |
| 状態に反応 | Wi-Fi変化 → 自動プロファイル変更 |
| 作業空間の復元 | 1発でウィンドウ配置を再現 |
| 外部連携 | IoT家電制御、Spotify操作 |
| カスタムUI | ミニHUDでCPU/バッテリ/日時を常時表示 |

## 参考リンク

- [公式ドキュメント](https://www.hammerspoon.org/docs/)
- [Getting Started Guide](https://www.hammerspoon.org/go/)
- [Sample Configurations](https://github.com/Hammerspoon/hammerspoon/wiki/Sample-Configurations)
- [awesome-hammerspoon](https://github.com/ashfinal/awesome-hammerspoon)
- [zzamboni/hammerspoon-config](https://github.com/zzamboni/hammerspoon-config)

## 現在の設定

このdotfilesでは以下の設定を使用：

- **場所:** `.hammerspoon/`
- **方式:** モジュラー構成 + データ駆動設計
- **Hyper Key:** Ctrl + Cmd + Alt + Shift (MONA2 の ZMK キーマップで設定)

### ディレクトリ構成

```
.hammerspoon/
├── init.lua              # ブートストラップ
├── config.lua            # 設定値
├── modules/
│   ├── apps.lua          # アプリ起動 + ウィンドウスイッチャー
│   ├── windows.lua       # ウィンドウ管理
│   ├── pip_avoidance.lua # dアニメ再生ポップアップの自動退避
│   ├── groups.lua        # ウィンドウグループ
│   ├── fzf.lua           # FZFウィンドウスイッチャー
│   └── reload.lua        # 設定リロード
├── utils/
│   └── helpers.lua       # ヘルパー関数
└── Spoons/
    ├── FzfFilter.spoon/
    └── FzfWindowSwitcher.spoon/
```

### キーバインド一覧

| キー | 機能 | モジュール |
|------|------|-----------|
| **アプリ起動** |||
| Hyper + E | Ghostty 起動/非表示 | apps |
| **ウィンドウスイッチャー** |||
| Hyper + C | ウィンドウ切替 (UI表示) | apps |
| Hyper + W | FZF ウィンドウスイッチャー | fzf |
| **ウィンドウ管理** |||
| Hyper + F | 最大化トグル | windows |
| Hyper + H | 左のウィンドウにフォーカス | windows |
| Hyper + J | 下のウィンドウにフォーカス | windows |
| Hyper + K | 上のウィンドウにフォーカス | windows |
| Hyper + L | 右のウィンドウにフォーカス | windows |
| **dアニメ自動退避** |||
| Hyper + O | 再生ウィンドウの登録/解除をトグル | pip_avoidance |
| Hyper + I | dアニメ自動退避の有効/無効 | pip_avoidance |
| **ウィンドウグループ** |||
| Hyper + G | グループに追加/削除 | groups |
| Hyper + N | 次のウィンドウ | groups |
| Hyper + P | 前のウィンドウ | groups |
| **システム** |||
| Hyper + R | 設定リロード | reload |

### dアニメ再生ポップアップの自動退避

dアニメストアの再生ポップアップを、Cursorや他のアクティブウィンドウと重ならない四隅へ自動移動します。

1. dアニメストアで再生ポップアップを開く
2. 再生ポップアップをクリックしてフォーカスする
3. **Hyper + O** を押して対象ウィンドウを登録する
4. Cursorなどへ切り替えると、重複面積の少ない角へ移動する

新しく作られたブラウザウィンドウのタイトルに `dアニメ` または `animestore` が含まれる場合は自動登録も試みます。自動検出できない場合は、手動登録を使用してください。

登録済みの状態で **Hyper + O** を押すと登録を解除します。別のウィンドウを登録する場合は、いったん解除してから、そのウィンドウをフォーカスして再度押してください。

登録中は再生ポップアップの周囲に水色の枠線が表示されます。枠線はポップアップの移動・最小化・終了にも追従して表示/非表示が切り替わります。色や太さを変える場合は `config.lua` の `config.pipAvoidance.border` を変更してください。

候補は常に四隅のままです。四隅の重なり具合が同程度の場合に上段/下段のどちらを優先するかを、`config.lua` の `config.pipAvoidance.preferredVerticalPosition`（`"top"` または `"bottom"`）で選べます。

**Hyper + I** で自動退避を一時停止できます。通常のフォーカス変更では前面化せず、ポップアップを実際に移動したときだけ前面化を試みます。Chromeでその移動時にもアクティブ化される場合は、`config.lua` の `config.pipAvoidance.raiseTarget` を `false` にしてください。再生ポップアップは通常のブラウザウィンドウのため、フルスクリーンSpace上での常時最前面表示は保証されません。

### 設定のカスタマイズ

`config.lua` で設定を変更可能：

```lua
-- アプリランチャー追加
config.appLaunchers = {
    { key = "e", app = "Ghostty" },
    { key = "b", app = "Arc" },  -- 追加
}

-- ウィンドウグループのキー変更
config.groups = {
    keys = {
        toggle = "g",
        next = "n",
        prev = "p",
    },
}
```
