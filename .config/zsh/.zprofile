# ===== IMPORTANT NOTE =====
# Environment variables and PATH settings have been moved to .zshenv
# to ensure they are available in all shell types (login, non-login, interactive, non-interactive).
# This fixes issues with VSCode and other tools that spawn non-login shells.
#
# See:
# - ~/.zshenv (common settings)
# - ~/.config/zsh/zshenv/{Linux,Darwin,WSL}/init.zsh (platform-specific settings)
#
# This file (.zprofile) is now reserved for:
# - Interactive completion setup
# - Time-consuming initialization that should only run once at login
# - Special login-only configurations

# Load performance optimization library if not already loaded
# Note: This should already be loaded from .zshenv, but we check just in case
if ! command -v command_exists &>/dev/null; then
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
    exec_if_command() {
      local cmd="$1"
      shift
      command_exists "$cmd" || return 1
      eval "$@"
    }
  fi
fi

# if [ -f "/usr/local/bin/yaskkserv2_make_dictionary" ] ; then
#   yaskkserv2 --google-japanese-input=notfound --google-suggest --google-cache-filename=$HOME/.config/skk/yaskkserv2.cache $HOME/.config/skk/dictionary.yaskkserv2
# fi

# ===== Volta Completion (Interactive Only) =====
# Completion files should be loaded in .zprofile or .zshrc (interactive shells)
[[ -f ~/.config/zsh/completions/_volta ]] && fpath+=(~/.config/zsh/completions)

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

# ===== Go, Rust, Deno, Bun Environment Setup =====
# MOVED TO: ~/.zshenv
# These environment variables are now set in .zshenv to ensure they are available
# in all shell types (including non-login shells like VSCode terminals)

# ===== Interactive Completions =====
# These should ideally be in .zshrc (for interactive shells only)
# but are kept here for backwards compatibility

# fzf integration - conditional loading
source_if_exists ~/.fzf.zsh

# uv - unified Python package manager completion
if command_exists uv; then
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null || true
fi

# kubectl completion - conditional with error handling
exec_if_command kubectl '[[ "$commands[kubectl]" ]] && source <(kubectl completion zsh)' 2>/dev/null || true

# helm completion - conditional with error handling
exec_if_command helm '[[ "$commands[helm]" ]] && source <(helm completion zsh)' 2>/dev/null || true

# Platform-specific initialization - optimized
source_if_exists "$ZDOTDIR/zprofile/$(uname)/init.zsh"

# vendor_perl PATH - optimized
[[ -f "/usr/bin/vendor_perl/po4a" ]] && add_to_path "/usr/bin/vendor_perl"

# Flutter configuration moved to sdk.zsh to avoid duplication

