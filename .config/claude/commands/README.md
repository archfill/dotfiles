# Claude Code カスタムスラッシュコマンド

全プロジェクト共通で利用するカスタムコマンドを管理します。

## 配置構成

```
~/.claude/commands/ → dotfiles/.config/claude/commands/ (symlink)
```

## ディレクトリ構造

```
commands/
├── review/     # コードレビュー系
├── docs/       # ドキュメント生成系
└── dev/        # 開発ワークフロー系
```

## コマンドの作成方法

1. 適切なディレクトリに `.md` ファイルを作成
2. ファイル名がコマンド名になる（例: `security.md` → `/security`）

### 基本テンプレート

```markdown
---
description: コマンドの説明（/help で表示）
allowed-tools: Bash(git status:*, git diff:*)
argument-hint: [引数の説明]
---

プロンプト内容をここに記述。

$ARGUMENTS で全引数、$1, $2 で位置引数を参照可能。
```

## 参考

- [Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
