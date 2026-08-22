{ inputs, pkgs, config, ... }:

let
  ghosttyFcitxWorkaround = pkgs.runCommand "ghostty-fcitx-workaround" {
    name = "ghostty-fcitx-workaround";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    meta = pkgs.ghostty.meta;
  } ''
    cp -a --no-preserve=mode,ownership ${pkgs.ghostty}/. $out/
    chmod -R u+w $out
    chmod +x $out/bin/ghostty

    wrapProgram $out/bin/ghostty --unset GTK_IM_MODULE

    ghostty_desktop_entry="$out/share/applications/com.mitchellh.ghostty.desktop"
    ghostty_dbus_service="$out/share/dbus-1/services/com.mitchellh.ghostty.service"
    for ghostty_entry in "$ghostty_desktop_entry" "$ghostty_dbus_service"; do
      substituteInPlace "$ghostty_entry" \
        --replace-quiet "${pkgs.ghostty}/bin/ghostty" "$out/bin/ghostty" \
        --replace-quiet 'TryExec=ghostty' "TryExec=$out/bin/ghostty" \
        --replace-quiet 'Exec=ghostty' "Exec=$out/bin/ghostty"
    done
    for ghostty_entry in "$ghostty_desktop_entry" "$ghostty_dbus_service"; do
      if ! ${pkgs.gnugrep}/bin/grep -qF "$out/bin/ghostty" "$ghostty_entry"; then
        echo "ghostty-fcitx-workaround: wrapper path missing from $ghostty_entry" >&2
        exit 1
      fi
    done
  '';

  googleChromeWayland = pkgs.google-chrome.override {
    commandLineArgs = [
      "--ozone-platform=wayland"
      "--enable-wayland-ime=true"
    ];
  };

  llamaCppCuda = pkgs.llama-cpp.override {
    cudaSupport = true;
    cudaPackages = pkgs.cudaPackages // {
      flags = pkgs.cudaPackages.flags // {
        cmakeCudaArchitecturesString = "75;89";
      };
    };
  };

  onePasswordMcp = pkgs.stdenv.mkDerivation {
    pname = "1password-mcp";
    version = pkgs._1password-gui.version;

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.glibc
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm555 ${pkgs._1password-gui}/share/1password/1password-mcp \
        $out/bin/1password-mcp
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "1Password Environments MCP server from the 1Password desktop app";
      homepage = "https://www.1password.dev/environments/mcp-codex-server";
      license = licenses.unfree;
      mainProgram = "1password-mcp";
      platforms = platforms.linux;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
in
{
  imports = [
    ../../modules/nixos-common.nix
    ../../modules/desktop/dms.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/niri.nix
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
  users.groups."1password-mcp".gid = 31003;
  security.wrappers."1password-mcp" = {
    source = "${onePasswordMcp}/bin/1password-mcp";
    owner = "root";
    group = "1password-mcp";
    setuid = false;
    setgid = true;
  };
  programs.steam.enable = true;

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
    ghosttyFcitxWorkaround
    googleChromeWayland
    prismlauncher
    jdk # System default Java; keep versioned JDKs below for Prism Launcher instances.
    jdk8
    jdk17
    jdk21
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    llamaCppCuda
    nextcloud-client
    vscode
    zed-editor
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
