{ pkgs, config, ... }:

{
  imports = [
    ../../modules/nixos-common.nix
    ../../modules/desktop/hyprland.nix
    ./hardware.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      gfxmodeEfi = "1024x768";
      useOSProber = true;
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [
    "iptable_nat"
  ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  networking.hostName = "archfill-nixos";

  security.sudo.extraRules = [
    {
      users = [ "archfill" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "archfill" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    ghostty
    google-chrome
    vscode
    winboat
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
