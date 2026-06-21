{ ... }:

{
  imports = [
    ../../modules/common.nix
    ../../modules/linux.nix
    ../../modules/standalone-linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";
}
