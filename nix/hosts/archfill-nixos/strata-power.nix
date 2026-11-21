{ pkgs, ... }:

# Strata Power (別マシンの Web API) からの状態確認と停止の受け口。
# - ユーザー strata-power は SSH の強制コマンドだけを実行できる（restrict + command + from）
# - 許可するコマンドは status / poweroff のみ。呼び出しは journal に残す
# - sudo は systemctl --no-block poweroff の 1 コマンドだけ NOPASSWD
#
# 公開鍵は Strata Power 側の CT で作った ed25519 の公開鍵。

let
  systemctl = "/run/current-system/sw/bin/systemctl";

  strataPowerCommand = pkgs.writeShellScript "strata-power-command" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.util-linux pkgs.gnugrep ]}:/run/current-system/sw/bin
    cmd="''${SSH_ORIGINAL_COMMAND:-}"
    src="''${SSH_CONNECTION%% *}"

    log() { logger -t strata-power -- "$*"; }

    case "$cmd" in
      status)
        log "status from ''${src:-unknown}"
        echo "== sessions =="
        who || true
        echo "== tmux (archfill) =="
        # tmux は UID ごとのディレクトリにソケットを作る
        tmux_dir="/tmp/tmux-$(id -u archfill)"
        if [ -d "$tmux_dir" ] && [ -n "$(find "$tmux_dir" -maxdepth 1 -type s 2>/dev/null)" ]; then
          echo "tmux: yes"
        else
          echo "tmux: none"
        fi
        echo "== gpu compute apps =="
        if command -v nvidia-smi >/dev/null 2>&1; then
          apps="$(nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null || true)"
          if [ -n "$apps" ]; then
            echo "$apps"
          else
            echo "none"
          fi
        else
          echo "unavailable"
        fi
        ;;
      poweroff)
        log "poweroff from ''${src:-unknown}"
        exec /run/wrappers/bin/sudo -n ${systemctl} --no-block poweroff
        ;;
      *)
        log "rejected command from ''${src:-unknown}"
        echo "strata-power: unsupported command" >&2
        exit 1
        ;;
    esac
  '';
in
{
  users.groups.strata-power = { };

  users.users.strata-power = {
    isSystemUser = true;
    group = "strata-power";
    description = "Strata Power";
    # 強制コマンドの実行には実在のシェルが必要
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      ''restrict,command="${strataPowerCommand}",from="192.168.0.110" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrqV5B5jYQV5RCizQf3+X06wf+vW4/92VtVpa4ays3N strata-power@pve-ct110''
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "strata-power" ];
      commands = [
        {
          command = "${systemctl} --no-block poweroff";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
