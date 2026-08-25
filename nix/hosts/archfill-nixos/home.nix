{ inputs, pkgs, ... }:

let
  rovehelmPackage = inputs.rovehelm.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";

  home.packages = [
    pkgs.opencode
    rovehelmPackage
  ];

  gtk = {
    enable = true;

    # GTK 2 cannot use the GTK 3 Adwaita port. Keep its legacy config
    # unmanaged while making GTK 3/4 consistently prefer the dark scheme.
    gtk2.enable = false;

    gtk3 = {
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      colorScheme = "dark";
    };

    gtk4.colorScheme = "dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      font-name = "Noto Sans CJK JP 10";
      document-font-name = "Noto Sans CJK JP 10";
      monospace-font-name = "Noto Sans Mono CJK JP 10";
    };
  };

}
