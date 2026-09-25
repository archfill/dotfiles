{ config, pkgs, ... }:

# home-manager の macOS 固有設定 (全 macOS ホスト共通)。
# nix-darwin システム設定の `modules/darwin-system.nix` とは別物。
# - modules/darwin-system.nix → nix-darwin system モジュール (homebrew 等)
# - 本ファイル                → home-manager の Darwin 固有 user 設定
# home.username / home.homeDirectory は nix-darwin の users.users から自動設定される。
{
  # system Rubyに依存せず、通常のshellと`flutter doctor`から利用する
  # iOS / Flutter開発ツール。
  home.packages = [
    pkgs.cocoapods
  ];

  # Hammerspoon は login item として /nix の mount 前に起動し得るため、
  # home.file では管理しない。modules/darwin-system.nix の MJConfigFile で
  # Data volume 上の dotfiles を直接参照させる。

  # lazygit は最新バージョン (PR #3989, 2025) で
  # ~/.config/lazygit/config.yml をデフォルトで読むようになったため、
  # common.nix の xdg.configFile."lazygit" のみで完結する。
  # ~/Library/Application Support/lazygit/ は古い既存ファイル
  # (state.yml 等) が残っている場合に lazygit が後方互換で
  # そちらを優先するため、移行時に当該ディレクトリを手動削除すること:
  #   rm -rf ~/Library/Application\ Support/lazygit

  # SSH の共通設定 (1Password SSH agent / OrbStack)。公開リポジトリのため
  # 接続先は含めず、~/.ssh/config.d/private (1Password のセキュアノートが原本) を
  # Include する。既存の ~/.ssh/config (通常ファイル) があると switch が止まるので、
  # 接続先を config.d/private に移してから削除する (bin/doctor.sh が検出する)。
  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.ssh/config";

  # Codex Desktop を Dock / Finder から起動しても MCP token が見えるよう、
  # 1Password Environment の mounted .env を login session の launchctl
  # environment へ定期投入する。
  # plist はホームディレクトリの絶対パスを含むため、ホスト非依存にするよう
  # 静的ファイルの symlink ではなく launchd.agents で生成する。
  launchd.agents."codex-env" = {
    enable = true;
    config = {
      Label = "com.archfill.codex-env";
      ProgramArguments = [
        "${config.home.homeDirectory}/dotfiles/.local/bin/codex-env"
        "set"
      ];
      RunAtLoad = true;
      StartInterval = 300;
      StandardOutPath = "/tmp/codex-env.out.log";
      StandardErrorPath = "/tmp/codex-env.err.log";
    };
  };
}
