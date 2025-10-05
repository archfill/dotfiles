# TUIメールクライアント比較ガイド - aerc vs NeoMutt

このドキュメントはTUI（Text User Interface）メールクライアントの選択と設定に関する包括的なガイドです。

## 目次
- [クイック比較表](#クイック比較表)
- [aerc詳細](#aerc詳細)
- [NeoMutt詳細](#neomutt詳細)
- [機能比較マトリックス](#機能比較マトリックス)
- [NeoMutt独自機能](#neomutt独自機能)
- [実際の設定例](#実際の設定例)
- [選択ガイド](#選択ガイド)
- [参考リソース](#参考リソース)

---

## クイック比較表

| 項目 | aerc | NeoMutt |
|------|------|---------|
| **開発言語** | Go | C |
| **初回リリース** | ~2019年 | 1995年（Mutt）<br>2016年（NeoMutt fork） |
| **学習曲線** | 緩やか | 急峻 |
| **設定難易度** | ⭐⭐ 簡単 | ⭐⭐⭐⭐⭐ 高難度 |
| **箱出し体験** | すぐ使える | 調整必須 |
| **カスタマイズ深度** | 中程度 | 極めて深い |
| **スクリプト言語** | なし（外部連携） | Lua統合 |
| **Notmuch統合** | ネイティブサポート | パッチ統合 |
| **Git+email** | ⭐⭐⭐⭐⭐ 最適 | ⭐⭐⭐⭐ 対応可 |
| **日本語情報** | 少ない | 豊富（ArchWiki等） |
| **開発状況** | 活発 | 成熟・安定 |

---

## aerc詳細

### 概要
- **公式サイト**: https://aerc-mail.org/
- **特徴**: モダンでシンプル、Git+emailワークフローに最適化
- **設計思想**: UNIXパイプライン哲学、小さく保ち外部ツールと連携

### アーキテクチャ

#### バックエンドサポート
- IMAP
- JMAP
- Maildir / Maildir++
- Notmuch（ネイティブ統合）
- Mbox

#### 設定ファイル構成
```
~/.config/aerc/
├── aerc.conf      # UI・一般設定（INI形式）
├── binds.conf     # キーバインド
├── accounts.conf  # アカウント情報（秘密）
├── stylesets/     # カラースキーム
└── templates/     # メールテンプレート
```

### 主要機能

#### 1. Go Templateエンジン
```template
# templates/thanks
Thanks for your contribution!

{{exec `git` `log` `--oneline` `origin/main..HEAD`}}

{{if .OriginalMIMEType eq "text/html"}}
{{exec `html` .OriginalText | wrap 72 | quote}}
{{else}}
{{wrap 72 .OriginalText | quote}}
{{end}}
```

**特徴**:
- 外部コマンド実行（`{{exec}}`）
- 条件分岐・ループ処理
- カスタム関数定義可能

#### 2. 埋め込みターミナル
```ini
[view]
gp = :term git push<Enter>
gs = :term git status<Enter>
```

aerc内で直接シェルコマンド実行可能。

#### 3. Notmuchネイティブ統合

**accounts.conf**:
```ini
[Personal]
source = notmuch:///home/user/.mail
query-map = ~/.config/aerc/queries
default = INBOX
```

**queries ファイル**:
```
Inbox=tag:inbox and not tag:archived
Sent=tag:sent
Today=date:today
ThisWeek=date:week..
Important=tag:important
Work=tag:work and tag:inbox
```

#### 4. フィルターシステム

**aerc.conf**:
```ini
[filters]
# プレーンテキスト
text/plain = wrap -w 90 | colorize

# HTML表示
text/html = w3m -I UTF-8 -T text/html -cols 90 | colorize

# パッチ表示
text/x-patch = hldiff
text/x-diff = hldiff

# カスタムフィルター
subject,~^\[PATCH = awk -f ~/.config/aerc/filters/hldiff
```

#### 5. キーバインド（コンテキスト別）

**binds.conf**:
```ini
# [messages] - メール一覧
[messages]
j = :next<Enter>
k = :prev<Enter>
gi = :cf INBOX<Enter>
gs = :cf Sent<Enter>
ga = :cf Archive<Enter>
u = :pipe urlscan<Enter>

# [view] - メール表示
[view]
ga = :pipe -mb git am -3<Enter>
rt = :reply -Tthanks<Enter>

# [compose] - メール作成
[compose]
y = :send<Enter>
a = :attach<Space>
```

#### 6. フック（自動化）

```ini
[hooks]
mail-sent = mbsync -Va && notmuch new
mail-added = notify-send "New mail" "$AERC_SUBJECT from $AERC_FROM"
tag-modified = notmuch new
aerc-shutdown = echo "Closed at $(date)" >> ~/.aerc.log
```

### 長所
✅ セットアップが簡単（5-10分）
✅ モダンなUI（tmux風タブ）
✅ Git+emailワークフローに最適
✅ Notmuchネイティブサポート
✅ Go templateで強力なテンプレート
✅ 埋め込みターミナル
✅ 設定ファイルがシンプル（INI形式）

### 短所
❌ 歴史が浅い（情報が少ない）
❌ 条件付きフォーマット不可
❌ スコアリング機能なし
❌ 内蔵スクリプト言語なし
❌ 複雑な自動化は制限あり

---

## NeoMutt詳細

### 概要
- **公式サイト**: https://neomutt.org/
- **特徴**: Muttのフォーク、高度なカスタマイズと自動化
- **設計思想**: パワーユーザー向け、完全な制御

### アーキテクチャ

#### 設定ファイル構成（推奨モジュラー構成）
```
~/.config/neomutt/
├── neomuttrc          # メイン設定
├── accounts/
│   ├── gmail.muttrc
│   └── work.muttrc
├── colors/
│   └── dracula.muttrc
├── macros.muttrc
└── aliases
```

### 主要機能

#### 1. Luaスクリプティング

**設定で有効化**:
```muttrc
set my_lua_script = ~/.config/neomutt/scripts/custom.lua
```

**Luaスクリプト例**:
```lua
-- 条件分岐処理
if mutt.get("folder") == "=INBOX" then
  mutt.set("sort", "reverse-date")
else
  mutt.set("sort", "threads")
end

-- 動的フォーマット生成
function custom_date_format(msg)
  local age = os.time() - msg.date
  if age < 86400 then
    return "%H:%M"
  else
    return "%b %d"
  end
end
```

#### 2. メッセージスコアリング

```muttrc
# 基本的なスコアリング
score "~f boss@company.com" +100
score "~s urgent" +50
score "~x 1-100" +10              # 添付ファイルあり
score "~f spam@" -100

# スコアでソート
set sort = score
set sort_aux = reverse-date

# スコアで色分け
color index brightred default "~n 100-"
color index yellow default "~n 50-99"
```

#### 3. 条件付きindex_format

```muttrc
# メールの年齢に応じて日付表示を変更
set index_format='%Z %<[y?%<[m?%<[d?%[%H:%M ]&%[%a %d]>&%[%b %d]>&%[%m/%y ]> %-15.15L %s'

# スレッド折りたたみ状態で表示変更
set index_format='%4C %Z %{%b %d} %-15.15L %?M?(#%M)&(%4l)? %s'

# スパムスコア条件付き表示
set index_format='%Z %D %?H?[%H] ?%-15.15F %s'
```

#### 4. 高度なフックシステム

**send-hook（送信先で自動設定変更）**:
```muttrc
send-hook "~t @company.com" '\
  set signature="~/.sig-work"; \
  set from="john@company.com"'

send-hook "~t @client.com" '\
  set signature="~/.sig-formal"; \
  my_hdr Reply-To: support@company.com'
```

**folder-hook（フォルダで自動設定変更）**:
```muttrc
folder-hook 'INBOX' '\
  set sort=reverse-date; \
  set index_format="%Z %D %-20.20F %s"'

folder-hook 'lists/*' '\
  set sort=threads; \
  subjectrx "^\\[.*\\] " ""'
```

**reply-hook（返信元で自動処理）**:
```muttrc
reply-hook "~f important-client@" '\
  my_hdr Cc: team@company.com'
```

**message-hook（メッセージ表示時）**:
```muttrc
message-hook '~f important@' 'set pager="vim -R"'
message-hook '~h "Content-Type: text/html"' '\
  set display_filter="html2text"'
```

#### 5. display_filter（メッセージ前処理）

```muttrc
# Teams会議リンクを見やすく整形
set display_filter="sed 's/__________.*Teams.*<\\([^>]*\\)>.*__________/Teams: \\1/'"

# 特定送信者からのメールだけフィルター
message-hook '~f @hushmail.com' 'set display_filter="dos2unix"'

# 複数処理パイプライン
set display_filter="dos2unix | sed 's/foo/bar/' | colorize"
```

#### 6. subjectrx（件名正規表現置換）

```muttrc
# [PATCH 0/3]プレフィックス削除
folder-hook 'lists/kernel' '\
  subjectrx "^\\[PATCH [0-9/]+\\] " "%R"'

# [JIRA]プレフィックス削除
folder-hook 'work/jira' '\
  subjectrx "^\\[JIRA\\] " "%R"'
```

#### 7. 複雑なパターンマッチング

```muttrc
# 新着で添付ファイル付きで自分がCCに入っていない
~N ~x 1-100 !~C myaddress@domain.com

# 1週間以内の重要メールで未読
~d <1w ~f important@boss.com ~U

# 本文に特定キーワード
~b "confidential"

# タグ操作で一括処理
T~N ~f @company.com !~s "[SPAM]"<enter>
;<save-message>=Archive<enter>
```

### 長所
✅ 極めて高度なカスタマイズ可能
✅ Lua統合でプログラマブル
✅ スコアリング・自動優先度付け
✅ 条件付きフォーマット
✅ 強力なフックシステム
✅ 豊富な日本語情報（ArchWiki等）
✅ 成熟した安定性

### 短所
❌ 学習曲線が急峻（習得に時間）
❌ 初期設定が複雑（1-3時間）
❌ 設定ファイルの記法が独特
❌ モダンなUIではない

---

## 機能比較マトリックス

### ✅ 両方で実現可能な機能

| 機能 | aerc | NeoMutt | 備考 |
|------|------|---------|------|
| **キーバインドカスタマイズ** | ✅ | ✅ | aercはコンテキスト別設定 |
| **URL抽出（urlscan）** | ✅ | ✅ | `:pipe urlscan` |
| **HTML表示** | ✅ | ✅ | w3m, pandoc等 |
| **パッチ表示** | ✅ | ✅ | hldiff等 |
| **アドレス帳統合** | ✅ | ✅ | khard, abook, notmuch |
| **テンプレート機能** | ✅ | ✅ | aercの方が強力（Go template） |
| **マクロ** | ✅ | ✅ | コマンドシーケンス実行 |
| **メール検索** | ✅ | ✅ | + notmuch統合 |
| **タグ/ラベル管理** | ✅ | ✅ | notmuchバックエンド時 |
| **複数アカウント** | ✅ | ✅ | aercはタブ形式 |
| **フック（自動化）** | ✅ | ✅ | NeoMuttの方が高度 |
| **外部コマンドパイプ** | ✅ | ✅ | `:pipe` |
| **スレッド表示** | ✅ | ✅ | 標準サポート |
| **カラースキーム** | ✅ | ✅ | 両方とも高度にカスタマイズ可 |

### ⚠️ 制限付きで実現可能

| 機能 | aerc | NeoMutt | 制限事項 |
|------|------|---------|----------|
| **サイドバー** | ✅ | ✅ | aercは常時表示（トグル不可） |
| **メール削除** | ✅ | ✅ | notmuchは`:modify-labels +deleted` |
| **仮想フォルダ** | ✅ | ✅ | notmuchバックエンド時のみ |

### ❌ NeoMuttのみ可能な機能

| 機能 | aerc | NeoMutt | 重要度 |
|------|------|---------|--------|
| **条件付きindex_format** | ❌ | ✅ | ⭐⭐⭐⭐⭐ |
| **メッセージスコアリング** | ❌ | ✅ | ⭐⭐⭐⭐ |
| **send-hook/reply-hook** | ⚠️ | ✅ | ⭐⭐⭐⭐⭐ |
| **display_filter（全体）** | ⚠️ | ✅ | ⭐⭐⭐ |
| **subjectrx** | ❌ | ✅ | ⭐⭐⭐ |
| **複雑なパターンマッチ** | ⚠️ | ✅ | ⭐⭐⭐⭐ |
| **Luaスクリプティング** | ❌ | ✅ | ⭐⭐ |
| **message-hook** | ❌ | ✅ | ⭐⭐⭐ |

---

## NeoMutt独自機能

### 1. 条件付きindex_format
メールの状態に応じて一覧表示を動的変更。

**例**: 今日のメールは時刻、古いメールは日付表示
```muttrc
set index_format='%Z %<[y?%<[m?%<[d?%[%H:%M ]&%[%a %d]>&%[%b %d]>&%[%m/%y ]> %-15.15L %s'
```

**表示結果**:
```
N  09:45  John Doe          Fix urgent bug
   Jan 15 alice@example.com Meeting tomorrow
   03/24  bob@company.com   Quarterly report
```

### 2. メッセージスコアリング
パターンマッチで自動優先度付け。

```muttrc
score "~f ceo@company.com" +200
score "~f @important-client.com" +150
score "~s 'urgent|emergency'" +100
score "~f @mailing-list.com" -50

set sort = score
```

**効果**: 受信箱を開くと重要なメールが自動的に上位表示。

### 3. send-hook（送信先で自動設定変更）
送信先ドメインで署名・From・SMTPサーバーを完全自動切り替え。

```muttrc
send-hook '~t @bigcorp.com' '\
  set from="john.doe@company.com"; \
  set signature="~/.sig-corporate"; \
  set sendmail="/usr/bin/msmtp -a work"; \
  my_hdr Bcc: archive@company.com'

send-hook '~t @opensource.org' '\
  set from="jdoe@personal.com"; \
  set signature="~/.sig-oss"; \
  set sendmail="/usr/bin/msmtp -a personal"'
```

### 4. display_filter（メッセージ前処理）
表示前にメール内容を動的変換。

```muttrc
# Teams会議リンク整形
set display_filter="perl -pe 's/__________.*Teams.*<([^>]*)>.*__________/Teams: $1/'"

# 送信者別フィルター
message-hook '~f @hushmail.com' 'set display_filter="dos2unix"'
```

### 5. subjectrx（件名正規表現置換）
メーリングリストのプレフィックス除去。

```muttrc
folder-hook 'lists/kernel' 'subjectrx "^\\[PATCH [0-9/]+\\] " "%R"'
```

**変換例**:
```
変換前: [PATCH 2/5] [linux-kernel] Fix memory leak
変換後: Fix memory leak
```

---

## 実際の設定例

### aerc設定サンプル

**~/.config/aerc/aerc.conf**:
```ini
[ui]
index-format=%D %-17.17n %Z %s
timestamp-format=2006-01-02 03:04 PM
sidebar-width=20
mouse-enabled=false
new-message-bell=true

[viewer]
pager=less -R
alternatives=text/plain,text/html
header-layout=From|To,Cc|Bcc,Date,Subject

[filters]
subject,~^\[PATCH=awk -f /usr/share/aerc/filters/hldiff
text/plain=wrap -w 90 | colorize
text/html=w3m -I UTF-8 -T text/html -cols 90 | colorize

[compose]
editor=nvim
address-book-cmd=khard email --parsable %s

[hooks]
mail-sent=mbsync -Va && notmuch new
```

**~/.config/aerc/binds.conf**:
```ini
[messages]
j = :next<Enter>
k = :prev<Enter>
gi = :cf INBOX<Enter>
gs = :cf Sent<Enter>
ga = :cf Archive<Enter>
u = :pipe urlscan<Enter>
<C-n> = :switch-account -n<Enter>

[view]
ga = :pipe -mb git am -3<Enter>
gp = :term git push<Enter>
rt = :reply -Tthanks<Enter>
```

### NeoMutt設定サンプル

**~/.config/neomutt/neomuttrc**:
```muttrc
# 基本設定
set folder = ~/.mail
set spoolfile = +INBOX
set record = +Sent
set postponed = +Drafts
set trash = +Trash

# キャッシュ
set header_cache = ~/.cache/mutt/headers
set message_cachedir = ~/.cache/mutt/bodies

# 表示設定
set index_format='%Z %<[y?%<[m?%<[d?%[%H:%M ]&%[%a %d]>&%[%b %d]>&%[%m/%y ]> %-15.15L %s'
set sort = reverse-date
set sort_aux = last-date-received

# サイドバー
set sidebar_visible = yes
set sidebar_width = 30
set sidebar_format = '%D%?F? [%F]?%* %?N?%N/?%S'

# アカウント読み込み
source ~/.config/neomutt/accounts/gmail.muttrc

# マクロ読み込み
source ~/.config/neomutt/macros.muttrc

# カラー読み込み
source ~/.config/neomutt/colors/dracula.muttrc
```

**~/.config/neomutt/macros.muttrc**:
```muttrc
# URL抽出
macro index,pager \cl '<pipe-message>urlscan -d<enter>'

# アカウント切り替え
macro index i1 '<sync-mailbox><enter-command>source ~/.config/neomutt/accounts/gmail.muttrc<enter><change-folder>!<enter>'
macro index i2 '<sync-mailbox><enter-command>source ~/.config/neomutt/accounts/work.muttrc<enter><change-folder>!<enter>'

# クイックアーカイブ
macro index A ';<save-message>=Archive<enter><enter>'

# 全既読
macro index \Ca 'T~U<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>'

# フォルダ移動
macro index,pager gi '<change-folder>=INBOX<enter>'
macro index,pager gs '<change-folder>=Sent<enter>'
macro index,pager ga '<change-folder>=Archive<enter>'
```

**~/.config/neomutt/accounts/gmail.muttrc**:
```muttrc
set from = "you@gmail.com"
set realname = "Your Name"
set folder = ~/.mail/gmail
set spoolfile = +INBOX
set record = +[Gmail].Sent\ Mail
set postponed = +[Gmail].Drafts
set trash = +[Gmail].Trash

set smtp_url = "smtp://you@gmail.com@smtp.gmail.com:587/"
set smtp_pass = "`pass show gmail/app-password`"

# Gmail特有のフォルダマッピング
mailboxes =INBOX =[Gmail].Sent\ Mail =[Gmail].Drafts =[Gmail].Trash
```

---

## 選択ガイド

### aercを選ぶべき人
✅ すぐに使い始めたい（学習コスト低）
✅ モダンなツールが好き
✅ Git+emailワークフローが中心
✅ Notmuchを既に使用or導入予定
✅ 基本的なメール作業が中心
✅ シンプルな設定を好む

**推奨ユースケース**:
- OSS開発者（パッチレビュー）
- 個人メール管理
- 軽量なビジネスメール

### NeoMuttを選ぶべき人
✅ 複雑な自動化・ワークフローが必要
✅ メール処理を極限まで効率化したい
✅ 複数アカウント/ドメインを完全自動切り替え
✅ メーリングリストを大量購読
✅ メール優先度管理が重要
✅ 設定ファイルをハックするのが楽しい
✅ 既存のMutt設定資産がある

**推奨ユースケース**:
- ビジネスメール（複数アカウント）
- メーリングリスト管理者
- セキュリティ/プライバシー重視
- 高度な自動化が必要

### 実際の選択基準

| ユースケース | 推奨 | 理由 |
|-------------|------|------|
| Git+emailワークフロー | **aerc** | 埋め込みターミナル、テンプレート |
| 複数企業アカウント管理 | **NeoMutt** | send-hook、folder-hook |
| メーリングリスト大量購読 | **NeoMutt** | subjectrx、スコアリング |
| 個人メール（Gmail等） | **aerc** | セットアップ簡単 |
| Notmuch中心ワークフロー | **aerc** | ネイティブ統合 |
| 優先度自動管理 | **NeoMutt** | スコアリング |
| 初めてTUIメーラー | **aerc** | 学習曲線緩やか |
| Mutt経験者 | **NeoMutt** | 資産活用可能 |

### 併用戦略
両方の長所を活かす方法：

1. **notmuchをバックエンドとして共通化**
2. **mbsyncで同期、両方から同じMaildirにアクセス**
3. **用途に応じて使い分け**:
   - 日常操作: aerc（高速、モダンUI）
   - 複雑な検索/フィルター: NeoMutt（高度な機能）

---

## 参考リソース

### aerc
- **公式サイト**: https://aerc-mail.org/
- **マニュアル**:
  - https://man.archlinux.org/man/aerc-config.5.en
  - https://man.archlinux.org/man/aerc-binds.5.en
  - https://man.archlinux.org/man/aerc-templates.7.en
- **ガイド**:
  - https://drewdevault.com/2020/04/20/Configuring-aerc-for-git.html
  - https://wilw.dev/notes/aerc
- **Notmuch統合**: https://man.sr.ht/~rjarry/aerc/integrations/notmuch.md
- **dotfiles例**:
  - https://github.com/dcao/dotfiles/blob/master/extra/aerc/aerc.conf
  - https://codeberg.org/totoroot/dotfiles/src/branch/main/config/aerc/binds.conf

### NeoMutt
- **公式サイト**: https://neomutt.org/
- **ドキュメント**:
  - https://neomutt.org/guide/configuration.html
  - https://neomutt.org/guide/advancedusage.html
  - https://neomutt.org/guide/reference.html
- **日本語情報**:
  - https://wiki.archlinux.jp/index.php/Mutt
  - https://debimate.jp/2019/06/01/環境構築：terminalcli向けメーラーneomuttでgmailを送受信するた/
- **サンプル設定**: https://github.com/neomutt/samples
- **ブログ記事**:
  - https://gideonwolfe.com/posts/workflow/neomutt/intro/
  - https://www.jevy.org/articles/neomutt-lieer-notmuch/
- **dotfiles例**:
  - https://github.com/ceuk/mutt_dotfiles
  - https://github.com/kmARC/dotfiles

### 共通ツール
- **urlscan**: https://github.com/firecat53/urlscan
- **khard**: https://github.com/lucc/khard
- **notmuch**: https://notmuchmail.org/
- **mbsync**: https://isync.sourceforge.io/
- **msmtp**: https://marlam.de/msmtp/

### Arch Linuxインストール
```bash
# aerc
sudo pacman -S aerc

# NeoMutt
sudo pacman -S neomutt

# 共通ツール
sudo pacman -S urlscan khard notmuch isync msmtp w3m
```

---

**最終更新**: 2025-10-05
**作成者**: Claude Code調査レポート
