{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    # Hyprland core
    hyprcursor
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    hyprshot
    hyprpolkitagent

    # Wayland desktop tools
    waybar
    rofi
    rofi-calc
    rofi-emoji
    swaynotificationcenter
    wl-clipboard
    cliphist
    satty
    matugen
    dart-sass
    ags
    eww
    wlogout
    overskride

    # Desktop utilities used by the existing Hyprland config/scripts
    pavucontrol
    brightnessctl
    playerctl
    networkmanagerapplet
    btop
    papirus-icon-theme
    kdePackages.dolphin

    # NVIDIA Wayland / VA-API support
    egl-wayland
    nvidia-vaapi-driver
  ];
}
