# Hammerspoon: 方向でウィンドウを入れ替える（設計）

日付：2026-11-20

## 背景

- 左右のウィンドウの位置を入れ替える操作が、今の環境のどこにもない（Hammerspoon・Rectangle・BTT）。
  macOS 標準の「ウインドウ → 移動とサイズ変更 → 配置」は方向を指せず、マウスの操作になる
- Hyprland では `swapwindow`（方向を指して入れ替え）で行っている。指の動きをそろえたい
- Hyper は修飾キーを4つとも使っているので、グループ（`docs/plans/2026-11-19-hammerspoon-window-groups-design.md`）と
  同じく、Hyper + キーのあとに続けて押す2段の操作にする

## やること

| キー | 動き | Hyprland |
| --- | --- | --- |
| Hyper + M → H/J/K/L | 前面のウィンドウと、その方向のウィンドウの位置・大きさを入れ替える | `swapwindow` |
| Hyper + M → Esc、または1秒何も押さない | 何もせずに抜ける | － |

- 操作待ちの間は「Swap: HJKL」と短く出し、抜けたら消す（グループと同じ見せ方）
- 操作待ちの間に別の Hyper のキーを押したら、操作待ちを抜け、そのキー自身の機能は動かす（グループと同じ）
- キーは `config.windows.swapKey`（既定 `"m"`、`false` で止める）。方向は `directionalFocusKeys`（既定 H/J/K/L）

## やらないこと

- `movewindow`（入れ替えずに方向へ動かす）。Mac には並べ方の木がなく、動かす先の場所が決まらない
- 入れ替えのアニメーション

## 入れ替えの決まり

前面のウィンドウを A、方向の相手を B とする。

1. B は方向移動と同じ決め方で選ぶ（`windows.windowInDirection(A, direction)`：見えているもの、±45°）。
   B がいなければ「No window」と短く出して何もしない
2. A・B それぞれの「入れ替える単位」と、その外枠を決める
   - グループのメンバーなら、そのグループ全体。外枠はグループの `frame`（タブの帯を含む）
   - そうでなければ、そのウィンドウだけ。外枠は `win:frame()`
3. A と B が同じグループなら何もしない
4. A の単位を B の外枠へ、B の単位を A の外枠へ動かす
   - グループの単位を動かすときは、グループの状態の `frame` を先に変えてから、メンバーを帯の下へ並べる
     （先に状態を変えるので、メンバーの移動の見張りが動いても、グループの frame と一致して何もしない）。
     そのあと保存し、タブを描き直す
   - ウィンドウだけの単位は `setFrame(外枠, 0)`
5. A を前面のまま残す。カーソルは `windows.moveMouseInto(A)` で A に合わせる（中にあれば動かない）

- 大きさの違うウィンドウ同士でも、そのまま外枠を入れ替える（アプリの最小の大きさで収まらない場合は、アプリ側の大きさになる）
- 別のモニターにあるウィンドウとも入れ替えられる（方向の候補に入っていれば）

## ファイル

| ファイル | 変更 |
| --- | --- |
| `.hammerspoon/modules/keymodal.lua`（新規） | 「Hyper + キー → 続けて押す」操作待ちの共通部品。グループの `init.lua` にある modal の処理（案内の表示、1秒で抜ける、Esc、別の Hyper キーで抜ける eventtap、抜けるときの後片付け）をここへ移す |
| `.hammerspoon/modules/groups/init.lua` | 操作待ちを `keymodal` で作るように変える（動きは変えない）。入れ替えのために、グループを外から扱う口を `windows` に登録する（下） |
| `.hammerspoon/modules/windows.lua` | 入れ替えの処理と Hyper + M の操作待ちを足す |
| `.hammerspoon/config.lua` | `config.windows.swapKey = "m"` とコメント |
| `.hammerspoon/README.md` | キー一覧に足す |

### グループとのつなぎ

`modules/groups` は `modules/windows` を require しているので、逆向きに require すると循環する。
そこで `windows.setGroupAdapter(adapter)` を用意し、グループの `init` が次の3つを登録する。
グループが無効なら登録されず、入れ替えはウィンドウだけの単位で動く。

| 関数 | 中身 |
| --- | --- |
| `groupOf(windowId)` | groupId か nil |
| `outerFrame(groupId)` | グループの `frame`（タブの帯を含む外枠） |
| `moveGroup(groupId, outer)` | 状態の frame を変え、メンバーを帯の下へ並べ、保存し、タブを描き直す |

## 確かめ方

自動：変更した Lua をすべて `luac -p`。`tests/hammerspoon/groups_state_test.lua` が通ること。
Hammerspoon を読み込み直してエラーがないこと（`hs -c` は軽い呼び出しだけにする。コンソール全体を返す呼び出しはしない）。

手で（ユーザーが押す）：

1. 左の Ghostty と右の Chrome で、Ghostty から Hyper + M → L → 位置と大きさが入れ替わり、Ghostty が前面のまま、枠とカーソルも Ghostty にある
2. Hyper + M のあと何も押さずに1秒待つ・Esc → 何も起きず、案内が消える
3. 方向にウィンドウがないとき Hyper + M → H → 「No window」と出て何も起きない
4. 相手がグループのとき → グループ全体（タブの帯ごと）と入れ替わる。タブもついてくる
5. 前面のウィンドウがグループのメンバーのとき → グループ全体が相手と入れ替わる
6. 縦置きのモニターのウィンドウと入れ替える（別のモニター）
7. グループの操作（Hyper + G → G / H/J/K/L / O、Esc、1秒）が今までどおり動く
8. Hyper + H/J/K/L、Hyper + -、Hyper + C / W が今までどおり動く
