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

  # ai-company (Hermes / OpenClaw) のサンドボックスもこの VM で動かす。
  # 自律エージェントのコンテナから見える範囲を絞るため、ホーム全体は VM に共有せず
  # 必要なディレクトリだけを並べる (mounts を書くと既定のホーム共有は置き換わる)。
  # mutableSettings: colima が書き出した colima.yaml にこの差分だけ上書きする。
  services.colima.profiles.default = {
    mutableSettings = true;
    settings = {
      cpu = 2;
      memory = 4;
      # Hermes は sandbox の bind 元に実体パスを使う。~/.hermes-hakua は互換 symlink の
      # ため、そちらを共有すると VM 内で skills 等が空になる (~/git/mac-mini-hermes)。
      mounts = let
        home = config.home.homeDirectory;
        hakua = "${home}/.local/state/ai-company/hermes-home/profiles/hakua";
      in [
        { location = "${home}/agents/hakua"; writable = true; }
        { location = "${home}/agents/ritsuka"; writable = true; }
        { location = "${hakua}/sandboxes"; writable = true; }
        { location = "${hakua}/skills"; writable = false; }
        { location = "${hakua}/cache"; writable = false; }
        { location = "${hakua}/attachments"; writable = true; }
      ];
    };
  };
}
