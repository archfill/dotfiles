# aicommit2 使用手順

このガイドでは、aicommit2 + Ollamaを使ったAI自動コミットメッセージ生成の使い方を説明します。

---

## ✅ インストール状況

現在の環境：
- ✅ **Ollama**: v0.12.5 インストール済み
- ✅ **aicommit2**: v2.4.7 インストール済み
- ✅ **設定ファイル**: `~/.aicommit2` リンク済み
- ✅ **Ollamaサービス**: 起動中

---

## 📝 ステップバイステップ使用手順

### **ステップ1: モデルのダウンロード（初回のみ）**

設定ファイルで指定した`llama3.2`モデルをダウンロードします：

```bash
ollama pull llama3.2
```

**ダウンロード時間:** 約5-10分（2GB）

**確認:**
```bash
ollama list
```

以下のように表示されればOK：
```
NAME         ID         SIZE    MODIFIED
llama3.2:latest  abc123...  2.0 GB  1 minute ago
```

---

### **ステップ2: モデルの動作テスト（オプション）**

ダウンロードしたモデルが正常に動作するか確認：

```bash
ollama run llama3.2 "Hello, how are you?"
```

応答が返ってくればOKです。`/bye`で終了。

---

### **ステップ3: aicommit2の基本使用**

#### **3-1. 基本的な使い方**

```bash
# 1. ファイルを変更
echo "test" >> test.txt

# 2. Gitにステージング
git add test.txt

# 3. aicommit2を実行
aicommit2
```

以下のような画面が表示されます：

```
┌ Generated commit messages (3 options)
│
│ 1. feat: Add test.txt with initial content
│ 2. chore: Create test.txt file for testing
│ 3. docs: Add test.txt documentation file
│
└ Use ↑/↓ to select, Enter to commit, Esc to cancel
```

**操作方法:**
- `↑/↓` キー: 選択
- `Enter`: コミット実行
- `Esc` または `Ctrl+C`: キャンセル

---

#### **3-2. コマンドラインオプション**

```bash
# 複数候補を生成（デフォルトは3、最大5）
aicommit2 --generate 5
aicommit2 -g 5

# Conventional Commits形式を強制
aicommit2 --type conventional
aicommit2 -t conventional

# Gitmoji形式（絵文字付き）
aicommit2 --type gitmoji

# ロケール指定（日本語/英語）
aicommit2 --locale ja
aicommit2 --locale en

# コードレビュー機能
aicommit2 --code-review
aicommit2 -r

# コミットせずにメッセージのみ生成
aicommit2 --no-verify
```

---

### **ステップ4: Gitフック統合（自動化）**

コミット時に自動的にメッセージを生成：

```bash
# フックをインストール
aicommit2 hook install

# 確認
ls -la .git/hooks/prepare-commit-msg

# 使用方法
git add .
git commit  # メッセージが自動生成されてエディタが開く
```

**フックのアンインストール:**
```bash
aicommit2 hook uninstall
```

---

## 🎯 実践例

### **例1: 新機能追加**

```bash
# 新しい機能を追加
vim src/feature.js

# ステージング
git add src/feature.js

# aicommit2実行
aicommit2

# 生成例:
# feat: Add user authentication feature
# fix: Implement login validation logic
# chore: Update user authentication module
```

---

### **例2: バグ修正**

```bash
# バグを修正
vim src/buggy-code.js

# ステージング
git add src/buggy-code.js

# aicommit2実行
aicommit2

# 生成例:
# fix: Resolve null pointer exception in user login
# fix: Correct error handling in authentication
# fix: Fix validation logic for user credentials
```

---

### **例3: 複数ファイルの変更**

```bash
# 複数ファイルを変更
vim src/auth.js src/utils.js tests/auth.test.js

# 全てステージング
git add src/ tests/

# aicommit2実行
aicommit2

# 生成例:
# feat: Implement authentication system with tests
# refactor: Update auth module and add unit tests
# chore: Improve authentication logic and coverage
```

---

## ⚙️ 設定カスタマイズ

### **モデルを変更**

より高性能なモデルに変更する場合：

```bash
# llama3.1:8b（8Bパラメータ）をダウンロード
ollama pull llama3.1:8b

# 設定変更
aicommit2 config set OLLAMA.model[]=llama3.1:8b

# または設定ファイルを直接編集
nvim ~/.dotfiles/.config/aicommit2/config
```

**推奨モデル:**
- `llama3.2` - 軽量・高速（3B、推奨）
- `llama3.1:8b` - 高性能（8B、精度重視）
- `codellama` - コード特化
- `elyza:jp8b` - 日本語特化

---

### **メッセージ形式を変更**

```bash
# Conventional Commits形式に変更
aicommit2 config set type=conventional

# Gitmoji形式に変更
aicommit2 config set type=gitmoji

# 標準形式（プレフィックスなし）
aicommit2 config set type=
```

---

### **ロケールを変更**

```bash
# 英語メッセージ
aicommit2 config set locale=en

# 日本語メッセージ
aicommit2 config set locale=ja
```

---

### **生成数を変更**

```bash
# 5候補生成
aicommit2 config set generate=5

# 1候補のみ（自動コミット）
aicommit2 config set generate=1
```

---

## 🔧 トラブルシューティング

### **問題1: "Ollama is not running"**

**原因:** Ollamaサービスが起動していない

**解決方法:**
```bash
# サービス状態確認
sudo systemctl status ollama

# 起動
sudo systemctl start ollama

# 自動起動設定
sudo systemctl enable ollama
```

---

### **問題2: "Model not found"**

**原因:** モデルがダウンロードされていない

**解決方法:**
```bash
# モデル一覧確認
ollama list

# モデルダウンロード
ollama pull llama3.2
```

---

### **問題3: "Connection refused"**

**原因:** Ollamaサーバーに接続できない

**解決方法:**
```bash
# サーバーURL確認
aicommit2 config get OLLAMA.host

# デフォルトに戻す
aicommit2 config set OLLAMA.host=http://localhost:11434
```

---

### **問題4: 生成が遅い**

**原因:** モデルサイズが大きい、またはハードウェア性能

**解決方法:**
```bash
# 軽量モデルに変更
ollama pull llama3.2:1b  # 1Bパラメータ版
aicommit2 config set OLLAMA.model[]=llama3.2:1b

# コンテキストサイズを削減
aicommit2 config set OLLAMA.numCtx=2048
```

---

### **問題5: メッセージが適切でない**

**原因:** モデルの理解度、プロンプト設定

**解決方法:**
```bash
# 高性能モデルに変更
ollama pull llama3.1:8b
aicommit2 config set OLLAMA.model[]=llama3.1:8b

# 温度パラメータ調整（0.0-2.0、低いほど安定）
aicommit2 config set OLLAMA.temperature=0.5

# 複数候補から選択
aicommit2 --generate 5
```

---

## 📊 パフォーマンスチューニング

### **軽量・高速設定**

```bash
# 設定ファイルを編集
nvim ~/.dotfiles/.config/aicommit2/config
```

```ini
# 軽量設定
generate=2
max-length=50

[OLLAMA]
model[]=llama3.2:1b
numCtx=2048
maxTokens=1000
temperature=0.5
```

---

### **高精度設定**

```ini
# 高精度設定
generate=5
max-length=100

[OLLAMA]
model[]=llama3.1:8b
numCtx=8192
maxTokens=4000
temperature=0.7
```

---

## 🚀 高度な使い方

### **複数モデルの並行使用**

```bash
# 複数モデルをダウンロード
ollama pull llama3.2
ollama pull codellama

# 設定で複数指定
aicommit2 config set OLLAMA.model[]=llama3.2
aicommit2 config set OLLAMA.model[]=codellama

# 実行すると両方のモデルから提案を受け取る
aicommit2
```

---

### **カスタムプロンプト**

独自のプロンプトを使用する場合：

```bash
# プロンプトファイル作成
cat > ~/.config/aicommit2/custom-prompt.txt <<'EOF'
以下のGit diffを分析して、簡潔で分かりやすいコミットメッセージを生成してください。
メッセージは50文字以内、Conventional Commits形式で書いてください。
EOF

# 設定
aicommit2 config set systemPromptPath=~/.config/aicommit2/custom-prompt.txt
```

---

## 💡 ベストプラクティス

### **推奨ワークフロー**

```bash
# 1. 変更を確認
git status
git diff

# 2. 適切な粒度でステージング
git add src/feature1.js  # 機能ごとに分割

# 3. aicommit2でメッセージ生成
aicommit2

# 4. 必要に応じて編集
# （エディタで微調整）

# 5. プッシュ
git push
```

---

### **避けるべきこと**

❌ **大量のファイルを一度にコミット:**
```bash
# 悪い例
git add .
aicommit2  # メッセージが曖昧になる
```

✅ **機能ごとに分割してコミット:**
```bash
# 良い例
git add src/auth.js
aicommit2

git add src/api.js
aicommit2
```

---

## 📚 参考リンク

- [aicommit2 GitHub](https://github.com/tak-bro/aicommit2)
- [Ollama公式](https://ollama.com)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [dotfiles設定](~/.dotfiles/.config/aicommit2/)

---

## 🆘 サポート

問題が解決しない場合：

1. **設定を確認:**
   ```bash
   aicommit2 config get
   ```

2. **ログを確認:**
   ```bash
   # ログ有効化
   aicommit2 config set logging=true

   # ログ確認
   cat ~/.aicommit2.log
   ```

3. **設定をリセット:**
   ```bash
   rm ~/.aicommit2
   make links
   ```

4. **Issue報告:**
   - [aicommit2 Issues](https://github.com/tak-bro/aicommit2/issues)
