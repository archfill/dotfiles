{ pkgs, inputs, ... }:

let
  # ─── Neovim バージョン切替フラグ ────────────────────────────────
  # true  → neovim-nightly-overlay の nightly ビルド
  # false → nixpkgs unstable の stable 版
  useNeovimNightly = false;

  neovimNightly =
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

  neovimPackage =
    if useNeovimNightly
    then neovimNightly
    else pkgs.neovim;
in
{
  home.username = "chill-rf";
  home.homeDirectory = "/Users/chill-rf";

  # 初回 install 時点の home-manager リリース版。以降は変更しない。
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ── Neovim 本体のみ提供 ───────────────────────────────────────
  # programs.neovim モジュールは init.lua 等を生成して既存 dotfiles と
  # 競合するため使わず、wrapped neovim パッケージを直接 home.packages
  # に入れることで .config/nvim/ を完全に既存のまま保つ。
  # Lua プラグイン (Telescope / Treesitter 等) から呼ぶ周辺ツールも併せる。
  home.packages = with pkgs; [
    neovimPackage
    ripgrep
    fd
  ];
}
