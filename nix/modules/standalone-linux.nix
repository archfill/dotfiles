{ ... }:

# Standalone home-manager on non-NixOS Linux (Arch / Ubuntu / WSL).
#
# System-level pieces such as kernel, GPU drivers, display managers, Docker
# daemon, and OS services stay with the host distribution. User-level packages,
# dotfile links, shell tooling, editor tooling, and language CLIs are managed
# through nix/modules/common.nix + nix/modules/linux.nix.
{
  targets.genericLinux.enable = true;
}
