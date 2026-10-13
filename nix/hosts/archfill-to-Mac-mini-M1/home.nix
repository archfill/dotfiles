{ config, ... }:

# archfill-to-Mac-mini-M1 の home-manager エントリ。
# home.username / home.homeDirectory は nix-darwin の users.users から
# home-manager が自動設定する (flake.nix の mkDarwinHost で宣言)。
{
  imports = [
    ../../modules/common.nix
    ../../modules/home-darwin.nix
  ];

  # 同じ archfill ユーザーの独立 profile から配備する。
  # 先に候補を prepare / apply してから移行する。手順: docs/agent-machine.md
  dotfiles.managedAgentCli.enable = false;
  home.sessionPath = [ "/opt/agent-runtime/profile/bin" ];

  # token は login Keychain に保管し、ハーネス起動時の op にだけ渡す。
  # 既存の Desktop 用 codex-env / launchctl 環境は変更しない。
  home.file.".local/bin/agent-auth".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.local/bin/agent-auth";
  xdg.configFile."agent-auth/env.refs.example".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/agent-auth/env.refs.example";
}
