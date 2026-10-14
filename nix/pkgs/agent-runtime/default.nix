{ pkgs, agentPackages }:

# 既存ユーザー所有の profile に配備する。Home Manager / darwin switch と独立。
# 同じ closure に基本的な作業ツールも含める。認証・設定は既存 HOME のものを使う。
pkgs.buildEnv {
  name = "agent-runtime";
  paths = [
    agentPackages.claude-code
    agentPackages.codex
    agentPackages.pi
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
}
