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
