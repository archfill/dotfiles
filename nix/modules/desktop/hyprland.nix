{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
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
    hyprpicker
    hyprshot
    hyprpolkitagent

    # Wayland desktop tools
    rofi
    wl-clipboard
    cliphist
    satty
    matugen
    gettext
    overskride

    # Desktop utilities used by the existing Hyprland config/scripts
    pavucontrol
    brightnessctl
    libnotify
    playerctl
    networkmanagerapplet
    nwg-look
    kdePackages.dolphin

    # NVIDIA Wayland / VA-API support
    egl-wayland
    nvidia-vaapi-driver
  ];
}
