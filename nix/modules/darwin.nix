{ config, ... }:

# home-manager の macOS 固有設定。
# nix-darwin システム設定の `nix/darwin.nix` (top-level) とは別物。
# - top-level `nix/darwin.nix` → nix-darwin system モジュール (homebrew 等)
# - 本ファイル                 → home-manager の Darwin 固有 user 設定
{
  home.username = "chill-rf";
  home.homeDirectory = "/Users/chill-rf";

  # ─── macOS 固有 symlink (mkOutOfStoreSymlink で dotfiles 編集を即反映) ──
  # Hammerspoon (macOS 自動化スクリプト)。~/.hammerspoon/init.lua がエントリ。
  home.file.".hammerspoon".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.hammerspoon";

  # lazygit は macOS では XDG_CONFIG_HOME を尊重せず、
  # ~/Library/Application Support/lazygit/config.yml を読みに行く。
  # ~/.config/lazygit は home-manager (common.nix) で管理済みなので、
  # 同じ dotfiles 実体を Library 側からも symlink で参照させる。
  home.file."Library/Application Support/lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/lazygit/config.yml";
}
