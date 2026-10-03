# Mac mini をエージェント専用機として運用する

対象: `archfill-to-Mac-mini-M1`。**既存ユーザー `archfill` のまま運用し、別ユーザーは作成しない。**
Mac Studio / Linux の既存管理方式は変更しない。
この変更は設定と手順だけ。CLI 配備・darwin switch は自動実行しない。

## 管理方式

| 対象 | 更新方法 |
| --- | --- |
| macOS・サービス・基盤 | `archfill` が `make nix-rebuild` (必要時だけ管理者認証) |
| Claude Code / Codex / Pi / Devin と基本作業ツール | `archfill` が独立した `agent-runtime` を prepare → 明示承認して apply |
| コード・ビルド・プロジェクト依存 | 同じ `archfill` で作業。worktree / lockfile / 必要に応じて `nix develop` |
| 認証情報・CLI 設定 | 既存の設定を継続。必要な認証情報は 1Password から供給 |

目的は **CLI 更新とシステム設定反映の分離**。CLI の日常更新では sudo を使わない。
OS ユーザー間の権限分離ではなく、エージェントも `archfill` がアクセスできるファイル・認証を利用できる。
明示承認の引数や所有者チェックも、同じユーザーのエージェントに対するセキュリティ境界ではない。
パスワード不要の sudo 設定は追加しない。

`agent-runtime` は Nix の immutable closure。`/opt/agent-runtime/profile/bin` で提供する。
Home Manager は Mac mini だけ上記 4 CLI をインストールせず、代わりに独立 profile の PATH を設定する。
Antigravity 等それ以外のツールは従来どおり。基本作業ツールの一覧は
`nix/pkgs/agent-runtime/default.nix` に置く。

既存の Codex Desktop 用 1Password Environment / SSH agent / `codex-env` の運用は継続する。
1Password の保管・供給と token の権限は別なので、エージェントに必要な情報と権限だけを渡す。
秘密情報は repo や Nix derivation に埋め込まない。CLI 設定・hooks・Pi extensions も同じユーザー権限で
コードを実行できるため、信頼できないコードの隔離が必要なら VM / コンテナを別途使う。

## 状態の読み手と失敗時の扱い

- **候補 (`candidate`) / 更新を実施する人**
  - 伝播: prepare 成功時に候補を更新し、承認用の正確な store path を表示する。
  - 非同期: ビルド・起動確認を同期実行。起動確認は各 CLI 45 秒で打ち切る。並行配備は lock で拒否。
  - 劣化: ビルド・smoke 失敗時は現在の profile と既存候補を変更しない。root 登録の失敗時も profile は維持。
- **稼働 profile / 新しい CLI プロセス・shell・起動ジョブ**
  - 伝播: apply は `nix-env --set` で世代を作り profile を切り替える。新しいプロセスは新世代を読む。
  - 非同期: 実行中のプロセスは更新されない。タスクを止め、切替後に fresh process を起動する。
  - 劣化: 承認 path と候補の不一致、起動確認失敗は切替前に拒否。認証・実タスクの問題は旧世代へ切り戻す。
- **PATH / `archfill` の zsh・非対話 shell・起動ジョブ**
  - 伝播: Home Manager の `home.sessionPath` を `.zshenv` の `setup_nix_session` が読む。反映後に新しい shell を起動する。
  - 非同期: 古い shell や launchd の環境は自動更新しない。ジョブには PATH または CLI の絶対パスを明示する。
  - 劣化: 初回配備前は profile が存在しない。先に prepare / apply を完了し、その後に Home Manager の旧 CLI を外す。
- **旧世代・候補 / Nix garbage collector**
  - 伝播: build out-link / candidate の間接 GC root と profile の世代リンクが closure を保持する。
  - 非同期: 配備中の `pending` は finally で解放。異常終了で残った pending は次の prepare で再利用する。
  - 劣化: root / 世代を消すと GC 後に復旧できないことがある。旧世代を検証前に削除しない。
- **パッケージ定義 / 他ホスト・`make nix-update`**
  - 伝播: 既存 update スクリプトが共有定義を更新。Mac Studio / Linux は従来の Home Manager 反映で読む。
  - 非同期: 更新取得失敗時は差分を確認し、prepare へ進まない。prepare は flake.lock を更新しない。
  - 劣化: Mac mini の `make nix-update` は OS 更新用であり独立 profile は更新しない。別の apply が必要。

## 初回移行（既存の `archfill` で実施）

### 1. 配備ディレクトリを作る

初回のディレクトリ作成だけ sudo が必要。ユーザー作成・切り替え・認証情報の移行は不要。

```bash
sudo install -d -o archfill -g staff -m 0755 /opt/agent-runtime
```

`/opt` と親ディレクトリは root または `archfill` 所有で、group / other 書き込み不可にする。
symlink を使わない。配備コマンドは所有者・権限を検証し、root 実行を拒否する。
`archfill` の既存 admin membership は維持するが、配備コマンド自体は sudo を呼ばない。
macOS の ACL は配備コマンドでは検証しないので、`ls -lde /opt /opt/agent-runtime` で
他ユーザー向けの書き込み許可が追加されていないことを確認する。
同じ `archfill` のプロセスによる変更はこの権限設定では防げない。

### 2. CLI を先に配備する

既存 clone (`/Users/archfill/dotfiles`) で実行する。
配備スクリプト・Nix 定義の差分をレビューする。`sudo make` は使わない。

```bash
cd ~/dotfiles
make agent-test
make agent-prepare
# 候補のバージョン・変更内容を確認し、既存の CLI セッションを終了する。
make agent-apply STORE_PATH=/nix/store/<prepare が表示した正確な hash>-agent-runtime
make agent-status
```

未コミットの新規 Nix ファイルがある場合、通常の Git flake は未追跡ファイルを含めない。
次の `git add -N` で認識させる（コミットも内容のステージングも行わない）。
`path:./nix` の評価だけでは、この通常経路での読み込み失敗を検出できない。

```bash
git add -N -- nix/modules/agent-cli.nix nix/pkgs/agent-runtime/default.nix
nix eval --raw './nix#darwinConfigurations.archfill-to-Mac-mini-M1.system.drvPath'
```

初回は候補の反映後に Home Manager 側の旧 CLI を外し、独立 profile の PATH を設定する。
既存 CLI から操作していると途中で executable が切り替わるので、人のターミナルから移行する。

```bash
make nix-diff
make nix-rebuild
```

### 3. 同じユーザーの新しい shell で確認する

Home Manager が `/opt/agent-runtime/profile/bin` を session PATH に追加するため、
新しく開いた zsh で確認する。別ユーザーへのログインや `~/.zprofile` の手動追加は不要。

```bash
whoami                         # archfill
command -v claude codex pi devin
claude --version
codex --version
pi --version
```

CLI が `/opt/agent-runtime/profile/bin` から解決されることを確認する。
別の手動インストールが PATH の先頭にある場合は、二重管理を解消する。
非 zsh の shell や launchd など、Home Manager の session 設定を読まない起動経路では
PATH を明示し、CLI executable は `/opt/agent-runtime/profile/bin/claude` などの絶対パスで指定する。
長時間のセッションでは混在を避けるため、タスク開始時に
`readlink -f /opt/agent-runtime/profile`（runtime の coreutils）で得た store path を PATH に入れ、
そのタスクの全プロセスを同じ世代で起動する。

同じ HOME を使うため、既存の CLI 設定・ログイン情報・1Password 連携はそのまま利用する。
`codex-env` の参照と mounted Environment は [macOS setup](macos-setup.md) の既存運用を継続する。
Devin の `auto_update: false` 設定も既存の Home Manager 配置を使う。
認証、Git checkout、ビルド・テスト、必要な CLI hooks を代表的な repo で検証する。
`--version` の smoke test は認証や実際のエージェント動作まで保証しない。

## 日常の更新（`archfill`、sudo 不要）

1. 既存 clone で定義を更新して差分をレビューする。

   ```bash
   make claude-update codex-update pi-update devin-update
   git diff -- nix/pkgs
   # 基本作業ツールも更新するときだけ、依存更新をレビューする:
   # nix flake update --flake path:./nix
   ```

2. `make agent-prepare`。新候補をビルド・4 CLI の `--version` を確認。稼働 profile はそのまま。
3. 新規タスク受付を止め、全エージェント・子プロセス・常駐 daemon を終了する。
   現状は個別 CLI 実行のため、配備コマンドは稼働タスクの検出や停止を自動化しない。
4. 表示された正確な store path を指定して `make agent-apply STORE_PATH=...`。
5. 新しいプロセスで代表タスクを確認して受付を再開。`--version` だけで本番再開しない。

候補の同時作成・切替は排他 lock で拒否する。prepare 後に別候補が作られた場合、
古い path の承認では apply できない。同じ配備済み path を再適用してもツールの内容は変わらない。
ネットワークや Nix daemon の利用が sandbox で拒否される問題は、sudo 不要化とは別に許可が必要。

## 切り戻しと GC

```bash
make agent-status
# 全タスクを停止し、list-generations で確認した世代番号を指定する。
make agent-rollback GENERATION=1
# CLI と daemon を再起動し、代表タスクを確認する。
```

rollback は指定世代の smoke test 後に `nix-env --switch-generation` を実行する。
存在しない世代・壊れた closure は拒否する。CLI が書いたユーザー設定・DB schema は巻き戻らないので、
重要な状態は更新前に別途バックアップする。

`/opt/agent-runtime/profile-*-link` は旧世代の GC root として保持する。
`make nix-clean` はこの専用 profile の世代削除には使わない。容量整理は安定稼働を確認した後、
専用 profile に対して保持世代を確認して実施する。候補 root も不用意に削除しない。

## 運用上の残る判断

自動更新・launchd のエージェント自動起動・サービスの停止制御は導入しない。
CLI ごとに起動形態が異なるため、無人の再起動運用を追加するときは実際のジョブ構成に合わせて設計する。
FileVault 有効時の停電後復帰、SSH / Tailscale、ログの保存と機密情報のマスキング、
ディスク監視・バックアップも実機運用開始前に確認する。

参考: [Nix profiles](https://nix.dev/manual/nix/stable/package-management/profiles)、
[nix-env --set](https://nix.dev/manual/nix/stable/command-ref/nix-env/set)。
