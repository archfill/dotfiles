---
description: git-committerエージェントで変更を分析しコミット
allowed-tools: Task
argument-hint: [--en|--ja]
---

git-committer エージェントを使用して、変更を分析し適切にコミットしてください。

## 言語設定

- 引数 `$ARGUMENTS` を確認:
  - `--en` が含まれる場合 → 英語でコミットメッセージ作成を指示
  - `--ja` または指定なし → 日本語でコミットメッセージ作成を指示

## 実行方法

Task tool を使用して git-committer エージェントを呼び出してください:

```
Task tool:
  subagent_type: "git-committer"
  prompt: |
    現在のリポジトリの変更を分析し、適切にコミットしてください。

    言語: [日本語/英語 - 上記設定に従う]

    手順:
    1. git status, git diff, git diff --cached で変更を確認
    2. 変更を論理的にグループ分け
    3. 各グループに適切なConventional Commitsメッセージを提案
    4. ユーザー確認後、コミットを実行
```

エージェントの実行結果をユーザーに報告してください。
