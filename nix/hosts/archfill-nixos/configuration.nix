{ pkgs, config, ... }:

{
  imports = [
    ../../modules/nixos-common.nix
    ../../modules/desktop/hyprland.nix
    ./hardware.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "archfill-nixos";

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
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  systemd.services.nvidia-device-files = {
    description = "Create NVIDIA device files";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    after = [
      "systemd-modules-load.service"
      "systemd-udev-settle.service"
    ];
    path = with pkgs; [
      coreutils
      gawk
      gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      shopt -s nullglob

      nvidia_major="$(grep -m1 ' nvidia$' /proc/devices | awk '{ print $1 }')"
      uvm_major="$(grep -m1 ' nvidia-uvm$' /proc/devices | awk '{ print $1 }')"

      if [ -z "$nvidia_major" ]; then
        exit 0
      fi

      mknod -m 666 /dev/nvidiactl c "$nvidia_major" 255 || true
      mknod -m 666 /dev/nvidia-modeset c "$nvidia_major" 254 || true

      if [ -n "$uvm_major" ]; then
        mknod -m 666 /dev/nvidia-uvm c "$uvm_major" 0 || true
        mknod -m 666 /dev/nvidia-uvm-tools c "$uvm_major" 1 || true
      fi

      minors=()
      for info in /proc/driver/nvidia/gpus/*/information; do
        minor="$(grep -m1 '^Device Minor:' "$info" | cut -d: -f2 | tr -d '[:space:]')"
        if [ -n "$minor" ]; then
          minors+=("$minor")
        fi
      done

      if [ "''${#minors[@]}" -eq 0 ]; then
        exit 0
      fi

      for minor in "''${minors[@]}"; do
        mknod -m 666 "/dev/nvidia$minor" c "$nvidia_major" "$minor" || true
      done
    '';
  };

  environment.systemPackages = with pkgs; [
    ghostty
    nvidia-modprobe
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
