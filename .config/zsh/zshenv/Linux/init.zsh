export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
# export LANG=ja_JP.UTF-8

# ===== Linux-specific Environment Setup =====
# This file is sourced by .zshenv for Linux systems only

# Load helper functions if not already available
command -v command_exists &>/dev/null || {
  command_exists() { command -v "$1" &>/dev/null; }
  dir_exists() { [[ -d "$1" ]]; }
  add_to_path() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
  }
  source_if_exists() { [[ -f "$1" ]] && source "$1"; }
  init_env_var() { [[ -z "${(P)1}" ]] && export "$1"="$2"; }
}

# ===== Linuxbrew Setup =====
# Linuxbrew package manager for Linux
if dir_exists "/home/linuxbrew/.linuxbrew"; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ===== Snap Packages PATH =====
# Snap package manager binaries
add_to_path "/snap/bin"

# ===== VTE Integration =====
# Terminal emulator integration (for Tilix, GNOME Terminal, etc.)
[[ -n "$TILIX_ID" || -n "$VTE_VERSION" ]] && source_if_exists "/etc/profile.d/vte.sh"

# ===== Fcitx5 Input Method =====
# Japanese input method with Mozc (only if fcitx5 is installed)
if command_exists fcitx5; then
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS=@im=fcitx
fi
