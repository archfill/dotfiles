---
description: ステージ済みの変更をConventional Commits形式でコミット
allowed-tools: Bash(git status:*, git diff:*, git log:*, git commit:*, git add:*)
argument-hint: [--en|--ja]
---

ステージ済みの変更をConventional Commits形式でコミットしてください。

## 言語設定

- **デフォルト: 日本語**
- 引数 `$ARGUMENTS` を確認:
  - `--en` が含まれる場合 → 英語でメッセージ作成
  - `--ja` または指定なし → 日本語でメッセージ作成

## 手順

1. `git status` でステージ済みの変更を確認
2. `git diff --cached` でステージ済みの差分を確認
3. `git log --oneline -10` で直近のコミット履歴を確認（スタイル参考）
4. 変更内容を分析し、適切なConventional Commits形式のメッセージを生成
5. ユーザーに確認後、コミットを実行

## Conventional Commits形式

```
<type>(<scope>): <subject>

<body>
```

### Type
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマット等）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツールの変更
- `ci`: CI設定の変更

### 言語別の書き方

**日本語の場合:**
```
feat(nvim): プラグインの遅延読み込みを追加
```
- subjectは体言止め（「〜を追加」「〜を修正」）

**英語の場合:**
```
feat(nvim): add lazy loading for plugins
```
- subjectは命令形・小文字開始（add, fix, update）

### 注意事項

- scopeは変更対象のモジュール/コンポーネント名（省略可）
- bodyには変更の理由や詳細を記述（省略可）
- Co-Authored-ByとGenerated with行は**絶対に追加しない**
