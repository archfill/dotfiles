setopt combiningchars
setopt no_global_rcs

export ZDOTDIR=$HOME/.config/zsh
export ZRCDIR=$ZDOTDIR/zshrc

# Dotfiles directory path for scripts and aliases
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Modern package managers are used instead:
# - uv for Python (replaces pyenv)
# - volta for Node.js (replaces nvm)

# ===== Performance Library & Helper Functions =====
# Load performance optimization library or define fallback functions
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
fi

# ===== Basic PATH Setup =====
# Essential directories for user binaries
[[ -d "${HOME}/bin" ]] && add_to_path "${HOME}/bin"
[[ -d "/usr/local/bin" ]] && add_to_path "/usr/local/bin"
[[ -d "${HOME}/.local/bin" ]] && add_to_path "${HOME}/.local/bin"

# ===== Node.js Version Management - Volta =====
# Volta (modern unified solution for Node.js)
if dir_exists "$HOME/.volta"; then
  init_env_var "VOLTA_HOME" "$HOME/.volta"
  add_to_path "$VOLTA_HOME/bin"
fi

# ===== Go (g version manager + official) =====
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

# ===== Rust (rustup + Cargo) =====
# Rust environment variables (with defaults)
init_env_var "RUSTUP_HOME" "$HOME/.rustup"
init_env_var "CARGO_HOME" "$HOME/.cargo"

# Source Rust environment if available
source_if_exists "$CARGO_HOME/env"

# Add Cargo bin to PATH
add_to_path "$CARGO_HOME/bin"

# ===== Deno Runtime =====
if dir_exists "$HOME/.deno"; then
  init_env_var "DENO_INSTALL" "$HOME/.deno"
  add_to_path "$DENO_INSTALL/bin"
fi

# ===== Bun Runtime =====
if dir_exists "$HOME/.bun"; then
  init_env_var "BUN_INSTALL" "$HOME/.bun"
  add_to_path "$BUN_INSTALL/bin"
fi

# Android SDK configuration - unified for all platforms
setup_android_sdk() {
  local android_home="$1"
  if [ -d "$android_home" ]; then
    export ANDROID_HOME="$android_home"
    export ANDROID_SDK_ROOT="$ANDROID_HOME/sdk"
    return 0
  fi
  return 1
}

# Try different Android SDK locations
setup_android_sdk "$HOME/AndroidTools" || \
setup_android_sdk "$HOME/Library/Android" || \
setup_android_sdk "$HOME/Android/Sdk"  # Common Linux location

if [ -f "$ZDOTDIR/zshenv/`uname`/init.zsh" ]; then . "$ZDOTDIR/zshenv/`uname`/init.zsh"; fi
if [ -f "$HOME/zshenv_local.zsh" ]; then . "$HOME/zshenv_local.zsh"; fi
. "$HOME/.cargo/env"
