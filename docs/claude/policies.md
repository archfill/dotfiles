# Policies and Rules for Claude Code

このドキュメントはdotfiles管理における重要なポリシーとルールをまとめています。

## 🚨 CRITICAL: シェル環境設定の自動変更禁止ポリシー (2025年6月30日制定)

### 重要原則: make init でのシェル設定自動変更を完全禁止

**背景**: zshをメインシェルとして使用し、zsh設定はdotfilesでシンボリックリンク管理している環境では、セットアップスクリプトによる自動的なシェル設定変更は不要かつ有害である。

### 🚫 禁止事項 (絶対に実装してはならない)

1. **シェル設定ファイルへの自動書き込み**:
   - `~/.bashrc`、`~/.zshrc`、`~/.profile` への自動的な環境変数・PATH追加
   - `echo 'export PATH=...' >> ~/.zshrc` 形式の処理
   - シェル設定ファイルの自動変更全般

2. **環境変数の永続化処理**:
   - セットアップスクリプトによる永続的なPATH設定
   - 自動的なシェル統合設定の追加
   - ユーザーの同意なしでのシェル環境変更

### ✅ 推奨される実装方針

1. **dotfilesによるシェル管理**:
   - zsh設定は `.config/zsh/` でシンボリックリンク管理
   - 環境変数・PATHは dotfiles内の設定ファイルで定義
   - ユーザーが意図的に管理する構造を維持

2. **手動設定案内の提供**:
   - 必要なPATH設定内容をログメッセージで表示
   - 手動設定手順の明確な案内
   - コピー&ペースト可能な設定例の提示

### 📋 2025年6月30日実施済み修正内容

**修正対象スクリプト**:

1. **`bin/lib/volta_installer.sh`**: ※2025年12月にmiseへ移行のため削除
2. **Flutter installer**: FVM を Nix 管理へ移行したため削除済み
3. **`bin/apps/php-apt.sh`**: Composer PATH追加処理を削除（既に削除済み）

**修正後の動作**:

- セットアップスクリプト実行後もシェル設定ファイルは変更されない
- 必要なPATH設定は手動設定案内メッセージで提供
- ツールのインストール自体は正常に継続

### 🔍 今後の保守ルール

**新規スクリプト作成時**:

- シェル設定ファイルへの書き込み処理を含めてはならない
- 環境変数設定は一時的（現在セッションのみ）に留める
- 手動設定案内の提供を標準とする

**既存スクリプト修正時**:

- シェル設定変更処理が含まれていないか必ず確認
- 発見した場合は即座に手動設定案内に変更
- CLAUDE.mdに修正内容を記録

### 💡 設定例: 手動でのPATH設定方法

ユーザーが手動で設定すべきPATH（参考）:

```bash
# ~/.config/zsh/zshrc/paths.zsh などで管理
# Note: mise (Node.js管理) は自動的にPATHを管理するため設定不要

export PATH="$HOME/fvm/default/bin:$PATH"      # FVM Flutter
export PATH="$HOME/.pub-cache/bin:$PATH"       # Dart pub cache

export PATH="$HOME/.composer/vendor/bin:$PATH" # Composer global tools
```

### 🎯 この方針の利点

1. **設定の一元管理**: dotfilesによる統一的なシェル環境管理
2. **意図しない変更の防止**: ユーザーが把握していない設定変更を回避
3. **クリーンな環境**: セットアップ後もユーザーの環境設定が保持される
4. **保守性向上**: 設定の所在が明確で変更履歴が追跡可能

**CRITICAL**: この方針はdotfiles環境の基本設計思想であり、例外を認めてはならない。全ての開発者・保守担当者はこの原則を厳守すること。

---

## 🌐 Nix 採用と OSS 配布の方針 (2026 年 6 月 10 日制定)

### 基本原則

> **個人環境では Nix を全開で使う。OSS / 配布対象のリポジトリには Nix を必須化しない。**

dotfiles に Nix (home-manager) を導入した結果、強力な再現性とツール一元管理が手に入った。一方で、リポジトリ単位で Nix 必須にすると、コントリビュータが Nix インストールから始めねばならず、参加障壁が著しく上がる。両者を両立させる運用を本ドキュメントで明文化する。

### 関連用語

- **Nix / home-manager / flakes**: 宣言的パッケージ・環境管理。本 dotfiles で採用済み（`~/dotfiles/nix/`）。
- **mise**: Polyglot version manager + task runner。proto / asdf 系の後継的存在で、軽量・OSS 配布で広く許容される。
- **flake.nix + devShell + direnv**: Nix 派 OSS 開発者の標準的なローカル開発体験。プロジェクトに入ると `nix develop` で隔離された環境が起動する。

### プロジェクト分類とツール選定

| プロジェクト類型                       | 推奨ツール構成                                                                | flake.nix の扱い                                                                  |
| -------------------------------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| OSS / 配布想定                         | **mise.toml** + **husky / lefthook** + **npm/pnpm scripts** or **mise tasks** | リポジトリには **commit しない**（ローカル限定でなら使える、後述パターン C 参照） |
| private / 個人専用（小規模）           | mise.toml ベースが無難。flake.nix を併設してもよい                            | 任意                                                                              |
| Nix ネイティブ OSS (NixOS, Nixpkgs 等) | flake.nix を主軸                                                              | **commit してよい**                                                               |
| 純粋な個人実験リポジトリ               | flake.nix + devShell + direnv で Nix 全開                                     | commit してよい                                                                   |

### Nix 派 OSS 開発者の主流: パターン C（ローカル限定 flake.nix）

NixOS Discourse / Reddit r/NixOS でのコンセンサス: **「flake.nix は個人 gitignore、OSS リポジトリのコントリビュータには mise を案内する」** が最多。実装は以下:

#### 設定手順

1. **`~/.gitignore_global` に Nix ローカル設定を追加**

   ```
   flake.nix
   flake.lock
   .envrc
   .direnv/
   ```

   有効化:

   ```bash
   git config --global core.excludesfile ~/.gitignore_global
   ```

   これで、どのリポジトリに `flake.nix` を置いても自動的に commit 対象外になる。

2. **リポジトリ別ローカル除外（gitignore_global を使わない場合）**

   ```bash
   cd ~/git/<repo>
   printf '%s\n' 'flake.nix' 'flake.lock' '.envrc' >> .git/info/exclude
   ```

3. **ローカル flake.nix のテンプレート**

   ```nix
   {
     description = "Local dev shell (個人ローカル用、gitignore 対象)";
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     outputs = { self, nixpkgs }:
       let
         system = "aarch64-darwin";
         pkgs = nixpkgs.legacyPackages.${system};
       in {
         devShells.${system}.default = pkgs.mkShell {
           buildInputs = [ pkgs.mise pkgs.direnv ];
           shellHook = ''eval "$(mise activate bash)"'';
         };
       };
   }
   ```

4. **direnv で自動切替**

   ```bash
   # .envrc (gitignore 対象)
   use flake
   ```

   `cd <repo>/` で Nix devShell + mise activate が自動起動する。

### 例外と判断軸

- **「リポジトリに flake.nix を入れたい」と感じたとき** → 「このプロジェクトのコントリビュータに Nix を要求して問題ないか」を自問する。public OSS / 第三者貢献を期待する場合は NO。
- **「ハイブリッドで両方提供したい」** → mise.toml と flake.nix を両方 commit する選択肢もあるが、バージョン宣言が二重化するため DRY 違反になりやすい。よほどメリットがない限り避ける。
- **「全コントリビュータが Nix を入れる前提」が成立する小チーム** → flake.nix を commit してよい。事前合意必須。

### この方針の根拠

- 個人 dotfiles が Nix 全開でも、リポジトリ単位の選択は独立して決められる。
- Nix エコシステム公式 (Determinate Systems) も「グローバル最小限 + プロジェクト単位 devShell」を推奨しており、本方針はそれと整合する。
- yui (Python + TypeScript monorepo) を moon + proto から mise + husky に移行したのもこの方針に基づく決定（2026 年 6 月 10 日）。

### 参照

- グローバル CLAUDE.md (`~/.claude/CLAUDE.md`) の「プロジェクト環境構築の方針」セクションが本ドキュメントの要約。
- 詳細実装手順は本ファイル（このセクション）を参照する。

---

## Documentation Requirements

**CRITICAL**: Any modifications MUST include corresponding updates to README files.

### When to Update READMEs

- New commands added to Makefile
- New scripts or libraries created
- Configuration changes affecting user workflow
- Architecture modifications in shared library system
- New platform support or features

### Update Process

1. Modify functionality/add features
2. Test changes with `make test`
3. Update README.md (English) and README.ja.md (Japanese)
4. Verify both versions are consistent
5. Commit all changes together

---

## Critical Maintenance Rules

- **Always update READMEs** when making changes
- **Use shared libraries** instead of duplicating code
- **Test changes** with `make test` before committing
- **Follow naming conventions** and error handling patterns
- **Document architectural changes** in both README files
