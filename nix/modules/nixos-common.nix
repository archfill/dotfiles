{ pkgs, ... }:

{
  # Google 公式 CLI は Nixpkgs 上で unfree 扱いのため、対象だけ許可
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.getName pkg == "android-cli"
    || pkgs.lib.getName pkg == "antigravity-cli";

  # HTTP2Shell (CVE-2026-111497): brotli 1.2.0 の decoder に OOB write がある。
  # nixpkgs の修正 (1.2.1) は staging 止まりで、overlay で上げると curl / nix / qtbase
  # 等が全部再ビルドになるため、system closure 内の brotli だけを graft で差し替える。
  # python brotli (USE_SYSTEM_BROTLI) や nodejs_24 (--shared-brotli) もこれで直る。
  # nodejs_22 / nodejs_26 は nixpkgs 側でパッチ済みの別 brotli を使うので対象外。
  # (nixos-unstable の brotli が 1.2.1 以上になったら削除)
  system.replaceDependencies.replacements =
    let
      brotliFixed = pkgs.brotli.overrideAttrs (_: {
        version = "1.2.1";
        src = pkgs.fetchFromGitHub {
          owner = "google";
          repo = "brotli";
          tag = "v1.2.1";
          hash = "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=";
        };
      });
    in
    map (output: {
      oldDependency = pkgs.brotli.${output};
      newDependency = brotliFixed.${output};
    }) [ "out" "lib" ];

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Tokyo";

  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_COLLATE = "ja_JP.UTF-8";
    LC_CTYPE = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MESSAGES = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };
  environment.variables.LANGUAGE = "ja_JP:ja";

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      material-symbols
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Noto Sans CJK JP"
          "Noto Sans"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif CJK JP"
          "Noto Serif"
          "DejaVu Serif"
        ];
        monospace = [
          "Noto Sans Mono CJK JP"
          "DejaVu Sans Mono"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  console.keyMap = "us";

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.displayManager = {
    gdm.enable = true;
  };
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  services.openssh.enable = true;
  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  users.users.archfill = {
    isNormalUser = true;
    description = "archfill";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOaWmcBbwpGLXnlJdKS+YvFUloC96coOgDJGQBmF/lob main@chill-rf.com"
    ];
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "ja" ];
  };
  programs.zsh.enable = true;

  # Allow mise-managed prebuilt binaries (for example Node.js) to run on NixOS.
  programs.nix-ld.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "archfill" ];
  };

  environment.systemPackages = with pkgs; [
    git
    tailscale
    vim
    wget
    curl
  ];
}
