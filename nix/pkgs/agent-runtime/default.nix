{ pkgs, agentPackages }:

# Mac mini の開発 executor は sh / subprocess からも CLI を呼ぶ。
# 認証・誤更新防止は Zsh 関数ではなく executable の入口で実施する。
let
  pi = if pkgs.stdenv.hostPlatform.isDarwin then
    pkgs.writeShellScriptBin "pi" ''
      # 配備 smoke test / CLI discovery は認証もユーザー設定も不要。
      if [[ $# -eq 1 && ( "$1" == --version || "$1" == --help ) ]]; then
        exec ${agentPackages.pi}/bin/pi "$@"
      fi
      exec ${pkgs.python313}/bin/python3 \
        "''${DOTFILES_DIR:-$HOME/dotfiles}/bin/agent-auth.py" \
        auto -- ${agentPackages.pi}/bin/pi "$@"
    ''
  else agentPackages.pi;
  claude = pkgs.writeShellScriptBin "claude" ''
    case "''${1:-}" in
      update|install)
        echo 'Claude is managed by dotfiles. In ~/dotfiles run: make claude-update agent-prepare' >&2
        echo 'Review the candidate, then use: make agent-apply STORE_PATH=<candidate>' >&2
        exit 2
        ;;
    esac
    exec ${agentPackages.claude-code}/bin/claude "$@"
  '';
in
pkgs.buildEnv {
  name = "agent-runtime";
  paths = [
    claude
    agentPackages.codex
    pi
    agentPackages.devin
    # The X Subscription 付帯の agent CLI 陣。いずれも自前 pin で stable 最新追従。
    agentPackages.grok-build
    agentPackages.cursor-agent
    agentPackages.origin
  ] ++ (with pkgs; [
    git agentPackages.gh openssh bash coreutils findutils gnugrep
    ripgrep fd jq gnumake tmux nodejs_24 python313 bun uv pnpm
  ]);
  pathsToLink = [ "/bin" ];
  # Marker for shell setup and an explicit raw entry point for diagnostics.
  postBuild = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/libexec
    ln -s ${agentPackages.pi}/bin/pi $out/libexec/pi
  '';
}
