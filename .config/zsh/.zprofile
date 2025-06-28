# Load performance optimization library
if [[ -f "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh"
else
  # Fallback functions if performance library fails to load
  command_exists() { command -v "$1" &>/dev/null; }
  dir_exists() { [[ -d "$1" ]]; }
  add_to_path() { 
    local new_path="$1"
    local position="${2:-front}"
    [[ -d "$new_path" ]] || return 1
    [[ ":$PATH:" == *":$new_path:"* ]] && return 0
    if [[ "$position" == "back" ]]; then
      export PATH="$PATH:$new_path"
    else
      export PATH="$new_path:$PATH"
    fi
  }
  source_if_exists() { [[ -f "$1" ]] && source "$1"; }
  init_env_var() { [[ -z "${(P)1}" ]] && export "$1"="$2"; }
  setup_path_unified() {
    local -a path_entries=("$@")
    local entry
    for entry in "${path_entries[@]}"; do
      add_to_path "$entry"
    done
  }
  exec_if_command() {
    local cmd="$1"
    shift
    command_exists "$cmd" || return 1
    eval "$@"
  }
fi

# Optimized PATH setup using performance library
setup_path_unified \
  "${HOME}/bin" \
  "/usr/local/bin" \
  "${HOME}/.local/bin"

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

# Node.js version management - optimized with early returns
setup_nodejs_manager() {
  # 1. Volta (preferred) - fast, reliable, cross-platform
  if dir_exists "$HOME/.volta"; then
    init_env_var "VOLTA_HOME" "$HOME/.volta"
    add_to_path "$VOLTA_HOME/bin"
    
    # Add volta completion if available (non-blocking)
    [[ -f ~/.config/zsh/completions/_volta ]] && fpath+=(~/.config/zsh/completions)
    return 0
  fi
  
  # 2. Nodebrew (macOS alternative)
  dir_exists "$HOME/.nodebrew/current/bin" && {
    add_to_path "$HOME/.nodebrew/current/bin"
    return 0
  }
  
  # 3. nvm (legacy fallback - load only if needed)
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  if dir_exists "$nvm_dir"; then
    init_env_var "NVM_DIR" "$nvm_dir"
    source_if_exists "$NVM_DIR/nvm.sh"
    source_if_exists "$NVM_DIR/bash_completion"
    return 0
  fi
  
  return 1
}

# Initialize Node.js version manager (with error handling)
setup_nodejs_manager 2>/dev/null || true

# anyenv removed - using modern tools instead:
# - uv for Python package management
# - volta for Node.js version management

# Google Cloud SDK configuration - optimized with caching
setup_google_cloud_sdk() {
  local gcloud_path="$1"
  
  # Early return if directory doesn't exist
  dir_exists "$gcloud_path" || return 1
  
  # Source configuration files (non-blocking)
  source_if_exists "$gcloud_path/path.zsh.inc"
  source_if_exists "$gcloud_path/completion.zsh.inc"
  return 0
}

# Try different Google Cloud SDK locations (short-circuit evaluation)
setup_google_cloud_sdk "$HOME/google-cloud-sdk" || \
setup_google_cloud_sdk "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" || \
setup_google_cloud_sdk "/snap/google-cloud-sdk/current" || true

# opam configuration - optimized with early return
if dir_exists "${HOME}/.opam"; then
  source_if_exists "${HOME}/.opam/opam-init/init.zsh" >/dev/null 2>&1
  command_exists opam && eval "$(opam env)" 2>/dev/null || true
fi

# ===== Go (g version manager + official) - Environment Setup =====
# Note: Moved from sdk.zsh to ensure environment variables are available
# in both interactive and non-interactive shells (login shells)

# Go environment variables (with defaults)
init_env_var "GOPATH" "$HOME/go"
init_env_var "GOBIN" "$GOPATH/bin"

# Source g environment if available (highest priority for version management)
source_if_exists "$HOME/.g/env"

# Add Go binaries to PATH
add_to_path "$GOBIN"

# Fallback GOROOT detection for manual installations
if [[ -z "${GOROOT:-}" ]]; then
  local go_paths=(
    "$HOME/.local/go"
    "/usr/local/go"
    "/opt/homebrew/opt/go/libexec"
    "/usr/lib/go"
  )
  
  for go_path in "${go_paths[@]}"; do
    if dir_exists "$go_path" && [[ -x "$go_path/bin/go" ]]; then
      init_env_var "GOROOT" "$go_path"
      add_to_path "$GOROOT/bin"
      break
    fi
  done
fi

# ===== Rust (rustup + Cargo) - Environment Setup =====
# Note: Moved from sdk.zsh to ensure environment variables are available
# in both interactive and non-interactive shells (login shells)

# Rust environment variables (with defaults)
init_env_var "RUSTUP_HOME" "$HOME/.rustup"
init_env_var "CARGO_HOME" "$HOME/.cargo"

# Source Rust environment if available
source_if_exists "$CARGO_HOME/env"

# Add Cargo bin to PATH
add_to_path "$CARGO_HOME/bin"

# fzf integration - conditional loading
source_if_exists ~/.fzf.zsh

# uv - unified Python package manager (optimized)
# Note: Cargo bin path is already added above in rust configuration
exec_if_command uv eval "$(uv generate-shell-completion zsh)" 2>/dev/null || true

# kubectl completion - conditional with error handling
exec_if_command kubectl '[[ "$commands[kubectl]" ]] && source <(kubectl completion zsh)' 2>/dev/null || true

# helm completion - conditional with error handling
exec_if_command helm '[[ "$commands[helm]" ]] && source <(helm completion zsh)' 2>/dev/null || true

# Platform-specific initialization - optimized
source_if_exists "$ZDOTDIR/zprofile/$(uname)/init.zsh"

# vendor_perl PATH - optimized
[[ -f "/usr/bin/vendor_perl/po4a" ]] && add_to_path "/usr/bin/vendor_perl"

# Flutter configuration moved to sdk.zsh to avoid duplication

