{ inputs, pkgs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ../../modules/common.nix
    ../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";

  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
    cli.enable = true;

    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };
}
