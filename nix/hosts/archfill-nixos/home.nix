{ pkgs, ... }:

let
  rovehelmRuntimeLibraries = with pkgs; [
    fontconfig
    freetype
    libxkbcommon
    vulkan-loader
    wayland
    libxcb
  ];

  rovehelmBinary = name: pkgs.writeShellScriptBin name ''
    set -euo pipefail

    data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
    rovehelm_data="''${ROVEHELM_DATA_HOME:-$data_home/rovehelm}"
    current_link="''${ROVEHELM_CURRENT_LINK:-$rovehelm_data/current}"
    binary="$current_link/bin/${name}"

    if [[ ! -x "$binary" ]]; then
      echo "Rovehelm is not installed. Run rovehelm-update first." >&2
      exit 1
    fi

    version_dir="$(${pkgs.coreutils}/bin/readlink -f "$current_link")"
    binary="$version_dir/bin/${name}"
    if [[ ! -x "$binary" ]]; then
      echo "Rovehelm bundle is incomplete: $binary" >&2
      exit 1
    fi

    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath rovehelmRuntimeLibraries}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec "$binary" "$@"
  '';

  rovehelmUpdate = pkgs.writeShellScriptBin "rovehelm-update" ''
    update_script="''${ROVEHELM_UPDATE_SCRIPT:-/home/archfill/dotfiles/bin/rovehelm-update.sh}"
    exec ${pkgs.bash}/bin/bash "$update_script" "$@"
  '';
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";

  home.packages = [
    pkgs.opencode
    rovehelmUpdate
    (rovehelmBinary "rovehelm-launcher")
    (rovehelmBinary "rovehelm")
    (rovehelmBinary "rovehelmd")
    (rovehelmBinary "rovehelm-agent-hook")
    (rovehelmBinary "rovehelm-messaging")
  ];

  gtk = {
    enable = true;

    # GTK 2 cannot use the GTK 3 Adwaita port. Keep its legacy config
    # unmanaged while making GTK 3/4 consistently prefer the dark scheme.
    gtk2.enable = false;

    gtk3 = {
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      colorScheme = "dark";
    };

    gtk4.colorScheme = "dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      font-name = "Noto Sans CJK JP 10";
      document-font-name = "Noto Sans CJK JP 10";
      monospace-font-name = "Noto Sans Mono CJK JP 10";
    };
  };

}
