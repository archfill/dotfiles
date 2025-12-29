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
2. **`bin/apps/52-flutter.sh`**: Flutter/Dart PATHの自動追加を削除
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
