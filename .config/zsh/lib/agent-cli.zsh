# Shared by SSH command shells, login shells and interactive terminals.
# Keep the managed runtime ahead of ~/.local/bin without moving project tools.
setup_agent_runtime_path() {
  local runtime="${1:-/opt/agent-runtime/profile/bin}"
  [[ -d "$runtime" ]] || return 0
  local entry
  local -a ordered_path=()
  local inserted=0
  for entry in "${path[@]}"; do
    if [[ "$entry" == "$runtime" || "$entry" == "$HOME/.local/bin" ]]; then
      if (( ! inserted )); then
        ordered_path+=("$runtime")
        inserted=1
      fi
      [[ "$entry" == "$runtime" ]] && continue
    fi
    ordered_path+=("$entry")
  done
  (( inserted )) || ordered_path=("$runtime" "${ordered_path[@]}")
  path=("${ordered_path[@]}")
  export PATH
}

setup_agent_runtime_path

# Legacy fallback for hosts without the runtime executable wrappers.
# Mac mini uses the executable entry points even from sh / subprocess.
if [[ ! -e /opt/agent-runtime/profile/libexec/pi && "$OSTYPE" == darwin* && -f "$HOME/.config/agent-auth/env.refs" ]] && (( $+commands[agent-auth] )); then
  function pi() {
    command agent-auth run -- pi "$@"
  }
fi

# Native installation would create a second, unmanaged Claude installation.
if [[ ! -e /opt/agent-runtime/profile/libexec/pi && -x /opt/agent-runtime/profile/bin/claude ]]; then
  function claude() {
    case "${1:-}" in
      update|install)
        print -u2 -- 'Claude is managed by dotfiles. In ~/dotfiles run: make claude-update agent-prepare'
        print -u2 -- 'Review the candidate, then apply it with: make agent-apply STORE_PATH=<candidate>'
        return 2
        ;;
    esac
    /opt/agent-runtime/profile/bin/claude "$@"
  }
fi
