# Dotfiles保守・メンテナンスガイド

このドキュメントでは、dotfilesリポジトリの保守・メンテナンス手順について説明します。

## 📋 目次

1. [概要](#概要)
2. [定期メンテナンス](#定期メンテナンス)
3. [設定変更・削除の手順](#設定変更削除の手順)
4. [シンボリックリンク管理](#シンボリックリンク管理)
5. [アーカイブ管理](#アーカイブ管理)
6. [トラブルシューティング](#トラブルシューティング)
7. [ベストプラクティス](#ベストプラクティス)

## 概要

dotfilesの運用において、設定の変更や削除は慎重に行う必要があります。このガイドでは安全で追跡可能な方法を提供します。

### 🛠️ 利用可能なツール

| ツール | 用途 | コマンド例 |
|--------|------|------------|
| `cleanup-symlinks.sh` | 壊れたシンボリックリンクの清理 | `make cleanup-symlinks` |
| `verify-links.sh` | リンク状態の確認 | `make verify-links` |
| `archive-config.sh` | 設定のアーカイブ化 | `make archive-config CONFIG=name` |

## 定期メンテナンス

### 🔄 推奨メンテナンススケジュール

| 頻度 | 作業内容 | コマンド |
|------|----------|----------|
| 週1回 | リンク状態確認 | `make verify-links` |
| 月1回 | 壊れたリンク清理 | `make cleanup-symlinks-dry` → `make cleanup-symlinks` |
| 四半期 | 全体状況確認 | `make maintenance-status` |

### 📊 状態確認コマンド

```bash
# 包括的なメンテナンス状況
make maintenance-status

# シンボリックリンクの詳細確認
make verify-links

# 壊れたリンクのみ確認
make verify-links-broken

# dotfiles関連リンクのみ確認
make verify-links-dotfiles
```

## 設定変更・削除の手順

### 🗂️ 段階的削除ワークフロー

設定を安全に削除・変更するための推奨手順：

#### 1. 事前準備

```bash
# 現在の状況確認
make maintenance-status

# 対象設定のリンク状況確認
make verify-links-dotfiles
```

#### 2. アーカイブ作成

```bash
# アーカイブ操作の事前確認
make archive-config-dry CONFIG=設定名 REASON="変更理由"

# 実際のアーカイブ作成
make archive-config CONFIG=設定名 REASON="変更理由"
```

例：
```bash
make archive-config CONFIG=yabai-skhd REASON="Aerospaceに移行のため"
```

#### 3. 設定変更・削除実行

- ファイルの編集・削除
- シンボリックリンクの更新
- 関連スクリプトの修正

#### 4. テスト期間

```bash
# 1-2週間のテスト期間中、定期的に確認
make verify-links-broken
```

#### 5. 清理作業

```bash
# 壊れたリンクの確認
make cleanup-symlinks-dry

# 実際の清理実行
make cleanup-symlinks
```

#### 6. 最終確認とコミット

```bash
# 最終状況確認
make maintenance-status

# 変更をコミット
git add -A
git commit -m "remove(設定名): 設定削除とクリーンアップ

- アーカイブブランチ: archive/設定名-YYYYMMDD
- 削除理由: 変更理由
- 壊れたシンボリックリンクを清理

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## シンボリックリンク管理

### 🔗 リンク状態の確認

```bash
# 全体的な統計情報
make verify-links

# JSON形式で詳細出力
./bin/verify-links.sh --format json

# CSV形式で出力（スプレッドシート処理用）
./bin/verify-links.sh --format csv
```

### 🧹 壊れたリンクの清理

```bash
# 安全確認（削除対象の表示のみ）
make cleanup-symlinks-dry

# 実際の削除実行
make cleanup-symlinks

# 特定ディレクトリのみ対象
./bin/cleanup-symlinks.sh --target ~/.config
```

### ⚠️ 保護されたパス

以下のパスは自動的に保護され、削除対象から除外されます：

- `~/.git`
- `~/.ssh`
- `~/.gnupg`
- `~/Library`
- `~/Applications`

## アーカイブ管理

### 📦 アーカイブの作成

```bash
# 基本的なアーカイブ作成
make archive-config CONFIG=設定名 REASON="理由"

# ローカルバックアップも作成
./bin/archive-config.sh --backup 設定名 "理由"

# 事前確認（dry run）
./bin/archive-config.sh --dry-run 設定名 "理由"
```

### 🌿 アーカイブブランチの命名規則

```
archive/設定名-YYYYMMDD
```

例：
- `archive/yabai-skhd-20241224`
- `archive/nvim-old-20241224`

### 📁 アーカイブの復元

```bash
# アーカイブブランチを確認
git branch -a | grep archive/

# 特定のアーカイブをチェックアウト
git checkout archive/設定名-YYYYMMDD

# ファイルを現在のブランチにコピー
# （具体的な手順は各設定の移行記録を参照）

# 元のブランチに戻る
git checkout main
```

## トラブルシューティング

### 🚨 よくある問題と解決法

#### 1. スクリプトが実行できない

```bash
# 実行権限を確認・付与
ls -la bin/*.sh
chmod +x bin/*.sh
```

#### 2. 壊れたリンクが大量にある

```bash
# まず概要を確認
make verify-links

# 段階的に削除（特定ディレクトリから）
./bin/cleanup-symlinks.sh --target ~/.config --dry-run
./bin/cleanup-symlinks.sh --target ~/.config
```

#### 3. アーカイブブランチ作成に失敗

```bash
# 未コミットの変更を確認
git status

# 必要に応じて変更をコミット
git add -A
git commit -m "WIP: アーカイブ前の一時コミット"

# 再度アーカイブ作成
make archive-config CONFIG=設定名 REASON="理由"
```

#### 4. リンク確認スクリプトがエラー

```bash
# jqコマンドがインストールされているか確認
command -v jq || echo "jq not found"

# macOSの場合
brew install jq

# その他のシステム
# パッケージマネージャーでjqをインストール
```

### 🔧 デバッグモード

```bash
# スクリプトをデバッグモードで実行
bash -x ./bin/cleanup-symlinks.sh --dry-run

# より詳細なログ
DEBUG=1 ./bin/verify-links.sh
```

## ベストプラクティス

### ✅ 推奨事項

1. **事前確認の徹底**
   - 削除前には必ず `--dry-run` オプションで確認
   - アーカイブ作成を習慣化

2. **段階的変更**
   - 一度に大量の設定を変更しない
   - テスト期間を設ける

3. **ドキュメント化**
   - 変更理由を明確に記録
   - 移行記録を作成・更新

4. **定期メンテナンス**
   - 週1回のリンク状態確認
   - 月1回の壊れたリンク清理

5. **バックアップ戦略**
   - 重要な変更前にはローカルバックアップ作成
   - リモートリポジトリへのプッシュ

### ⚠️ 避けるべき行為

1. **直接削除**
   - アーカイブなしでの設定削除
   - 手動でのシンボリックリンク削除

2. **テストなし変更**
   - dry runなしでの一括削除
   - 本番環境での直接変更

3. **ドキュメント不備**
   - 変更理由の記録忘れ
   - 移行手順の未文書化

### 📝 コミットメッセージテンプレート

```
<type>(<scope>): <description>

<body>

<footer>
```

例：
```
remove(yabai): Aerospaceに移行のため設定を削除

- アーカイブブランチ: archive/yabai-skhd-20241224
- 移行先: Aerospace window manager
- 壊れたシンボリックリンクを清理

BREAKING CHANGE: yabai/skhd設定が削除されました

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 📚 関連ドキュメント

- [移行記録一覧](migration/)
- [CLAUDE.md](../CLAUDE.md) - プロジェクト概要
- [Makefile](../Makefile) - 利用可能なコマンド一覧

## 🆘 サポート

質問や問題がある場合：

1. このドキュメントの確認
2. `make help` でコマンド一覧を確認
3. GitHubのIssueで報告

---

最終更新: 2024-12-24