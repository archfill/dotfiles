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

  # Karabiner-Elements の complex modifications (AquaSKK + iTerm2 連携)。
  # ~/.config/karabiner/karabiner.json (profile 本体) は Karabiner-Elements
  # GUI が自動生成・編集するため Nix 管理しない。
  # 個別の complex modification ルールだけを dotfiles で保持する。
  xdg.configFile."karabiner/assets/complex_modifications/aquaskk_iterm2.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/karabiner/assets/complex_modifications/aquaskk_iterm2.json";

  # JankyBorders (アクティブウィンドウに枠線を描画する macOS ツール)。
  xdg.configFile."borders".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/borders";

  # SketchyBar (macOS のカスタムステータスバー)。
  # lua/ plugins/ sketchybarrc を含む。
  xdg.configFile."sketchybar".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/sketchybar";

  # AeroSpace (タイル型ウィンドウマネージャ)。
  # 設定は ~/.aerospace.toml をホーム直下に置く規約。
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.aerospace.toml";
}
