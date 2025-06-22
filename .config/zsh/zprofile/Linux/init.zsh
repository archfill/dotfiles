# Load performance library if not available
command -v dir_exists &>/dev/null || {
  dir_exists() { [[ -d "$1" ]]; }
  add_to_path() { [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"; }
  source_if_exists() { [[ -f "$1" ]] && source "$1"; }
  init_env_var() { [[ -z "${(P)1}" ]] && export "$1"="$2"; }
}

# Linuxbrew setup (optimized)
if dir_exists "/home/linuxbrew/.linuxbrew"; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Volta settings moved to shared .zprofile to avoid duplication

# uv configuration moved to shared .zprofile

# VTE integration (optimized)
[[ -n "$TILIX_ID" || -n "$VTE_VERSION" ]] && source_if_exists "/etc/profile.d/vte.sh"

# Deno setup (optimized)
if dir_exists "$HOME/.deno"; then
  init_env_var "DENO_INSTALL" "$HOME/.deno"
  add_to_path "$DENO_INSTALL/bin"
fi

# Snap packages PATH (optimized)
add_to_path "/snap/bin"