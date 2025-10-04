# WSL設定ファイル

このディレクトリにはWSL（Windows Subsystem for Linux）固有の設定ファイルが含まれています。

## ファイル一覧

### wslconfig.template
- **用途**: WSL2の動作設定テンプレート
- **配置場所**: Windows側の `C:\Users\username\.wslconfig` にコピー
- **主要設定**:
  - メモリ使用量制限
  - プロセッサ数制限
  - ネットワーク設定
  - パフォーマンス最適化

### windows_terminal.json（移行済み）
- **用途**: Windows Terminal設定（`windows/windows_terminal.json`に移行済み）
- **配置場所**: 自動シンボリックリンク（`make windows-setup`で自動作成）
- **主要設定**:
  - Arch Linux / Ubuntu プロファイル
  - フォント設定（HackGen Console NF推奨）
  - カラースキーム
  - キーバインド

### environment（自動生成）
- **用途**: WSL固有の環境変数
- **生成元**: `bin/wsl/wsl_enhancements.sh`により自動生成
- **内容**:
  - Windows統合パス
  - クリップボード設定
  - WSL環境識別変数

### windows_aliases（自動生成）
- **用途**: Windows統合エイリアス
- **生成元**: `bin/wsl/windows_integration.sh`により自動生成
- **内容**:
  - Windowsアプリケーション起動エイリアス
  - ファイルパス変換関数
  - クリップボード操作エイリアス

## セットアップ

1. WSL基本セットアップ:
   ```bash
   make wsl-setup
   ```

2. Windows統合機能のセットアップ:
   ```bash
   make wsl-windows-integration
   ```

3. Windows設定の自動セットアップ:
   ```bash
   make windows-setup  # 管理者権限が必要
   ```
   - `.wslconfig` のシンボリックリンク作成
   - Windows Terminal設定のシンボリックリンク作成（動的検出）

4. 設定状態の確認:
   ```bash
   make windows-status
   ```

## 動作確認

WSL環境が正しく設定されているかを確認:

```bash
# WSL検出
make test

# WSL固有機能テスト
echo $WSL_ENV
win32yank --version
```

## トラブルシューティング

### よくある問題

1. **クリップボード統合が動作しない**
   - `win32yank`がインストールされているか確認
   - Windows側のセキュリティ設定を確認

2. **フォントが正しく表示されない**
   - HackGen Console NFフォントがインストールされているか確認
   - `fc-cache -fv`でフォントキャッシュを更新

3. **パフォーマンスが悪い**
   - `.wslconfig`の設定を見直し
   - WSL2を使用しているか確認
   - Windows側のメモリ使用量を確認

### ログ確認

```bash
# WSLログ確認
dmesg | grep -i wsl

# フォント確認
fc-list | grep -i hack
```