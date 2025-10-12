# aicommit2 Configuration

aicommit2はAIを活用してGitコミットメッセージを自動生成するツールです。

## 📦 インストール

toolboxサブモジュールを使用：

```bash
# dotfilesリポジトリから
make toolbox-ai

# または個別に
cd toolbox
make ai
```

## ⚙️ 設定

### 自動設定

`make links` 実行時に自動的に設定ファイルがリンクされます：

```bash
~/.dotfiles/.config/aicommit2/config → ~/.aicommit2
```

### 手動設定

```bash
ln -sf ~/.dotfiles/.config/aicommit2/config ~/.aicommit2
```

## 🤖 使用可能なAIプロバイダー

### Ollama（推奨・ローカル実行）

完全無料、プライバシー保護、API料金なし。

**セットアップ:**
```bash
# Ollama起動
ollama serve

# モデルダウンロード
ollama pull llama3.2          # 軽量・高速（推奨）
ollama pull llama3.1:8b       # 高性能
ollama pull codellama         # コード特化
ollama pull elyza:jp8b        # 日本語特化
```

**設定（config）:**
```ini
# グローバル設定
generate=3
type=conventional
locale=ja

[OLLAMA]
model[]=llama3.2
host=http://localhost:11434
```

### その他のプロバイダー

必要に応じてconfigファイル内の該当セクションをコメント解除：

- **OpenAI** (GPT-4, GPT-3.5)
- **Anthropic** (Claude 3.5 Sonnet)
- **Google Gemini** (Gemini 1.5 Pro)
- **Mistral** (Mistral Large)

## 🚀 使用方法

### 基本使用

```bash
git add .
aicommit2

# エイリアス
aic2
```

### 複数候補から選択

```bash
aicommit2 --generate 3
```

### Conventional Commits形式

```bash
aicommit2 --type conventional
```

### コードレビュー

```bash
aicommit2 --code-review
```

### Gitフック統合

コミット時に自動的にメッセージ生成：

```bash
# インストール
aicommit2 hook install

# アンインストール
aicommit2 hook uninstall

# 使用
git commit  # エディタに自動生成されたメッセージが表示される
```

## 🛠️ 設定カスタマイズ

### コマンドライン

```bash
# 設定確認
aicommit2 config get

# モデル変更
aicommit2 config set OLLAMA.model[]=llama3.1:8b

# ロケール変更
aicommit2 config set locale=en

# メッセージ形式変更
aicommit2 config set type=conventional
```

### 設定ファイル直接編集

```bash
nvim ~/.dotfiles/.config/aicommit2/config
```

## 📝 設定例

### 日本語コミットメッセージ（Conventional Commits）

```ini
# グローバル設定
generate=3
type=conventional
locale=ja

[OLLAMA]
model[]=llama3.2
host=http://localhost:11434
```

### 英語コミットメッセージ（標準形式）

```ini
# グローバル設定
generate=2
type=
locale=en

[OLLAMA]
model[]=llama3.2
host=http://localhost:11434
```

### 日本語特化モデル使用

```ini
# グローバル設定
generate=3
type=conventional
locale=ja

[OLLAMA]
model[]=elyza:jp8b
host=http://localhost:11434
```

## 🔧 トラブルシューティング

### Ollamaが起動しない

```bash
# サービス確認（Linux）
sudo systemctl status ollama

# 手動起動
ollama serve
```

### モデルが見つからない

```bash
# ダウンロード済みモデル確認
ollama list

# モデルダウンロード
ollama pull llama3.2
```

### 設定が反映されない

```bash
# 設定ファイル確認
cat ~/.aicommit2

# シンボリックリンク確認
ls -l ~/.aicommit2

# 再リンク
make links
```

## 📚 参考リンク

- [aicommit2 GitHub](https://github.com/tak-bro/aicommit2)
- [Ollama公式](https://ollama.com)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Gitmoji](https://gitmoji.dev/)
