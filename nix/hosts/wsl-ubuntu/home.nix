{ ... }:

{
  imports = [
    ../../modules/common.nix
    ../../modules/linux.nix
    ../../modules/standalone-linux.nix
    ../../modules/wsl.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";
}
