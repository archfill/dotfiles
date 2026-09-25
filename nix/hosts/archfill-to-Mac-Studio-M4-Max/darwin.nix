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
  ];

  homebrew.casks = [
    # 仮想マシン (Windows / macOS)。有料 (サブスクリプション)。
    # インストール後処理 (inittool) で sudo のパスワードを求められることがある
    "parallels"

    # 周辺機器
    "logitech-g-hub"
    "logitune"
    "loupedeck"
    # ZMK キーボード (MONA2) の電池残量をメニューバーに表示。
    # 署名が無いため初回起動時に「このまま開く」の許可が必要
    "kot149/tap/zmk-battery-center"
  ];
}
