{ ... }:

{
  # Use the native nixpkgs module so DMS follows the system's pinned
  # nixpkgs revision and starts with the graphical user session.
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };
}
