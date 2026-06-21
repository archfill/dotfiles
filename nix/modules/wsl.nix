{ config, pkgs, ... }:

let
  win32yank = pkgs.callPackage ../pkgs/win32yank { };
in

# WSL-specific home-manager settings.
#
# Keep Windows-owned state such as C:\Users\<user>\.wslconfig in windows/setup.ps1.
# This module only manages user-level Linux tools and dotfile placement that are
# safe to apply from standalone home-manager.
{
  home.packages = [
    win32yank
  ];

  # Keep the WSL config template available under XDG without generating
  # environment/windows_aliases files. Runtime WSL shell integration lives in
  # .config/zsh/zshenv/WSL and .config/zsh/zprofile/WSL.
  xdg.configFile."wsl/wslconfig.template".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/wsl/wslconfig.template";
}
