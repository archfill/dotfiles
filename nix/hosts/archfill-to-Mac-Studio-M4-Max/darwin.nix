{ ... }:

# archfill-to-Mac-Studio-M4-Max の nix-darwin system 設定。
# 共通設定は modules/darwin-system.nix、ユーザー定義は flake.nix の
# mkDarwinHost で宣言する。ホスト固有の差分 (追加 cask 等) はここに書く。
{
  imports = [
    ../../modules/darwin-system.nix
  ];

  # このホストだけで使うアプリ (共通の taps / casks リストとマージされる)。
  # 作者配布の tap は非公式なので trusted = true が必要 (darwin-system.nix 参照)。
  homebrew.taps = [
    { name = "kot149/tap"; trusted = true; }
    # repo 名が homebrew- で始まらないため clone_target で URL を指定する
    { name = "yksr-melt/Meltype"; clone_target = "https://github.com/yksr-melt/Meltype.git"; trusted = true; }
  ];

  homebrew.casks = [
    # 仮想マシン (Windows / macOS)。有料 (サブスクリプション)。
    # インストール後処理 (inittool) で sudo のパスワードを求められることがある
    "parallels"

    # Android エミュレータ (cask 名は bluestacks だが中身は BlueStacks Air、Apple Silicon 専用)。
    # pkg インストーラのため導入時に sudo のパスワードを求められることがある
    "bluestacks"

    # 周辺機器
    "logitech-g-hub"
    "logitune"
    "loupedeck"
    # ZMK キーボード (MONA2) の電池残量をメニューバーに表示。
    # 署名が無いため初回起動時に「このまま開く」の許可が必要
    "kot149/tap/zmk-battery-center"

    # Meta Quest をバーチャルディスプレイとして使う Mac 側アプリ。
    # cask 名・pkg 名は旧称 Remote Desktop のまま (bundle ID は com.meta.virtualdesktop)。
    # ヘッドセットと同じネットワーク (5/6GHz 推奨) で接続する
    "meta-quest-remote-desktop"

    # 日本語 IME（試用中、2026-11-17〜）。入れた後に入力ソースへ手で追加する。
    # 設定と学習は ~/Library に残る（cleanup は uninstall なので消えない）
    "yksr-melt/meltype/meltype"
  ];
}
