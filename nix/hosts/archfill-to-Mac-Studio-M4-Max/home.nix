{ config, pkgs, ... }:

let
  asimov = pkgs.callPackage ../../pkgs/asimov { };
in

# archfill-to-Mac-Studio-M4-Max の home-manager エントリ。
# home.username / home.homeDirectory は nix-darwin の users.users から
# home-manager が自動設定する (flake.nix の mkDarwinHost で宣言)。
{
  imports = [
    ../../modules/common.nix
    ../../modules/home-darwin.nix
  ];

  home.packages = [
    # Time Machine から外付けの git リポジトリ内のビルド成果物
    # (node_modules / target / .venv 等) を除外する。
    asimov
  ];

  xdg.configFile."asimov/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/asimov/config";

  # upstream の com.stevegrunwell.asimov と衝突しない Label で 24h ごとに実行する。
  # mdfind / tmutil / BSD stat 等の macOS 標準コマンドを使うため PATH を明示する
  # (パッケージ側は `asimov doctor` の誤検知を避けるため wrapProgram で包まない)。
  launchd.agents."asimov" = {
    enable = true;
    config = {
      Label = "com.archfill.asimov";
      ProgramArguments = [
        "${asimov}/bin/asimov"
        "--quiet"
      ];
      EnvironmentVariables = {
        PATH = "/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      StartInterval = 86400;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/asimov.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/asimov.err.log";
    };
  };
}
