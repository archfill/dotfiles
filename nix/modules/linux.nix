{ config, ... }:

# home-manager の Linux 共通設定。
# ホスト固有 (home.username / homeDirectory / GUI 環境) は
# nix/hosts/<host>.nix で個別宣言する想定。
#
# 用途:
# - Arch / Ubuntu / WSL 上の standalone home-manager
# - NixOS の home-manager モジュール経由 (homeManager.users.<user>)
#
# 共通の home-manager 設定はすべて nix/modules/common.nix にあるため、
# 本ファイルは現状 placeholder。Linux でだけ必要な設定が出てきたら
# (例: Wayland / X11 連携、Linux 固有の env var) ここに集約する。
{
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/hypr";

  xdg.configFile."waybar".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/waybar";

  xdg.configFile."rofi".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/rofi";

  xdg.configFile."swaync".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/swaync";

  xdg.configFile."matugen".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/matugen";

  # Linux でもフォント認識を有効化 (macOS 側と同じく fonts.fontconfig は
  # nix/modules/common.nix で enable 済みなので追記不要)。
}
