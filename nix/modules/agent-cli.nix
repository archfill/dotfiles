{ lib, ... }:

{
  # 専用機ではシステム反映から独立した管理側 profile で配備する。
  options.dotfiles.managedAgentCli.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install agent CLIs (Claude Code, Codex, Grok Build, Cursor CLI, Origin, Pi, Devin) through Home Manager";
  };
}
