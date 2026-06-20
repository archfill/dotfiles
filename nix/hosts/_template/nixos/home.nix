{ ... }:

{
  imports = [
    ../../../modules/common.nix
    ../../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";
}
