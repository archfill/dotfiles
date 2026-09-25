# macOS Setup Guide

新しい Mac (Apple Silicon) に dotfiles を適用するまでの手順。
macOS 環境は nix-darwin + home-manager + Homebrew モジュールで宣言的に管理しており、
**手動で入れるのは Nix / Homebrew で入れられないものだけ**にしている。

```
事前準備 (手動)          → make doctor → make init → セットアップ後の手動設定
Homebrew / 1Password / Nix   チェックのみ    初回 switch    権限許可など
```

Rosetta 2 は Apple が段階的に廃止するため前提にしない (Intel 専用 cask は採用しない)。

## 1. 事前準備 (手動)

順番どおりに行う。

### 1-1. Homebrew

nix-darwin の Homebrew モジュールは brew 本体をインストールしないため事前に必要。
Xcode Command Line Tools もこのインストーラーが一緒に入れる。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1-2. ターミナルに「アプリケーション管理」を許可

システム設定 → プライバシーとセキュリティ → **アプリケーション管理** で、使うターミナルを ON にし、ターミナルを再起動する。
未許可だと cask の upgrade / `--adopt` / uninstall が `Operation not permitted` で失敗する。

### 1-3. 1Password (SSH 鍵)

dotfiles の clone に SSH 鍵が必要なので、ここで入れる。
cask として宣言済みなので **brew 経由で入れる** (手動 DL 版だと初回 switch で衝突する)。

```bash
brew install --cask 1password
```

1. サインインする
2. 設定 → 開発者 → 「**SSH エージェントを使用**」と「**1Password CLI と連携**」を ON
3. clone に使うターミナルで 1Password の SSH agent を指定し、認証できることを確認

   ```bash
   export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
   ssh -T git@github.com
   ```

   `~/.ssh/config` は dotfiles が配置するので**手で作らない** (既にあると switch が止まる)。

### 1-4. Nix (Determinate Nix)

`nix/modules/darwin-system.nix` は Determinate Nix 前提 (`nix.enable = false`)。

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

インストール後はターミナルを開き直す。

### (任意) セットアップ中に使うアプリ

Chrome / Tailscale / Claude は cask として宣言済みで `make init` で入るが、
先に使いたい場合は **brew 経由で**入れておく。

```bash
brew install --cask google-chrome tailscale-app claude
```

公式サイトから手動で入れてしまった場合は、初回 switch 前に brew 管理へ取り込む
(cask のバージョンと一致している必要があるため早めに行う)。

```bash
brew install --cask --adopt 1password google-chrome tailscale-app claude
```

## 2. dotfiles を clone

パスは `~/dotfiles` 固定 (symlink や Hammerspoon の設定パスが前提にしている)。

```bash
git clone git@github.com:archfill/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## 3. ホスト定義を追加 (初めての Mac の場合)

`darwinConfigurations` の attr 名は **`LocalHostName`** と一致させる。

```bash
scutil --get LocalHostName
# 変更する場合:
# sudo scutil --set LocalHostName <new-name>
```

既存ホストをコピーして、`nix/flake.nix` の `darwinConfigurations` に追加する。

```bash
cp -r nix/hosts/archfill-to-Mac-Studio-M4-Max nix/hosts/<host>
```

```nix
"<host>" = mkDarwinHost {
  system = "aarch64-darwin";
  hostModule = ./hosts/<host>/darwin.nix;
  homeModule = ./hosts/<host>/home.nix;
  username = "<macOS のユーザー名>";   # whoami の値
};
```

- ユーザー定義 (`users.users` / `system.primaryUser`) は `mkDarwinHost` が username から生成する
- 全ホスト共通の設定は `nix/modules/darwin-system.nix` (system) と `nix/modules/home-darwin.nix` (home-manager)
- ホスト固有の cask などは `nix/hosts/<host>/darwin.nix` に書く (リストは共通設定とマージされる)

新規ファイルは flake から見えるように `git add` しておく (未追跡ファイルは flake に含まれない)。

## 4. チェックと適用

```bash
make doctor   # 前提条件のチェックのみ (何もインストールしない)
make init     # doctor → nix-darwin 初回 switch → Git 個人設定
```

`make init` の流れ:

1. `make doctor` 相当のチェック。❌ があればここで停止
2. `darwin-rebuild` が無ければ `sudo nix run nix-darwin/master#darwin-rebuild -- switch` で初回 bootstrap、あれば `darwin-rebuild switch`
3. `bin/config.sh`: `config/personal.conf` が無ければ Git の user.name / user.email / ghq.root を対話で設定

以降の日常運用は `make nix-rebuild` (差分確認は `make nix-diff`)。

## 5. セットアップ後の手動設定

宣言できない / デバイスごとに必要なもの:

- **権限の許可** (システム設定 → プライバシーとセキュリティ)
  - Hammerspoon / Rectangle / Alfred / BetterTouchTool: アクセシビリティ
  - Chrome リモート デスクトップ ホスト: 画面収録・アクセシビリティ
- **日本語入力**: macOS 標準の日本語入力 (ローマ字入力) が入力ソースにあることを確認。
  切り替えは英数 / かなキー (⌃Space による入力ソース切替は無効化している)
- **SSH の非公開の接続先**: 1Password のセキュアノート「SSH config (private)」の内容を `~/.ssh/config.d/private` に保存 (自宅サーバーなど。公開リポジトリのため dotfiles には入れない)。
  鍵は 1Password の SSH agent から使い、ホストごとに鍵を指定する場合は `IdentityFile` に**公開鍵** (`~/.ssh/<name>.pub`) を書く。秘密鍵のファイルはディスクに置かない
- **Chrome リモート デスクトップ**: `remotedesktop.google.com/access` でこの Mac のリモートアクセスを有効化 (PIN 設定)
- **署名の無いアプリの初回起動**: zmk-battery-center (Mac Studio) は初回起動時にブロックされるので、システム設定 → プライバシーとセキュリティ で「このまま開く」を押す
- **1Password Environments**: `codex-env` が使う `.env` のマウントを設定 (デバイスごと)
- **Mac App Store アプリ**: 宣言しない方針 (`homebrew.masApps` は cleanup で宣言外の MAS アプリを消すため。`darwin-system.nix` のコメント参照)。必要なものは手動でインストール
- **既定のブラウザ**: Chrome の初回起動時に既定のブラウザにする (macOS の確認ダイアログが必須のため宣言できない)
- **既定のメール (mailto:)**: Chrome で Gmail を開き、アドレスバーのプロトコルハンドラから Gmail に mailto を許可 → メール.app の設定 → 一般 → デフォルトのメールソフトで Chrome を選ぶ
- (任意) **優先する言語**: システム設定 → 一般 → 言語と地域 で English を追加
- **Rectangle を再起動**: ショートカット設定 (`darwin-system.nix` で宣言) は起動時に読み込まれる
- **一度ログアウト**: アイコンのスタイル・操作スペースなど一部の `system.defaults` はログアウトしないと反映されない
- 新しいシェルを開いて zsh / nvim などが Nix 版になっていることを確認

## トラブルシューティング

### `Unexpected files in /etc, aborting activation`

Nix インストーラー等が作った `/etc/zshrc` / `/etc/bashrc` と nix-darwin が衝突している。
表示されたメッセージどおり退避してから再実行する。

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
```

### `Existing file ... is in the way` (home-manager)

home-manager が管理するパスに既存ファイルがある。中身を確認して退避してから再実行する。

### `It seems there is already an App at ...`

手動で入れたアプリと宣言済み cask が衝突している。既存の Mac で cask を新しく宣言したときにも起きる。
switch の前に brew 管理へ取り込む:

```bash
# アプリのバージョンが cask と一致している場合 (brew info --cask <name> で確認)
brew install --cask --adopt <name>
# 一致していない場合は上書きで入れ直す (設定・データは ~/Library に残る)
brew install --cask --force <name>
```

pkg 形式の cask (tailscale-app / google-drive など) は衝突しないのでそのまま入る。
対象アプリは先に終了しておく。Tailscale 経由の SSH で作業すると再インストール時に接続が切れるので注意。

### pkg 形式の cask の uninstall でパスワードを求められて止まる

宣言から外した cask は `cleanup = "uninstall"` で自動削除されるが、ドライバや入力メソッドを含む
pkg 形式のもの (Karabiner-Elements など) は管理者パスワードが必要になることがある。
宣言から外したら、次の switch の前に手動で `brew uninstall --cask <name>` しておく。

### `untrusted tap` / tap trust で activation が止まる

Homebrew 6.0 以降は非公式 tap を trust しないと読み込めない。
`darwin-system.nix` の `taps` に `{ name = "<tap>"; trusted = true; }` で宣言する。

### `chgrp: ... Operation not permitted`

ターミナルに「アプリケーション管理」の権限が無い (1-2 参照)。許可後はターミナルの再起動が必要。

### `Cask '<name>' has been disabled`

Homebrew 側で cask が無効化された (Gatekeeper 非対応など)。
`darwin-system.nix` の casks から外すか、nixpkgs 版に置き換える。
