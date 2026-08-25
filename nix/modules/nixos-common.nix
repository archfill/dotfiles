{ pkgs, ... }:

{
  # Google 公式 Android CLI は Nixpkgs 上で unfree 扱いのため、対象だけ許可
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.getName pkg == "android-cli";

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
