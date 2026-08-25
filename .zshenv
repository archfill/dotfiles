setopt combiningchars
setopt no_global_rcs

# XDG Base Directory Specification
# 未 export だと lazygit など XDG 準拠ツールが ~/Library/Application Support
# を読みにいくため、~/.config/ 配下の設定が反映されない。
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export ZDOTDIR=$HOME/.config/zsh
export ZRCDIR=$ZDOTDIR/zshrc

# Dotfiles directory path for scripts and aliases
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Modern package managers are used instead:
# - uv for Python (replaces pyenv)
# - mise for Node.js and other tools (replaces nvm/volta)

# ===== Performance Library & Helper Functions =====
# Load performance optimization library or define fallback functions
if [[ -f "${ZDOTDIR}/lib/performance.zsh" ]]; then
  source "${ZDOTDIR}/lib/performance.zsh"
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

# ===== Platform-specific Setup (Homebrew, etc.) =====
# Load platform package managers FIRST so that version managers (mise, etc.)
# can override system binaries by being added to PATH later
if [ -f "$ZDOTDIR/zshenv/$(uname)/init.zsh" ]; then
  . "$ZDOTDIR/zshenv/$(uname)/init.zsh"
fi

# ===== Nix Home Manager session and profile =====
# Make Nix-provided commands available to login and non-login zsh shells.
# .zprofile calls this again after macOS path_helper has run.
setup_nix_session() {
  for _hm_dir in "/etc/profiles/per-user/$USER" "$HOME/.nix-profile"; do
    source_if_exists "$_hm_dir/etc/profile.d/hm-session-vars.sh"
  done

  for _nix_bin in \
    "/nix/var/nix/profiles/default/bin" \
    "$HOME/.nix-profile/bin" \
    "/etc/profiles/per-user/$USER/bin"; do
    if [[ -d "$_nix_bin" ]]; then
      path=("$_nix_bin" "${(@)path:#$_nix_bin}")
    fi
  done

  unset _hm_dir _nix_bin
  export PATH
}

setup_nix_session

# ===== mise shims for every shell type =====
# zshenv is loaded by login, interactive, and non-interactive shells. Keep
# mise's project-aware shims ahead of Nix's global Node/pnpm fallback so tools
# declared by a repository mise.toml are resolved consistently in scripts and
# editor/Codex-launched shells as well as in a terminal.
if command_exists mise; then
  eval "$(mise activate zsh --shims)" 2>/dev/null || true
fi

# ===== Basic PATH Setup =====
# Essential directories for user binaries
[[ -d "${HOME}/bin" ]] && add_to_path "${HOME}/bin"
[[ -d "/usr/local/bin" ]] && add_to_path "/usr/local/bin"
[[ -d "${HOME}/.local/bin" ]] && add_to_path "${HOME}/.local/bin"

# ===== Go (mise + workspace) =====
# Go workspace environment variables (mise manages Go binary via sdk.zsh)
# g version manager removed in 2025年12月, migrated to mise
init_env_var "GOPATH" "$HOME/go"
init_env_var "GOBIN" "$GOPATH/bin"

# Add Go workspace bin to PATH (for go install binaries)
add_to_path "$GOBIN"

# ===== Rust (rustup + Cargo) =====
# Rust environment variables (with defaults)
init_env_var "RUSTUP_HOME" "$HOME/.rustup"
init_env_var "CARGO_HOME" "$HOME/.cargo"

# Source Rust environment if available
source_if_exists "$CARGO_HOME/env"

# Add Cargo bin to PATH
add_to_path "$CARGO_HOME/bin"

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
    export ANDROID_SDK_ROOT="$android_home"
    return 0
  fi
  return 1
}

# Try different Android SDK locations
setup_android_sdk "$HOME/Library/Android/sdk" || \
setup_android_sdk "$HOME/AndroidTools" || \
setup_android_sdk "$HOME/Android/Sdk"  # Common Linux location

# ===== Local Overrides =====
if [ -f "$HOME/zshenv_local.zsh" ]; then . "$HOME/zshenv_local.zsh"; fi
