{ pkgs, ... }:

{
  programs.niri.enable = true;

  # Niri integrates X11 applications through xwayland-satellite.
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
