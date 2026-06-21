#!/usr/bin/env bash

# Minimal Linux bootstrap for non-NixOS hosts.
#
# This script intentionally installs only the OS-level tools needed before Nix /
# Home Manager can take over. User-space CLI tools, language runtimes, editors,
# fonts, and desktop packages are managed by nix/modules/*.nix.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

setup_error_handling

distro="$(get_os_distribution)"

install_debian_bootstrap_packages() {
  local packages=(
    ca-certificates
    curl
    git
    xz-utils
    zsh
  )

  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Debian/Ubuntu bootstrap packages: ${packages[*]}"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would run: sudo apt update"
    log_info "[DRY RUN] Would install Debian/Ubuntu bootstrap packages: ${packages[*]}"
    return 0
  fi

  sudo apt update
  sudo apt install -y "${packages[@]}"
}

install_arch_bootstrap_packages() {
  local packages=(
    ca-certificates
    curl
    git
    xz
    zsh
  )

  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Arch bootstrap packages: ${packages[*]}"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would install Arch bootstrap packages: ${packages[*]}"
    return 0
  fi

  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

show_nix_next_steps() {
  if command -v nix >/dev/null 2>&1; then
    log_success "Nix is already available"
    log_info "Next step:"
    log_info "  make init"
    return 0
  fi

  log_warning "Nix is not installed yet"
  log_info "Install Nix, then rerun make init so Home Manager can take over."
  log_info "Recommended installer:"
  log_info "  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon"
  log_info ""
  log_info "After opening a new shell:"
  log_info "  make init"
}

main() {
  parse_install_options "$@"

  log_info "Linux bootstrap package installation"
  log_info "===================================="

  case "$distro" in
    debian | ubuntu)
      log_info "Detected Debian/Ubuntu"
      install_debian_bootstrap_packages
      ;;
    arch)
      log_info "Detected Arch Linux"
      install_arch_bootstrap_packages
      ;;
    *)
      log_warning "Unsupported distribution: $distro"
      log_info "Install curl, git, ca-certificates, xz, and zsh with your OS package manager."
      ;;
  esac

  show_nix_next_steps
  log_success "Linux bootstrap completed"
}

main "$@"
