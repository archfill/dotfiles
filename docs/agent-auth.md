# ハーネス起動時の 1Password Service Account 認証

既存の macOS ユーザー `archfill` のまま、ハーネス起動時だけ必要な認証情報を供給する。
Service Account token は **login Keychain** に保管し、`.zshenv` / plist / Nix store / repo には書かない。
ログイン時の `launchctl setenv` は追加しない。

```text
macOS ログイン → login Keychain のロック解除
agent-auth run -- pi
  → Keychain から Service Account token を取得
  → op run が env.refs の参照を解決
  → bootstrap token を除去
  → 必要な秘密情報だけを受け取った Pi を起動
```

この機能は実装と手順のみ。実際の token 登録・Keychain アクセス・認証・Nix の反映は自動実行しない。
Mac mini の Home Manager は `agent-auth` と参照ファイルの example だけを配置する。
他ホストでも repo 内の wrapper は手動実行できるが、自動配置は Mac mini のみ。

## 1. Service Account を用意する

1Password にエージェント用の vault（例: `Agents`）を用意し、必要な secrets を置く。
Service Account にはこの vault の read 権限だけを付ける。不要な write / share / vault 作成権限は付けない。

**Service Account には built-in Personal / Private / Employee / default Shared vault のアクセスを許可できない。**
既存の `.config/codex/env.refs` は `op://Personal/...` なので、そのままこの方式には流用しない。
必要な項目だけを専用 vault に用意する。Service Account のアクセス・権限は後から変更できないため、
変更が必要なら新しい account / token を用意して切り替える。

CLI は `op` 2.18.0 以上が必要。Homebrew の `1password-cli` cask は既存の宣言で導入される。
この実装は標準の `op run` と secret references を使用し、Environments beta の CLI 機能には依存しない。

## 2. token を login Keychain に登録する（人が一度だけ実施）

Keychain Access を開き、**login** Keychain に新しい password item を作成する。

| 項目 | 値 |
| --- | --- |
| Keychain item name / service | `com.archfill.agent-auth.service-account` |
| Account | `archfill`（現在の macOS の短いアカウント名） |
| Password | Service Account token |

実際の token をチャット・シェル履歴・設定ファイルへ貼らない。
GUI で登録した後、item の Access Control で必要に応じて `/usr/bin/security` の読み取りを許可する。
「すべてのアプリケーションにアクセスを許可」や `security -A` は使わない。

ターミナルで登録する場合は、macOS `security` の対話入力を使える。
**default Keychain が login であることを Keychain Access で確認した上で**、次を実行する。
`-w` は必ず最後に置き、token を引数に付けない。更新時も同じ手順で上書きできる。

```bash
/usr/bin/security add-generic-password \
  -a "$(id -un)" \
  -s com.archfill.agent-auth.service-account \
  -T /usr/bin/security \
  -U -w
```

読み取り先は現在ユーザーの `~/Library/Keychains/login.keychain-db` に固定する。
ログインで Keychain が解除されない場合や独立したパスワードを設定している場合は、手動で解除する。
この wrapper は Keychain をパスワードで自動解除しない。初回やアクセス設定によっては GUI 承認が必要。
「毎回承認不要」を実現するには実機の Keychain Access Control を確認する必要がある。

## 3. ハーネスに渡す参照を設定する

Home Manager 反映後:

```bash
mkdir -p ~/.config/agent-auth
cp ~/.config/agent-auth/env.refs.example ~/.config/agent-auth/env.refs
```

反映前なら repo の `.config/agent-auth/env.refs.example` をコピーしてもよい。
`env.refs` には必要な `op://` 参照だけを設定する。実際の値は 1Password に置く。

```dotenv
GITHUB_PAT=op://Agents/GitHub Codex MCP/token
YUI_MCP_TOKEN=op://Agents/YUI MCP/token
```

API key を使うハーネスなら `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` なども追加できる。
ただし、Claude Code / Codex の既存 subscription login を使うなら API key を追加する必要はない。
認証方式・課金方式を意図せず変えないよう、必要な項目だけを有効にする。

平文 credentials、`OP_*`、PATH / HOME / interpreter 設定、重複した変数、参照内の変数展開・引用符は拒否する。
各行は `NAME=op://vault/item/field` の単純な形式で書く。vault / item 名にスペースは使用できる。
デフォルトの example はコメントだけなので、設定前の run は明確なエラーで終了する。

## 4. 確認して起動する

```bash
agent-auth check
agent-auth run -- pi
agent-auth run -- codex
agent-auth run -- claude
# ハーネス・プロジェクト別の参照ファイルを選ぶ場合:
agent-auth run --env-file ~/.config/agent-auth/project.refs -- pi
```

Home Manager の反映前は `~/dotfiles/.local/bin/agent-auth` を直接実行できる。
Python 3 と起動する CLI が PATH に必要。`op` はプロジェクトの PATH を信用せず、
Homebrew の `/opt/homebrew/bin/op` または `/usr/local/bin/op` を使用する。sudo は使わない。
`check` は Keychain と `op whoami` の成功だけを確認し、token・アカウント情報・CLI の生のエラーは表示しない。
各 secret にアクセスできるかは `run` で確認する。参照解決に失敗すると op がハーネスの起動前に終了する。

通常の `pi` / `codex` / `claude` コマンドを自動で置換しない。
**注入が必要なセッションは `agent-auth run -- ...` から起動する。**
launchd 等でハーネスを起動する際も、この wrapper を使い、Python / CLI が見える PATH を指定する。
現在の実装では自動起動ジョブは追加しない。

既存の Codex Desktop 用 `codex-env` とその launchd job、mounted Environment、SSH agent は変更しない。
Desktop 用の環境投入と、この CLI ハーネス用の供給は別経路。
Service Account token がハーネスに渡らないため、子プロセスで通常の `op` を実行しても Service Account 認証は
引き継がれない。追加の secrets は必要な参照ファイルを選んで、新しい wrapper セッションで供給する。

## 状態の読み手・失敗時の扱い

- **login Keychain / `agent-auth`**
  - 伝播: 起動ごとに固定 service・現在の OS account・login Keychain から再取得。token の常駐 cache は作らない。
  - 非同期: security の取得は最大 30 秒。未登録・ロック・拒否・timeout は static error で終了し、op / ハーネスを起動しない。
  - 劣化: desktop authentication や平文ファイルへの fallback はしない。token 更新後の次の起動で再取得する。
- **参照ファイル / `agent-auth` と `op run`**
  - 伝播: wrapper が起動ごとに読み、検証済みの参照を op の環境へ設定する。op に参照ファイルを再読込させない。
  - 非同期: 空・不正・予約変数は Keychain 取得前に拒否。別セッションはそれぞれ独立して参照を解決する。
  - 劣化: Personal vault、権限不足、期限切れ token、ネットワーク障害は op が失敗し、ハーネスを起動しない。
- **Service Account token / `op` と bootstrap の `env` プロセス**
  - 伝播: wrapper は `os.execve` で op に token を渡す。op の子の `/usr/bin/env -u OP_SERVICE_ACCOUNT_TOKEN` が除去する。
  - 非同期: op とハーネスは同じ foreground process tree。通常の終了 code・割り込みは op に委ねる。token の自前ログは作らない。
  - 劣化: 親の `OP_*` と無関係な ambient `op://` 参照は除去して別認証の混入を防ぐ。check の stdout / stderr は公開しない。
- **解決済み secrets / ハーネスとその子プロセス**
  - 伝播: 指定した参照の解決結果を環境変数で渡す。bootstrap token は渡さない。op の標準 output masking は維持する。
  - 非同期: 実行中の secrets は自動更新しない。rotation 後はセッションを再起動する。
  - 劣化: 親 shell・launchctl は変更しない。ただし既に親が持っていた通常の環境変数は引き継ぐ。

これは同じ OS ユーザー内での供給範囲の整理であり、ユーザー権限のセキュリティ境界ではない。
`/usr/bin/security` に読み取りを許可すれば、同じユーザーの他プロセスもそれを起動できる。
注入した secrets はハーネスの子プロセスから使える。op の masking も、ファイル出力・別表現への変換まで
防ぐものではない。Service Account の vault と credentials 自体の権限を限定する。

参考: [Service Account CLI](https://www.1password.dev/service-accounts/use-with-1password-cli)、
[op run](https://www.1password.dev/cli/reference/commands/run)、
[Service Account limitations](https://www.1password.dev/service-accounts/get-started)。
