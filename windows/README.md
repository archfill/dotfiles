# Windows Dotfiles Setup

このディレクトリには、Windows環境用の設定ファイルとセットアップスクリプトが含まれています。

## 📁 ファイル構成

```
windows/
├── setup.ps1                         # メインセットアップスクリプト
├── status.ps1                        # 設定状態の確認スクリプト
├── install-fonts.ps1                 # Nerd Fontsインストールスクリプト
├── link-wezterm.ps1                  # WezTerm設定リンク作成スクリプト
├── link-alacritty.ps1                # Alacritty設定リンク作成スクリプト
├── .wslconfig                        # WSL2設定ファイル
├── windows_terminal.template.json    # Windows Terminal設定テンプレート（参考用）
├── PowerShell_profile.ps1            # PowerShell 7プロファイル
├── .glazewm/                         # GlazeWM設定
│   └── config.yaml
└── .zebar/                           # Zebar設定
    ├── settings.json
    ├── config.yaml
    └── custom-*
```

## 🚀 使い方

### 基本セットアップ

以下を管理者権限で実行（自動的に管理者権限に昇格します）：

```powershell
cd $env:USERPROFILE\dotfiles\windows
.\setup.ps1
```

これにより以下の設定がシンボリックリンクで管理されます：
- ✅ `.wslconfig` → `~\.wslconfig`
- ✅ `PowerShell 7 Profile` → `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- ✅ `GlazeWM` → `~\.glzr\glazewm\config.yaml`
- ✅ `Zebar` → `~\.glzr\zebar\settings.json`

### ターミナルエミュレータ設定（オプション）

必要なターミナルエミュレータのみ個別に設定できます：

#### WezTerm設定

```powershell
cd $env:USERPROFILE\dotfiles\windows
.\link-wezterm.ps1
```

- **ソース**: `$env:USERPROFILE\dotfiles\.config\wezterm\`
- **ターゲット**: `$env:USERPROFILE\.config\wezterm\`

#### Alacritty設定

```powershell
cd $env:USERPROFILE\dotfiles\windows
.\link-alacritty.ps1
```

- **ソース**: `$env:USERPROFILE\dotfiles\.config\alacritty\`
- **ターゲット**: `$env:APPDATA\alacritty\`

### フォント管理（オプション）

開発環境向けフォントを2つの方法でインストール：

```powershell
cd $env:USERPROFILE\dotfiles\windows
.\install-fonts.ps1
```

#### フォント管理の2層構造

**1️⃣ Scoop (nerd-fonts bucket)**
- プログラミング用フォント（FiraCode, JetBrainsMono等）
- パッケージマネージャーで管理
- `scoop update`で一括更新可能

**2️⃣ GitHub直接ダウンロード**
- 日本語対応フォント（HackGen, PlemolJP, UDEV Gothic）
- GitHub APIで最新版を自動取得
- 自動ダウンロード＆インストール

#### インストールモード

**インタラクティブモード（デフォルト）:**
```powershell
.\install-fonts.ps1
# メニューから選択:
#   [A] すべてインストール
#   [P] プログラミング用のみ (Scoop)
#   [J] 日本語対応のみ (GitHub)
#   [1-12] 個別選択
```

**コマンドラインモード:**
```powershell
# すべてインストール
.\install-fonts.ps1 -All

# プログラミング用のみ (Scoop)
.\install-fonts.ps1 -Programming

# 日本語対応のみ (GitHub)
.\install-fonts.ps1 -Japanese

# 個別指定（通常版とNF版を組み合わせ可能）
.\install-fonts.ps1 -Fonts FiraCode-NF-Mono,HackGen,HackGenConsole-NF,PlemolJPConsole
```

#### 利用可能なフォント

**📦 プログラミング用 (via Scoop):**
- `FiraCode-NF-Mono` - Fira Code（リガチャ対応、人気）
- `JetBrainsMono-NF-Mono` - JetBrains Mono（JetBrains製）
- `CascadiaCode-NF-Mono` - Cascadia Code（Microsoft製）
- `Hack-NF-Mono` - Hack（シンプル、読みやすい）

**🐙 日本語対応 (via GitHub):**

*HackGen 通常版（Nerd Fontsなし）:*
- `HackGen` - HackGen（Hack + 源ノ角ゴシック）
- `HackGen-Console` - HackGen Console（全角スペース可視化）
- `HackGen35` - HackGen35（3:5幅版）
- `HackGen35-Console` - HackGen35 Console（3:5幅 + 全角スペース可視化）

*HackGen Nerd Fonts版:*
- `HackGenConsole-NF` - HackGen Console NF（Nerd Fonts + 全角スペース可視化）
- `HackGen35Console-NF` - HackGen35 Console NF（Nerd Fonts + 3:5幅 + 可視化）

*その他の日本語フォント:*
- `PlemolJPConsole` - PlemolJP Console NF（IBM Plex Mono + 日本語）
- `UDEVGothic` - UDEV Gothic NF（BIZ UDゴシック + JetBrains Mono）

**⚠️ 注意:** v2.7.0以降、HackGen Nerd FontsはConsole版のみ提供されています。通常版（Nerd Fontsなし）は全バリアントが利用可能です。

#### HackGenバリエーションの違い

**幅の違い:**
- **HackGen / HackGenConsole**: 半角:全角 = 1:2（標準的な等幅）
- **HackGen35 / HackGen35Console**: 半角:全角 = 3:5（やや狭い全角、詰まった表示）

**Console版の特徴:**
- 全角スペースが可視化される（`□`で表示）
- ターミナル作業に最適
- 通常版とNerd Fonts版の両方が利用可能

**Nerd Fonts版（-NF）の特徴:**
- アイコングリフ対応（開発ツールのアイコン表示）
- v2.7.0以降はConsole版のみ提供

**推奨用途:**
- 一般的なターミナル/エディタでの日本語コーディング → `HackGen` / `HackGenConsole-NF`
- 狭い画面で多くの情報を表示したい → `HackGen35` / `HackGen35Console-NF`
- アイコングリフが必要 → Nerd Fonts版（`*-NF`）
- IBM Plexベースが好み → `PlemolJPConsole`
- BIZ UDゴシックベースが好み → `UDEVGothic`

### 設定状態の確認

すべての設定のリンク状態を確認：

```powershell
cd $env:USERPROFILE\dotfiles\windows
.\status.ps1
```

## 📦 管理される設定

### WSL設定 (.wslconfig)

WSL2のパフォーマンス最適化設定：
- メモリ: 12GB
- CPU: 8コア
- スワップ: 4GB
- ネットワーク: mirrored/nat
- GUI最適化有効

### Windows Terminal（テンプレートのみ提供）

**注意**: Windows Terminalの設定は**デバイス固有の情報**（ユーザー名、WSLディストリビューション名、インストールパス等）を含むため、dotfilesでは管理**しません**。

代わりに`windows_terminal.template.json`を参考用のテンプレートとして提供しています：
- カラースキーム（Tokyo Night等）
- キーバインド設定
- デフォルト設定の参考例

各デバイスでWindows Terminalの設定は個別にカスタマイズしてください。

### PowerShell 7プロファイル

UTF-8エンコーディング設定と日本語環境対応：
- コードページUTF-8設定
- 環境変数設定
- エイリアス設定
- dotfiles管理用関数

### GlazeWM

タイリングウィンドウマネージャー設定

### Zebar

ステータスバー設定（GlazeWMと連携）

### WezTerm（オプション）

クロスプラットフォーム対応のGPU加速ターミナルエミュレータ設定：
- `wezterm.lua` - メイン設定
- `keybinds.lua` - キーバインド
- `on.lua` - イベントハンドラ
- `utils.lua` - ユーティリティ関数

### Alacritty（オプション）

OpenGL対応の高速ターミナルエミュレータ設定：
- `alacritty.toml` - メイン設定
- `common.toml` - 共通設定
- `windows.toml` - Windows固有設定

### Fonts（オプション）

開発環境向けフォント管理（2層構造）：

**Scoop管理:**
- nerd-fonts bucketからインストール
- プログラミング用フォント（FiraCode, JetBrainsMono等）
- `scoop update`で一括更新可能

**GitHub管理:**
- GitHub APIで最新版を自動取得
- 日本語対応フォント（HackGen, PlemolJP, UDEV Gothic）
- 自動ダウンロード＆インストール

**特徴:**
- インタラクティブ・コマンドライン両対応
- インストール済みチェック
- 全てPowerShellで完結

## 🔒 安全性

すべてのスクリプトは以下の安全対策を実装しています：

1. **既存設定の自動バックアップ**
   - フォーマット: `*.backup.YYYYMMDD-HHMMSS`
   - シンボリックリンク作成前に既存ファイルを保護

2. **管理者権限の自動昇格**
   - 必要に応じて自動的に管理者権限で再実行
   - ユーザーによる手動昇格の手間を削減

3. **エラーハンドリング**
   - 各操作の成功/失敗を明確に表示
   - 失敗時は詳細なエラーメッセージを表示

## 💡 必要なソフトウェア

### 必須
- **PowerShell 7** (pwsh) - 最新版を推奨

### 推奨
- **Windows Terminal** - テンプレート設定を参考にしてください
- **Scoop** - パッケージマネージャー（フォント管理に使用）
  - インストール: `irm get.scoop.sh | iex`
  - 詳細: https://scoop.sh

### オプション
- **WezTerm** - https://wezfurlong.org/wezterm/
- **Alacritty** - https://alacritty.org/
- **GlazeWM** - タイリングウィンドウマネージャー
- **Zebar** - ステータスバー

## 🔧 トラブルシューティング

### シンボリックリンクが作成できない

**原因**: 開発者モードが無効

**解決方法**:
1. 設定 → システム → 開発者向け
2. 「開発者モード」を有効化

または管理者権限で実行

### 既存の設定を復元したい

バックアップファイルから復元：

```powershell
# 例: PowerShell 7プロファイルの復元
Copy-Item "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1.backup.20251025-123456" `
          "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
```

### スクリプトが実行できない

**原因**: 実行ポリシーの制限

**解決方法**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### フォントがインストールできない

**原因1**: Scoopがインストールされていない

**解決方法**:
```powershell
irm get.scoop.sh | iex
```

**原因2**: nerd-fonts bucketが追加されていない

**解決方法**: `install-fonts.ps1`が自動的に追加します。手動で追加する場合：
```powershell
scoop bucket add nerd-fonts
```

### インストールしたフォントが表示されない

**原因**: ターミナルを再起動していない

**解決方法**: ターミナルエミュレータを再起動してください

## 📚 関連ドキュメント

- [dotfiles メインREADME](../README.md)
- [CLAUDE.md](../CLAUDE.md) - 設計方針と変更履歴
