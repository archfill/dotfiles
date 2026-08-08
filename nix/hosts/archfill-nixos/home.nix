{ inputs, pkgs, ... }:

let
  caelestiaPackage = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
  # Rovehelm's current Cargo.lock contains git dependencies from several
  # upstream workspaces. Its package expression does not provide the
  # outputHashes required by current nixpkgs, so supply the fixed-output
  # hashes at this integration point until the upstream expression does.
  rovehelmPackage =
    let
      rovehelm = inputs.rovehelm.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    rovehelm.overrideAttrs (_: {
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = "${inputs.rovehelm}/Cargo.lock";
        outputHashes = {
          "collections-0.1.0" = "sha256-HpQm9uTIofI2XTFPe/GG/W3V0ppOlwSXzQHfIdgDxN4=";
          "gpui-component-0.5.2" = "sha256-5ZCa7TNd+s37BZaD+QtmekvSNTbnZprENMv43QtTqqA=";
          "proptest-1.10.0" = "sha256-p5NTcHhruI8QQvANACg8AMRVNmuvGxs2NLit+/8PaWo=";
          "wasm_thread-0.3.3" = "sha256-+lRLCIk0S6Y5ORYjDKsYYHia2FtoSoh+rWkQh7mnPBE=";
          "xim-ctext-0.3.0" = "sha256-pRT4Sz1JU9ros47/7pmIW9kosWOGMOItcnNd+VrvnpE=";
          "zed-font-kit-0.14.1-zed" = "sha256-KXygi0olNQi5yM8eaJVykNDtbPMDjT+cWPBF8UrtXR4=";
          "zed-reqwest-0.12.15-zed" = "sha256-p4SiUrOrbTlk/3bBrzN/mq/t+1Gzy2ot4nso6w6S+F8=";
          "zed-scap-0.0.8-zed" = "sha256-BihiQHlal/eRsktyf0GI3aSWsUCW7WcICMsC2Xvb7kw=";
        };
      };
    });
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

  home.packages = [
    pkgs.opencode
    rovehelmPackage
  ];

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
