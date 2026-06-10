{ pkgs, ... }:

{
  # ─── Determinate Nix を使用しているため nix-darwin の nix 管理は無効 ───
  # Determinate Installer は独自で /nix daemon を管理しているため
  # nix-darwin に介入させない (nix.enable = false が必須)
  nix.enable = false;

  # ─── プラットフォーム ─────────────────────────────────────────────
  nixpkgs.hostPlatform = "aarch64-darwin";

  # ─── ユーザー定義 ─────────────────────────────────────────────────
  users.users.chill-rf = {
    name = "chill-rf";
    home = "/Users/chill-rf";
  };

  # nix-darwin の一部オプション (homebrew.onActivation 等) で primaryUser を要求
  system.primaryUser = "chill-rf";

  # ─── state version (nix-darwin 自体のスキーマバージョン) ────────────
  # 変更時はマニュアルを必ず確認すること。気軽に上げない。
  system.stateVersion = 6;
}
