{ config, pkgs, ... }:

# home-manager の macOS 固有設定。
# nix-darwin システム設定の `nix/darwin.nix` (top-level) とは別物。
# - top-level `nix/darwin.nix` → nix-darwin system モジュール (homebrew 等)
# - 本ファイル                 → home-manager の Darwin 固有 user 設定
{
  home.username = "chill-rf";
  home.homeDirectory = "/Users/chill-rf";

  # system Rubyに依存せず、通常のshellと`flutter doctor`から利用する
  # iOS / Flutter開発ツール。
  home.packages = [
    pkgs.cocoapods
  ];

  # Hammerspoon は login item として /nix の mount 前に起動し得るため、
  # home.file では管理しない。nix/darwin.nix の MJConfigFile で
  # Data volume 上の dotfiles を直接参照させる。

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

  # Codex Desktop を Dock / Finder から起動しても MCP token が見えるよう、
  # 1Password Environment の mounted .env を login session の launchctl
  # environment へ定期投入する。
  home.file."Library/LaunchAgents/com.archfill.codex-env.plist".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/codex/com.archfill.codex-env.plist";
}
