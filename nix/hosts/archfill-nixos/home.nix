{ inputs, pkgs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ../../modules/common.nix
    ../../modules/linux.nix
  ];

  home.username = "archfill";
  home.homeDirectory = "/home/archfill";

  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
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
