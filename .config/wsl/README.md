# WSL設定ファイル

このディレクトリにはWSL（Windows Subsystem for Linux）固有の設定ファイルが含まれています。

## ファイル一覧

### wslconfig.template
- **用途**: WSL2の動作設定テンプレート
- **配置場所**: Home Managerで `~/.config/wsl/wslconfig.template` に配置。Windows側の `C:\Users\username\.wslconfig` は `windows/setup.ps1` で管理
- **主要設定**:
  - メモリ使用量制限
  - プロセッサ数制限
  - ネットワーク設定
  - パフォーマンス最適化

### WSL shell integration
- **用途**: WSL固有の環境変数、PATH優先順位、Windows統合エイリアス
- **管理場所**:
  - `.config/zsh/zshenv/WSL/init.zsh`
  - `.config/zsh/zprofile/WSL/alias.zsh`
- **補足**: `win32yank` は `nix/modules/wsl.nix` で Home Manager 管理

## セットアップ

1. WSL user環境の反映:
   ```bash
   make rebuild NIX_ATTR='archfill@wsl-ubuntu'
   ```

2. Windows設定の自動セットアップ:
   ```bash
   make windows-setup  # 管理者権限が必要
   ```
   - `.wslconfig` のシンボリックリンク作成
   - Windows Terminal設定はテンプレートのみ提供し、実体は各デバイスで管理

3. 設定状態の確認:
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
