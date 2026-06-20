{ ... }:

{
  imports = [
    ../../../modules/nixos-common.nix
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "CHANGE-ME";

  system.stateVersion = "26.05";
}
