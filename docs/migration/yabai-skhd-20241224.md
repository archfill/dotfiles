# yabai-skhd 設定アーカイブ記録

## 基本情報

- **設定名**: yabai-skhd
- **アーカイブ日**: 2024-12-24
- **実行者**: dotfiles管理者
- **理由**: Aerospaceウィンドウマネージャーへの移行

## アーカイブ情報

- **アーカイブブランチ**: `archive/yabai-skhd-20241224` (未作成)
- **元ブランチ**: `main`
- **コミットハッシュ**: 現在のHEAD

## 設定概要

### yabai (BSPウィンドウマネージャー)

**設定ファイル**: `.config/yabai/yabairc`

主な機能：
- BSP（Binary Space Partitioning）レイアウト
- ウィンドウの自動配置とリサイズ
- マウス操作によるウィンドウ移動
- アプリケーション除外ルール
- ウィンドウの透明度・影・ボーダー設定

### skhd (ホットキーデーモン)

**設定ファイル**: `.config/skhd/skhdrc`

主な機能：
- ウィンドウフォーカス切り替え (alt + hjkl)
- ウィンドウ移動・スワップ (shift + alt + hjkl)
- ウィンドウリサイズ (shift + cmd + wasd)
- スペース操作 (回転、ミラー、フルスクリーン)
- ウィンドウスタック機能

## 移行先・代替手段

### Aerospace

**新しいウィンドウマネージャー**: [Aerospace](https://github.com/nikitabobko/AeroSpace)

**設定ファイル**: `.aerospace.toml`

#### 移行済みの機能
- ✅ SketchyBarとの連携（スペース切り替え）
- ✅ 基本的なウィンドウ管理
- ✅ ワークスペース管理

#### 移行理由
1. **モダンなアーキテクチャ**: より安定した動作
2. **シンプルな設定**: TOML形式の直感的な設定
3. **メンテナンス性**: 活発に開発されている
4. **macOS統合**: システムとの親和性が高い

## 削除・変更された要素

### 削除されたファイル

1. **skhd launchdサービス設定**
   - ファイル: `.config/skhd/homebrew.mxcl.skhd.plist`
   - 状態: ✅ 削除済み

### コメントアウトされた要素

1. **シンボリックリンク作成**
   - ファイル: `bin/mac/link.sh`
   - 変更: yabai/skhdのリンク処理をコメントアウト

### 削除された要素

1. **stacklineインストール処理**
   - ファイル: `bin/mac/config.sh`
   - 変更: yabai用Hammerspoonプラグインのインストール処理を削除

2. **Zshエイリアス**
   - ファイル: `.config/zsh/zshrc/Darwin/alias.zsh`
   - 変更: `yabai-restart` エイリアスを削除

3. **自動起動処理**
   - ファイル: `.config/zsh/zprofile/Darwin/init.zsh`
   - 変更: skhdの自動起動処理を削除

### 更新された要素

1. **SketchyBar連携**
   - ファイル: `.config/sketchybar/sketchybarrc`
   - 変更: `yabai -m space --focus` → `aerospace workspace`

## 復元方法

yabai/skhd設定を復元する場合：

### 1. 設定ファイルの復元

```bash
# 設定ディレクトリを復元
git checkout archive/yabai-skhd-20241224 -- .config/yabai/
git checkout archive/yabai-skhd-20241224 -- .config/skhd/

# シンボリックリンクを作成
ln -sf ~/.dotfiles/.config/yabai ~/.config/yabai
ln -sf ~/.dotfiles/.config/skhd ~/.config/skhd
```

### 2. 依存関係のインストール

```bash
# Homebrew経由でインストール
brew install yabai
brew install skhd

# サービス開始
brew services start yabai
brew services start skhd
```

### 3. 関連設定の復元

```bash
# Zshエイリアスの復元
echo 'alias yabai-restart="yabai --restart-service"' >> ~/.config/zsh/zshrc/Darwin/alias.zsh

# SketchyBar設定を元に戻す
# .config/sketchybar/sketchybarrc の該当行を手動で変更
```

### 4. Hammerspoon stacklineの復元

```bash
# stacklineプラグインをインストール
git clone https://github.com/AdamWagner/stackline.git ~/.hammerspoon/stackline
```

## 注意事項

- このアーカイブは2024-12-24時点の設定状態です
- 復元時は現在のAerospace設定との競合に注意してください
- SketchyBarの設定変更により、yabai復元時には手動調整が必要です
- macOSのSIP（System Integrity Protection）設定に注意してください

## 関連リンク

- [yabai公式ドキュメント](https://github.com/koekeishiya/yabai)
- [skhd公式ドキュメント](https://github.com/koekeishiya/skhd)
- [Aerospace公式ドキュメント](https://github.com/nikitabobko/AeroSpace)
- [保守手順書](../maintenance.md)

## 質問・サポート

この移行に関する質問がある場合：

1. [保守手順書](../maintenance.md)を確認
2. 移行記録の実行者に連絡
3. GitHubのIssueで報告

---

**移行完了日**: 2024-12-24
**最終更新**: 2024-12-24