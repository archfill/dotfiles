{ ... }:

# home-manager の entry point。
# プラットフォーム横断の宣言は modules/common.nix に集約し、
# OS 固有の宣言 (username/homeDirectory 等) は modules/<os>.nix に分離する。
# Linux 対応時は modules/linux.nix を追加し、flake.nix 側で OS 別に
# 渡す imports を切り替える設計。
{
  imports = [
    ./modules/common.nix
    ./modules/darwin.nix
  ];
}
