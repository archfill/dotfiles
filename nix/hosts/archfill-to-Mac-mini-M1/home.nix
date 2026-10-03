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
}
