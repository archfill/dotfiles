{ inputs, pkgs, ... }:

let
  caelestiaPackage = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
  orcaIdeX11 = pkgs.writeShellScriptBin "orca-ide-x11" ''
    unset NIXOS_OZONE_WL
    exec ${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.orca-ide}/bin/orca-ide \
      --ozone-platform=x11 "$@"
  '';
  patchedCaelestiaPackage = pkgs.runCommand "${caelestiaPackage.name}-active-window-title-patch" { } ''
    mkdir -p "$out"
    cp -a ${caelestiaPackage}/. "$out"/
    chmod -R u+w "$out/share/caelestia-shell/modules/bar/components" "$out/bin"
    cd "$out"
    ${pkgs.patch}/bin/patch -p0 < ${../../patches/caelestia-active-window-title-flicker.patch}

    qs_path="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/.caelestia-shell-wrapped | ${pkgs.gnugrep}/bin/grep -m1 '/bin/qs$')"
    path_prefix="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/.caelestia-shell-wrapped | ${pkgs.gnugrep}/bin/grep -m1 '^/nix/store/.*/bin:')"
    caelestia_lib_dir="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/.caelestia-shell-wrapped | ${pkgs.gnugrep}/bin/grep -m1 '^CAELESTIA_LIB_DIR=' | ${pkgs.coreutils}/bin/cut -d= -f2-)"
    caelestia_xkb_rules_path="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/.caelestia-shell-wrapped | ${pkgs.gnugrep}/bin/grep -m1 '^CAELESTIA_XKB_RULES_PATH=' | ${pkgs.coreutils}/bin/cut -d= -f2-)"
    qt_plugin_path="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/caelestia-shell | ${pkgs.gnugrep}/bin/grep '^/nix/store/.*/lib/qt-6/plugins$' | ${pkgs.coreutils}/bin/paste -sd: -)"
    qml_import_path="$(${pkgs.binutils}/bin/strings ${caelestiaPackage}/bin/caelestia-shell | ${pkgs.gnugrep}/bin/grep '^/nix/store/.*/lib/qt-6/qml$' | ${pkgs.coreutils}/bin/paste -sd: -)"

    cat > "$out/bin/caelestia-shell" <<EOF
#!${pkgs.runtimeShell}
export PATH="$path_prefix:\''${PATH:-}"
export CAELESTIA_LIB_DIR="$caelestia_lib_dir"
export CAELESTIA_XKB_RULES_PATH="$caelestia_xkb_rules_path"
export QT_PLUGIN_PATH="$qt_plugin_path:\''${QT_PLUGIN_PATH:-}"
export NIXPKGS_QT6_QML_IMPORT_PATH="$qml_import_path:\''${NIXPKGS_QT6_QML_IMPORT_PATH:-}"
export XDG_DATA_DIRS="$out/share:${caelestiaPackage}/share:\''${XDG_DATA_DIRS:-}"
exec "$qs_path" -p "$out/share/caelestia-shell" "\$@"
EOF
    chmod +x "$out/bin/caelestia-shell"
  '';
in
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ../../modules/common.nix
    ../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";

  home.packages = [ orcaIdeX11 ];

  xdg.desktopEntries.orca-ide-x11 = {
    name = "Orca IDE (XWayland IME)";
    genericName = "AI coding environment";
    comment = "Launch Orca through XWayland for reliable fcitx5 input";
    exec = "orca-ide-x11";
    icon = "orca-ide";
    terminal = false;
    type = "Application";
    categories = [ "Development" "IDE" ];
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

  programs.caelestia = {
    enable = true;
    package = patchedCaelestiaPackage;
    cli.enable = true;

    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };

  systemd.user.services.caelestia-matugen = {
    Unit = {
      Description = "Regenerate matugen colors from the current Caelestia scheme";
      After = [ "caelestia.service" ];
    };

    Service = {
      Type = "oneshot";
      Environment = "PATH=/run/current-system/sw/bin";
      ExecStart = pkgs.writeShellScript "caelestia-matugen" ''
        set -eu

        scheme_file="''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
        [ -r "$scheme_file" ] || exit 0

        primary="$(${pkgs.jq}/bin/jq -r '.colours.primary // empty' "$scheme_file")"
        [ -n "$primary" ] || exit 0

        ${pkgs.matugen}/bin/matugen color hex "$primary"
      '';
    };
  };

  systemd.user.services.nextcloud-client = {
    Unit = {
      Description = "Nextcloud desktop sync client";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      RestrictRealtime = true;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.paths.caelestia-matugen = {
    Unit = {
      Description = "Watch Caelestia scheme changes for matugen";
      After = [ "caelestia.service" ];
    };

    Path = {
      PathChanged = "%h/.local/state/caelestia/scheme.json";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
