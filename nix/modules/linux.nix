{ config, pkgs, ... }:

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
  home.packages = with pkgs; [
    cliphist
    curl
    ffmpeg
    ffmpegthumbnailer
    gettext
    imagemagick
    less
    matugen
    mpv
    p7zip
    poppler-utils
    rofi
    sqlite
    unzip
    wl-clipboard
    zoxide
  ];

  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/hypr";

  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/niri";

  xdg.configFile."rofi".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/rofi";

  xdg.configFile."matugen".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/matugen";

  xdg.dataFile."icons/hicolor/scalable/apps/input-keyboard.svg".source =
    "${pkgs.gnome-control-center}/share/icons/hicolor/scalable/apps/org.gnome.Settings-keyboard-symbolic.svg";

  xdg.dataFile."icons/hicolor/scalable/apps/input-keyboard-symbolic.svg".source =
    "${pkgs.gnome-control-center}/share/icons/hicolor/scalable/apps/org.gnome.Settings-keyboard-symbolic.svg";

  xdg.dataFile."icons/hicolor/scalable/apps/applications-system.svg".source =
    "${pkgs.gnome-control-center}/share/icons/hicolor/scalable/apps/org.gnome.Settings-applications-symbolic.svg";

  xdg.dataFile."icons/hicolor/scalable/apps/preferences-system-network.svg".source =
    "${pkgs.gnome-control-center}/share/icons/hicolor/scalable/apps/org.gnome.Settings-network-symbolic.svg";

  xdg.dataFile."icons/hicolor/scalable/actions/application-exit.svg".source =
    "${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/actions/application-exit-symbolic.svg";

  xdg.dataFile."icons/hicolor/scalable/actions/view-refresh.svg".source =
    "${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/actions/view-refresh-symbolic.svg";

  # Linux でもフォント認識を有効化 (macOS 側と同じく fonts.fontconfig は
  # nix/modules/common.nix で enable 済みなので追記不要)。
}
