#!/usr/bin/env bash

# Set DOTFILES_DIR if not already set
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="$HOME/dotfiles"
fi

# Load shared libraries
source "$DOTFILES_DIR/bin/lib/common.sh"

# Setup standardized error handling
setup_error_handling

mkdir -p "$HOME/.config"

log_info "Dotfiles setup starting at $(date)"

run() {
  bash "$DOTFILES_DIR/$1"
}

log_info "Starting to create symbolic links"
run "bin/link.sh"

OS_NAME="$(uname)"
log_info "Detected OS: $OS_NAME"

case "$OS_NAME" in
  Darwin)
    local install_mode="${DOTFILES_INSTALL_MODE:-full}"
    log_info "macOS setup starting (mode: $install_mode)"
    run "bin/mac/link.sh"
    
    # Skip package installation in CI environment
    if [[ "${SKIP_PACKAGE_INSTALL:-}" != "1" ]]; then
      log_info "Installing packages with mode: $install_mode"
      DOTFILES_INSTALL_MODE="$install_mode" run "bin/mac/brew.sh"
      
      # Install fonts for essential and full modes
      if [[ "$install_mode" != "minimal" ]]; then
        run "bin/mac/fonts_setup.sh"
      fi
    else
      log_info "Skipping package installation (CI environment)"
    fi
    
    run "bin/mac/config.sh"
    ;;

  Linux)
    log_info "Linux setup starting"
    run "bin/linux/install_linux.sh"
    run "bin/linux/apps/fonts_setup.sh"
    run "bin/linux/apps/deno_install.sh"
    ;;

  MINGW32_NT*|MINGW64_NT*)
    log_info "Windows (Cygwin) setup starting"
    run "bin/cygwin/install_cygwin.sh"
    ;;

  *)
    log_error "Unsupported OS: $OS_NAME"
    exit 1
    ;;
esac

# Skip app setup in CI environment
if [[ "${SKIP_PACKAGE_INSTALL:-}" != "1" ]]; then
  log_info "Starting app setup"
  run "bin/apps_setup.sh"
else
  log_info "Skipping app setup (CI environment)"
fi

log_info "Starting config setup"
run "bin/config.sh"

log_success "Dotfiles setup completed at $(date)"

exit 0
