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

  # lazygit は最新バージョン (PR #3989, 2025) で
  # ~/.config/lazygit/config.yml をデフォルトで読むようになったため、
  # common.nix の xdg.configFile."lazygit" のみで完結する。
  # ~/Library/Application Support/lazygit/ は古い既存ファイル
  # (state.yml 等) が残っている場合に lazygit が後方互換で
  # そちらを優先するため、移行時に当該ディレクトリを手動削除すること:
  #   rm -rf ~/Library/Application\ Support/lazygit

  # Karabiner-Elements の profile 本体と complex modifications (AquaSKK + iTerm2 連携)。
  # mkOutOfStoreSymlink で dotfiles のファイルを参照させるため、Karabiner-Elements
  # GUI からの編集はそのまま dotfiles 側に書き込まれる (git diff で履歴管理可能)。
  xdg.configFile."karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/karabiner/karabiner.json";

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
