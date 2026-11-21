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
in
{
  imports = [
    ../../modules/nixos-common.nix
    ../../modules/desktop/dms.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/niri.nix
    ./hardware.nix
    ./strata.nix
    ./strata-power.nix
  ];

  # Prefer Niri at login; Hyprland remains available as a fallback session.
  services.displayManager.defaultSession = "niri";

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
  boot.kernelPackages = pkgs.linuxPackages_latest;
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

  # オンボード RTL8111H (r8169) で Wake-on-LAN (magic packet)。
  # BIOS 側で ErP 無効 + PCI-E からの復帰を有効にしておくこと。
  networking.interfaces.enp34s0.wakeOnLan.enable = true;
  # NetworkManager が接続の既定値で WoL を上書きしないよう、全体の既定を magic にする
  networking.networkmanager.connectionConfig."ethernet.wake-on-lan" = "magic";

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

  # SSH で外部から常時使うため、スリープ / ハイバネートを無効化 (mask)
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    "hybrid-sleep".enable = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.udev.extraRules = ''
    # The GSX 1000 reports its main wheel as Volume-Down in both directions.
    ACTION=="add|change", SUBSYSTEM=="input", ATTRS{idVendor}=="1395", ATTRS{idProduct}=="00a0", ENV{ID_INPUT}="0", ENV{ID_INPUT_KEY}="0", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # MSI B450 TOMAHAWK MAX (MS-7C02) のオンボード LED を SuperIO 経由で操作する。
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # 起動時に LED を青にそろえる。サーバーと SMBus を取り合わないよう、サーバーより先に一度だけ流す。
  # 対象はマザーボード・メモリ・GPU だけ（Kraken などほかの機器は触らない）。ケース前面の ARGB は前面ボタンで設定する。
  systemd.services.openrgb-color = {
    description = "Set motherboard, DRAM and GPU LEDs to blue";
    wantedBy = [ "multi-user.target" ];
    before = [ "openrgb.service" ];
    after = [ "systemd-modules-load.service" ];
    path = [
      config.services.hardware.openrgb.package
      pkgs.gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "openrgb-color";
    };
    script = ''
      color=0000FF
      conf=/var/lib/openrgb-color
      args=()
      while IFS= read -r line; do
        idx=''${line%%:*}
        name=''${line#*: }
        case "$name" in
          "ENE DRAM") mode=static ;;
          "MSI B450 TOMAHAWK MAX"* | "MSI GeForce"*) mode=direct ;;
          *) continue ;;
        esac
        args+=(--device "$idx" --mode "$mode" --color "$color")
      done < <(openrgb --noautoconnect --config "$conf" --list-devices | grep -E '^[0-9]+: ')
      if [ ''${#args[@]} -gt 0 ]; then
        openrgb --noautoconnect --config "$conf" "''${args[@]}"
      fi
    '';
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "archfill" ];
  };
  # Same setup as the 1Password installer; replace with the module option once NixOS/nixpkgs#565408 lands.
  users.groups.onepassword-mcp.gid = 31003;
  security.wrappers."1password-mcp" = {
    source = "${pkgs._1password-gui}/share/1password/1password-mcp";
    owner = "root";
    group = "onepassword-mcp";
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
    (callPackage ../../pkgs/brave { }) # nixos-unstable に brave が戻るまでの一時 vendor
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
    ethtool
  ];

  system.stateVersion = "26.05";
}
