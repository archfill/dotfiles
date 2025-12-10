# export FLUTTER_ROOT="${HOME}/develop/flutter"

# ===== macOS-specific Environment Setup =====
# This file is sourced by .zshenv for macOS (Darwin) systems only

# Load helper functions if not already available
command -v dir_exists &>/dev/null || {
  dir_exists() { [[ -d "$1" ]]; }
  add_to_path() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
  }
}

# ===== Homebrew Setup =====
# macOS Homebrew package manager
if [[ -d "/opt/homebrew/bin" ]]; then
  # Apple Silicon (M1/M2/M3)
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -e "/usr/local/bin/brew" ]]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ===== MySQL Client PATH =====
# MySQL client binaries (Homebrew)
if [[ -d "/opt/homebrew/opt/mysql-client/bin" ]]; then
  add_to_path "/opt/homebrew/opt/mysql-client/bin"
fi

# ===== OrbStack (Docker/Container runtime) =====
# Provides docker, docker-compose, kubectl commands
# Note: OrbStack installer adds this to .zprofile by default, but we put it here
# to ensure availability in all shell types (including non-login shells like VSCode)
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh
