# Windows用 WezTerm セットアップスクリプト

純粋なWindows環境でWezTerm設定のシンボリックリンクを作成するためのPowerShellスクリプトです。

## ファイル構成

- `setup-wezterm-links.ps1` - PowerShellスクリプト（Windows 10/11対応）

## 使用方法

### PowerShellスクリプト

```powershell
# 管理者権限でPowerShellを起動してから実行

# 通常実行
.\setup-wezterm-links.ps1

# 既存ファイルを強制上書き
.\setup-wezterm-links.ps1 -Force

# 実行前プレビュー（実際の変更なし）
.\setup-wezterm-links.ps1 -WhatIf

# 詳細ログ出力
.\setup-wezterm-links.ps1 -Verbose

# 複数オプション組み合わせ
.\setup-wezterm-links.ps1 -Force -Verbose -WhatIf
```

## 管理者権限について

Windowsでシンボリックリンクを作成するには管理者権限が必要です。

### 管理者権限でPowerShellを起動する方法
1. スタートメニューで「PowerShell」を検索
2. 「Windows PowerShell」または「PowerShell」を右クリック
3. 「管理者として実行」を選択

## 作成されるシンボリックリンク

| リンク元（dotfiles） | リンク先（Windows） |
|---------------------|---------------------|
| `dotfiles\.config\wezterm` | `%USERPROFILE%\.config\wezterm` |

## 動作要件

- Windows 10 以降
- PowerShell 3.0 以降
- 管理者権限

## トラブルシューティング

### 「管理者権限が必要です」エラー
**原因**: シンボリックリンク作成に管理者権限が必要
**解決**: 管理者権限でスクリプトを実行してください

### 「ソースパスが見つかりません」エラー
**原因**: dotfilesのWezTerm設定ディレクトリが存在しない
**解決**: 正しいdotfilesディレクトリから実行しているか確認してください

### 「ターゲットが既に存在します」エラー
**原因**: リンク先に既にファイル/ディレクトリが存在する
**解決**: `-Force` オプションを使用して強制上書きしてください

### PowerShellの実行ポリシーエラー
**原因**: PowerShellの実行ポリシーが制限されている
**解決**: 以下のコマンドを管理者権限のPowerShellで実行
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 特徴

- **管理者権限チェック**: シンボリックリンク作成に必要な権限を自動確認
- **既存ファイル処理**: 既存の設定を安全にバックアップ
- **WhatIfモード**: 実際の変更前にプレビュー可能
- **エラーハンドリング**: 詳細なエラーメッセージとログ出力
- **モダンなPowerShell**: Windows 10/11の最新環境に最適化

## 使用例

```powershell
# dotfilesディレクトリに移動
cd C:\Users\username\dotfiles

# PowerShellで実行前確認
.\bin\windows\setup-wezterm-links.ps1 -WhatIf

# 問題なければ実際に実行
.\bin\windows\setup-wezterm-links.ps1 -Force
```

実行後、WezTermを再起動すると dotfiles の設定が適用されます。