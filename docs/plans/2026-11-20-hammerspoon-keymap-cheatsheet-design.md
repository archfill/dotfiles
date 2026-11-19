# Hammerspoon: キーの一覧とランチャー（Hyper + U）（設計）

日付：2026-11-20

## 背景

- Hyper のキーが増えた（方向移動、直前のウィンドウ、入れ替え、グループ、配置など）。何があるかを見る場所がない
- Hyprland の `.config/hypr/modules/keybinds.lua` は `bind("05 Groups", キー, "Next group tab", 動き)` のように
  分類と説明つきで登録している。Mac でも同じ形にして、一覧をそこから作る
- Alfred ではなく Hammerspoon で作る。キーを登録しているのが Hammerspoon なので、一覧の直し忘れが起きず、
  選んだ動きもそのまま呼べる（Alfred からだと毎回 `hs -c` か URL を経由して遅い）

## やること

- Hyper + U（`config.cheatsheet.key`、既定 `"u"`、`config.cheatsheet.enabled = false` で止める）で一覧を出す
- 一覧は `hs.chooser`。Hyper + W と同じ見た目（幅をピクセルで指定して画面の幅から割合を計算、暗い背景）
  - 各行：大きい文字 = 「Hyper + H　左のウィンドウへ移る」、小さい文字 = 分類
  - 打って絞り込む（キーの表記・説明・分類のどれでも当たる）
  - Enter で実行する。Hyper + U をもう一度押すと閉じる
  - 並び順は分類の順、その中は登録した順
- 実行は、一覧を閉じて元のウィンドウに前面が戻ってから行う（`hs.timer.doAfter(0.1, fn)` など）。
  前面のウィンドウを対象にする操作（方向移動、グループ、入れ替え）が、一覧ではなく元のウィンドウに効くようにする
- 2段の操作は1行ずつに分ける（例：「Hyper + G → G　グループにする／解散する」「Hyper + M → L　右のウィンドウと入れ替える」）。
  選んだら、操作待ちを通さずにその動きを直接呼ぶ
- Hammerspoon の外のキーは、一覧に出すだけで実行しない（行の小さい文字に「表示のみ」と出す）
  - Rectangle：Hyper + ← / → / ↑ / ↓（左・右・上・下の半分）
  - Alfred：Hyper + V（クリップボードの履歴）
  - Hyper + C（ウィンドウの切り替え）も表示のみ。`hs.window.switcher` は修飾キーを離したときに決まる作りで、一覧から呼べない

## キーを U にした理由（実装後に直した）

- 最初は Hyper + / にしたが、押しても Hammerspoon に届かなかった。macOS のキー配送のログにも、修飾キーの記録だけで / を押した記録が残らない
- Hyper + . も同じで、こちらは macOS の sysdiagnose のキー（⌃⌥⇧⌘.）。Hyper + , は stackshot のキー。
  どちらもアプリより先に macOS が取り、変えられない
- / は何に使われているか特定できなかった（システム設定・BTT・Alfred に割り当てはない）。記号のキーは避け、
  H/J/K/L から指を上げるだけで押せる U にした

## やらないこと

- 一覧の中でキーを変える・足す
- Alfred 側に同じ一覧を作る

## 分類

| 順 | 分類 | 中身 |
| --- | --- | --- |
| 1 | ウィンドウの移動 | H/J/K/L、-、C、W |
| 2 | 配置 | 矢印（Rectangle）、A/S/Z/X、F、M → H/J/K/L |
| 3 | グループ | G → G・H/J/K/L・O、N、P |
| 4 | アプリ | E（Ghostty）など `config.appLaunchers` |
| 5 | そのほか | V（Alfred）、R（読み込み直し）、/（この一覧）、dアニメの退避が有効なら O・I |

## 作り

### `modules/keymap.lua`（新規）

キーの登録と一覧の元になる記録を1か所にまとめる。

| 関数 | 中身 |
| --- | --- |
| `keymap.bind(mods, key, info, fn)` | `hs.hotkey.bind` を呼び、`info`（`category`・`description`）と一緒に記録する。hotkey を返す |
| `keymap.add(entry)` | キーを登録せずに記録だけする。2段の操作の各行、Hammerspoon の外のキー、別の仕組みで登録したキー（Spoon の W）に使う。`entry = { category, label, description, fn = nil か関数 }` |
| `keymap.entries()` | 分類の順、登録した順に並べた一覧を返す |

- 表記（label）は `keymap.bind` が mods とキーから作る（Hyper の4つがそろっていれば「Hyper」、矢印は ← → ↑ ↓、ほかは大文字）
- 分類の名前と順は `keymap.lua` の中に定数で持つ（上の表）
- 読み込み直しのたびに記録は作り直される（モジュールの読み込みごとに空から始まる）

### 今ある登録の置き換え

`modules/` の `hs.hotkey.bind` をすべて `keymap.bind` に変え、説明を付ける。動きは変えない。

- `windows.lua`：F、矢印（`enablePositioning` が true のときだけ。false のときは Rectangle の表示のみの行を `keymap.add`）、A/S/Z/X、-、H/J/K/L、M の各方向
- `groups/init.lua`：N、P、G の各操作
- `apps.lua`：アプリ（`config.appLaunchers`）、C（表示のみの行にするので `keymap.bind` の info に `runnable = false` を付けるか、bind のあと記録を表示のみにする）
- `reload.lua`：R
- `fzf.lua`：W（Spoon 側の hotkey の付け替えはそのまま、`keymap.add` で記録だけ）
- `pip_avoidance.lua`：有効なときだけ O・I（今は無効なので出ない）
- 2段の操作：`keymodal` の `bindAction` に `info` を渡せるようにし、`keymap.add` で「Hyper + G → G」のような行を記録する
  （fn は操作待ちを通さない、その動きそのもの）
- Alfred の V は `keymap.add` で表示のみ

### `modules/cheatsheet.lua`（新規）

- `keymap.entries()` から `hs.chooser` の行を作る。Hyper + U で開く・閉じる
- 見た目の設定は `config.fzf.ui` を使い回す（幅のピクセル、暗い背景）。案内の文は「キーを検索」
- 一覧は開くたびに作り直す（説明の文字列だけなので軽い）
- `init.lua` では、ほかのモジュールをすべて読み込んだあとに `cheatsheet.init` を呼ぶ

### 説明の文

- 一覧に出る説明・分類は日本語（ユーザーが読む UI の文字。Hyper + W の案内も日本語）
- コードのコメントは今までどおり英語

## ファイル

| ファイル | 変更 |
| --- | --- |
| `.hammerspoon/modules/keymap.lua` | 新規 |
| `.hammerspoon/modules/cheatsheet.lua` | 新規 |
| `.hammerspoon/modules/keymodal.lua` | `bindAction` で info を受けて `keymap.add` する |
| `.hammerspoon/modules/{windows,apps,reload,fzf,pip_avoidance}.lua`・`groups/init.lua` | `keymap.bind` / `keymap.add` に置き換え、説明を付ける |
| `.hammerspoon/init.lua` | 最後に `cheatsheet.init` |
| `.hammerspoon/config.lua` | `config.cheatsheet = { enabled = true, key = "u" }` |
| `.hammerspoon/README.md` | キー一覧に Hyper + U を足し、「キーを足すときは `keymap.bind` に説明を付ける」と書く |

## 確かめ方

自動：変更した Lua をすべて `luac -p`。`tests/hammerspoon/groups_state_test.lua` が通ること。
`keymap.lua` の表記を作る処理と並べる処理は `hs.*` を使わない形にして、`tests/hammerspoon/keymap_test.lua` で試す
（Hyper の表記、矢印、分類の順、登録した順）。
Hammerspoon を読み込み直してエラーがないこと（`hs -c` は軽い呼び出しだけ。コンソール全体を返す呼び出しはしない）。

手で（ユーザーが押す）：

1. Hyper + U で一覧が出る。分類の順に並び、Hyper + W と同じ見た目
2. 「グループ」「入れ替え」などで絞り込める
3. 「Hyper + L」を選ぶ → 一覧が閉じ、元のウィンドウから右へ移る
4. 「Hyper + G → G」を選ぶ → 元のウィンドウがグループになる（もう一度選ぶと解散）
5. Rectangle の矢印・Alfred の V・Hyper + C を選ぶ → 何も起きない（表示のみ）
6. Hyper + U をもう一度押すと閉じる
7. ほかのキー（H/J/K/L、-、M、G、N/P、F、A/S/Z/X、E、W、C、R）が今までどおり動く
