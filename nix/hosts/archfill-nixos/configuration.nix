{ pkgs, config, ... }:

let
  onepasswordMcp = pkgs.stdenv.mkDerivation {
    pname = "onepassword-mcp";
    version = pkgs._1password-gui.version;

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.glibc
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm555 ${pkgs._1password-gui}/share/1password/onepassword-mcp \
        $out/bin/onepassword-mcp
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "1Password Environments MCP server from the 1Password desktop app";
      homepage = "https://www.1password.dev/environments/mcp-codex-server";
      license = licenses.unfree;
      mainProgram = "onepassword-mcp";
      platforms = platforms.linux;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
in
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
      default = "saved";
      useOSProber = true;
      extraEntries = ''
        if [ "$grub_platform" = "efi" ]; then
          menuentry "UEFI Firmware Settings" {
            fwsetup
          }
        fi
      '';
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
  system.boot.loader.kernelFile = "vmlinuz";
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

  services.udev.extraRules = ''
    # The GSX 1000 reports its main wheel as Volume-Down in both directions.
    ACTION=="add|change", SUBSYSTEM=="input", ATTRS{idVendor}=="1395", ATTRS{idProduct}=="00a0", ENV{ID_INPUT}="0", ENV{ID_INPUT_KEY}="0", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

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
    nvidiaPersistenced = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    brave
    ghostty
    google-chrome
    onepasswordMcp
    vscode
    zed-editor
    winboat
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
