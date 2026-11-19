# Hammerspoon ウィンドウグループの作り直し 設計

## 背景

macOS では WM を置き換えられないため、AeroSpace のように別の WM を乗せる形はやめ、
OS 標準のウィンドウ管理の上に Hammerspoon で操作を足す方針にしている。
Hyprland の「場所は方向キーで選び、同じ場所に重ねたウィンドウはグループで切り替える」
という二段の操作を Mac でも使うため、`.hammerspoon/modules/groups.lua` を作り直す。

方向移動（Hyper + H/J/K/L、`modules/windows.lua`）は、見えているウィンドウだけを候補にする形に
直してある。そのため、重ねて後ろに隠れたウィンドウには方向移動では届かない。これをグループで補う。

## 今の作りの問題

| 点 | 今 | 困ること |
| --- | --- | --- |
| グループの数 | 1つだけ（`currentGroup`） | 左半分と右半分で別々のグループを作れない |
| N / P の対象 | いつもその1つのグループ | 前面のウィンドウと関係なく動く |
| タブの表示 | 作ったときの位置に固定、常に最前面 | ほかのウィンドウを前に出してもタブだけ残る。グループを動かしてもついてこない |
| 閉じたウィンドウ | N / P を押したときにだけ外す | タブに残る |
| グループの移動 | 1つだけ動く | ほかのメンバーが元の場所に残る |
| 読み込み直し（Hyper + R） | グループが消える | 設定を触るたびに作り直し |
| 状態 | 変数3つ（`currentGroup`・`groupIndex`・`groupFrame`）を操作ごとに直接書き換える | グループを複数にすると食い違う |

## やること・やらないこと

やること

- グループを複数持てるようにする
- 状態を1か所に集め、状態を変える関数を決める
- タブの表示を状態から描き直す形にする
- 閉じた・動いた・前面が変わったウィンドウに追従する
- Hyper + R の読み込み直しでグループを残す

やらないこと

- Hyprland と同じ修飾キーの層（Super + Alt・Super + Shift）。Hyper は修飾キーを4つとも使っていて、層を足す余地がない。かわりに Hyper + G のあとに続けて押す2段のキー操作にする
- Mac の再起動・ログアウトをまたいだ保存。ウィンドウ自体が閉じるので不要（Hyprland も同じ）
- ワークスペース、自動タイル（方針で避ける）

## 操作の仕様

Hyprland（`.config/hypr/modules/keybinds.lua` の「05 Groups」）と指の動きをそろえる。
Hyper に層を足せないので、Hyper + G で「グループの操作待ち」に入り、続けて押すキーで操作を選ぶ
（`hs.hotkey.modal`）。N・P は今のまま。

| キー | 動き | Hyprland で対応するもの |
| --- | --- | --- |
| Hyper + G → G | 前面のウィンドウをグループにする。グループに入っていれば、そのグループごと解散する | Super + G（`togglegroup`） |
| Hyper + G → H/J/K/L | 前面のウィンドウを、その方向にあるグループに入れる | Super + Alt + H/J/K/L（`moveintogroup`） |
| Hyper + G → O | 前面のウィンドウだけをグループから出す | Super + Shift + G（`moveoutofgroup`） |
| Hyper + G → Esc、または1秒何も押さない | 何もせずに抜ける | － |
| Hyper + N / P | グループ内の次・前 | Super + Tab / Shift + Tab |

- 操作待ちの間は、短い表示（`hs.alert`）で「Group: G / HJKL / O」のように案内を出し、抜けたら消す
- 操作待ちのキーは `config.groups.keys` で変えられるようにする（`toggle = "g"`・`out = "o"`・方向は方向移動と同じ H/J/K/L）
- 操作待ちの間に別の Hyper のキーを押しても、ほかの機能を邪魔しない（操作待ちを抜ける）

### Hyper + G → G（グループにする・解散する）

- 前面のウィンドウ W がグループに入っていない：W だけで新しいグループを作る（位置・大きさは W のまま）
- W がグループ A に入っている：A を解散する。メンバーの位置・大きさはそのまま
- メンバーが1つのグループも残す（Hyprland と同じ）

### Hyper + G → H/J/K/L（方向のグループに入れる）

- 方向の相手は、方向移動（`modules/windows.lua` の `focusDirection`）と同じ決め方で選ぶ
  （`windowsTo<Dir>(W, frontmost = true, strict = true)` の1つ目）
- 相手がグループ A のメンバーなら、W を A に入れる。W がほかのグループに入っていれば、先にそこから出す。
  W を A の位置・大きさに合わせ、A の前面を W にする
- 相手がグループに入っていない・相手がいない：何もしない（「No group」と短く出す）。Hyprland の `moveintogroup` と同じ

### Hyper + G → O（グループから出す）

- W をグループから出す。W の位置・大きさはそのまま。グループが空になったら消す
- W がグループに入っていなければ何もしない

### 結果の表示

- 今と同じく `hs.alert` で短く出す（例：「New group: Ghostty」「Added: Claude (#2)」「Removed: Claude」「Group dissolved」「No group」）

### 新しく開いたウィンドウ

- Hyprland は、グループが前面のときに新しく開いたウィンドウを自動でグループに入れる
- Mac ではダイアログや一時的なウィンドウも開くため、既定では自動で入れない。
  `config.groups.autoJoinNewWindows = true` で、前面のグループに自動で入れられるようにする
  （`windowCreated` を見張り、その直前の前面がグループのメンバーなら入れる）

### Hyper + N / P（次・前）

- 前面のウィンドウが入っているグループの中で、次・前のメンバーを前面にする
- 前面のウィンドウがグループに入っていなければ何もしない
- メンバーが1つなら何もしない
- 前面にする処理は `modules/windows.lua` の方向移動と同じく、`raise` → `focus` のあと 0.1 秒後に確かめ、別のウィンドウ（同じアプリの別ウィンドウなど）が前面になっていたらやり直す。新しいキー操作が来たら前の確かめは取り消す

### 前面が変わったとき（クリック・Hyper + W・方向移動など）

- 前面になったウィンドウがグループのメンバーなら、そのグループの前面をそのウィンドウにする
- タブの表示を描き直す

### ウィンドウが閉じたとき

- そのウィンドウをグループから外す。グループが空になったら消す

### ウィンドウが動いた・大きさが変わったとき

- グループの前面のメンバーが動いたら、グループの位置・大きさをそれに合わせ、ほかのメンバーにも同じ位置・大きさを当てる
- 自分で当てた `setFrame` が出来事として返ってきても、もう一度当て直さない（位置・大きさが同じなら何もしない、または当てている間は出来事を無視する印を持つ）

## 状態

### 形

```lua
state = {
  version = 1,
  nextGroupId = 1,
  groups = {
    [groupId] = {
      windowIds = { 123, 456 }, -- メンバー（タブの並び順）
      activeId = 456,           -- グループの前面
      frame = { x = 0, y = 30, w = 1720, h = 1410 },
    },
  },
  windowToGroup = { [123] = groupId, [456] = groupId }, -- 逆引き
}
```

- ウィンドウは `hs.window` のオブジェクトではなく番号（`win:id()`）で持つ。オブジェクトは使うときに `hs.window.get(id)` で引く
- `windowToGroup` は `groups` から作り直せる。保存はせず、読み込むときに作る

### 状態を変える関数

状態を変えるのはこの関数だけにする。`hs.*` を呼ばない純粋な関数にして、単体で試せるようにする。

| 関数 | 中身 |
| --- | --- |
| `createGroup(state, windowId, frame)` | 1つだけのグループを作る。groupId を返す |
| `addWindow(state, groupId, windowId)` | メンバーに足し、前面にする |
| `removeWindow(state, windowId)` | メンバーから外す。空のグループは消す |
| `dissolve(state, groupId)` | グループを解散する |
| `setActive(state, windowId)` | そのウィンドウのグループの前面にする（メンバーでなければ何もしない） |
| `nextId(state, windowId, step)` | 同じグループの次（step = 1）・前（step = -1）のウィンドウの番号を返す。状態は変えない |
| `setFrame(state, groupId, frame)` | グループの位置・大きさを変える |
| `prune(state, existsFn)` | `existsFn(id)` が false のウィンドウを外し、空のグループを消す |
| `groupOf(state, windowId)` | groupId を返す |
| `serialize(state)` / `deserialize(table)` | 保存用の表に変える・戻す（`windowToGroup` は戻すときに作る） |

### 保存

- 置き場所：`~/.local/state/hammerspoon/groups.json`（`config.groups.stateFile` で変えられるようにする）
- 書く：状態を変える関数を呼んだあと毎回 `hs.json.write` で書く。フォルダがなければ作る
- 読む：起動時に読み、`prune` で `hs.window.get(id)` が nil のウィンドウを外す
  - Mac の再起動後や、アプリを開き直したあとは、番号がもう無いので自然に外れる
- 読めない・形が違う（`version` が合わない）ときは、空の状態で始める（エラーにしない）
- dotfiles の外に置くので、コミットに混ざらない

## 作りの分け方

`modules/groups.lua` を次のように分ける。`require("modules.groups")` で今と同じく読めるように、
`modules/groups/init.lua` を入口にする（Hammerspoon が `?/init.lua` を探すことを実装時に確かめる。
探さない場合は `modules/groups.lua` を入口にして `modules.groups_state` などの名前にする）。

| ファイル | 役割 |
| --- | --- |
| `modules/groups/state.lua` | 状態の形と、状態を変える純粋な関数（`hs.*` を使わない） |
| `modules/groups/store.lua` | 保存先への読み書き |
| `modules/groups/tabbar.lua` | タブの表示。状態と前面のウィンドウを受け取って描き直すだけ。状態は持たない |
| `modules/groups/init.lua` | キーの登録（`hs.hotkey.modal` の操作待ちを含む）、ウィンドウの出来事の見張り、上の3つをつなぐ |

方向の相手を選ぶ処理は `modules/windows.lua` と同じものを使う。`windows.lua` の中の、フィルタを作る処理と
「方向の1つ目の候補を返す」処理を外から呼べるようにして（例：`windows.windowInDirection(win, direction)`）、
グループ側はそれを呼ぶ。前面にする処理（`raise` → `focus` → 0.1 秒後に確かめる）も共通にする。

### タブの表示

- 前面のウィンドウがグループのメンバーのときだけ、そのグループのタブを出す。それ以外は消す
  - ほかのグループのタブまで出すと、`hs.canvas` は常に最前面なので、ほかのウィンドウの上に残ってしまう
- 位置はグループの `frame` の上端。グループが動いたら描き直す
- 見た目（色・高さ・アプリ名の切り詰め）は今の `groups.lua` のものを使う
- タブの文字はアプリ名のまま（同じアプリが2つ並ぶ場合は、題名を短くして足すかを実装時に見て決める）

### ウィンドウの出来事の見張り

- `hs.window.filter` を1つ作り、`windowFocused`・`windowDestroyed` を購読する
- 動いた・大きさが変わったは、`windowMoved` を使わず、グループのメンバーごとに `hs.uielement` の見張り
  （`win:newWatcher`、`windowMoved`・`windowResized`）で受け取る
  - `hs.window.filter` の `windowMoved` は、動きが止まってから 0.5 秒待って出る作り（`window_filter.lua` の
    `WINDOWMOVED_DELAY`）で、ドラッグ中にメンバーが追従しなかったため（実装後に直した）
  - ドラッグ中はメンバーを動かすのを 0.03 秒に1回までにまとめ、保存は止まってから 0.5 秒後に1回にする
  - 見張りは、状態を保存するたびにメンバーの一覧と突き合わせて付け外しする
- フィルタは方向移動と同じく、普通のウィンドウだけ（`allowRoles = "AXStandardWindow"`）
- 出来事の処理は「状態を変える関数を呼ぶ → 保存 → タブを描き直す」だけにする

## 設定（`config.lua`）

```lua
config.groups = {
	enabled = true,
	-- toggle: 操作待ちに入るキー（Hyper + toggle）。操作待ちの中で toggle をもう一度押すと
	-- グループにする・解散する。out: グループから出す。方向は H/J/K/L
	keys = { toggle = "g", out = "o", next = "n", prev = "p" },
	-- 前面のグループに、新しく開いたウィンドウを自動で入れる（Hyprland の既定の動き）
	autoJoinNewWindows = false,
	-- 保存先（省略時は ~/.local/state/hammerspoon/groups.json）
	-- stateFile = os.getenv("HOME") .. "/.local/state/hammerspoon/groups.json",
}
```

## 確かめ方

### 状態の関数（自動）

- `tests/hammerspoon/groups_state_test.lua` を作り、`state.lua` を単体で試す
  - 足す・外す・空のグループが消える・次と前が一周する・`prune`・`serialize` → `deserialize` で元に戻る
- 実行：`nix shell nixpkgs#lua5_4 -c lua tests/hammerspoon/groups_state_test.lua`（Hammerspoon の Lua は 5.4）

### 実際のウィンドウ（手で）

1. 左半分の Ghostty で Hyper + G → G → 新しいグループ
2. 左半分の外に置いた Claude を前面にし、Ghostty が左にある状態で Hyper + G → H → Claude が Ghostty の位置に重なり、グループに入る
3. 右半分の Chrome で Hyper + G → G → 2つ目のグループ。Element を同じように方向で入れる
4. 左のグループで Hyper + N / P → 左のグループの中だけで回る。右も同じ
5. Hyper + L で右のグループに移る → タブが右のグループのものに変わる
6. Hyper + G → O → 前面のウィンドウだけがグループから出る
7. Hyper + G → G（グループの中で）→ グループごと解散する
8. Hyper + G のあと何も押さずに1秒待つ・Esc → 何も起きず、案内が消える
9. 方向の相手がグループに入っていないとき Hyper + G → H/J/K/L → 「No group」と出て何も起きない
10. グループのメンバーを閉じる → タブから消える
11. 前面のメンバーを Rectangle（Hyper + 矢印）で動かす → ほかのメンバーとタブがついてくる
12. Hyper + R → グループとタブが元に戻る。`~/.local/state/hammerspoon/groups.json` の中身が合っている
13. グループに入っていないウィンドウで Hyper + N / P → 何も起きない
14. 方向移動（Hyper + H/J/K/L）とウィンドウ切替（Hyper + C / W）が今までどおり動く

## 終わったら直すもの

- `.hammerspoon/README.md` のキー一覧とグループの説明
- `.hammerspoon/config.lua` の `config.groups` のコメント
