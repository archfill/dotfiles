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
    install_mode="${DOTFILES_INSTALL_MODE:-full}"
    log_info "macOS setup starting (mode: $install_mode)"

    # macOS 固有 symlink は home-manager (nix/modules/darwin.nix) で完全に管理。
    # 旧 bin/platform/macos/link.sh は不要になったため削除済み。

    # macOS では nix-darwin + home-manager + homebrew モジュールで全管理。
    # Brew の taps / brews / casks は nix/darwin.nix の宣言で同期される。
    # フォントも home.nix の pkgs.moralerspace 等で配置される。
    if [[ "${SKIP_PACKAGE_INSTALL:-}" != "1" ]]; then
      if command -v darwin-rebuild >/dev/null 2>&1; then
        log_info "Applying nix-darwin configuration..."
        if sudo darwin-rebuild switch --flake "${DOTFILES_DIR}/nix#archfill-to-Mac-mini"; then
          log_success "nix-darwin switch completed"
        else
          log_error "nix-darwin switch failed"
        fi
      else
        log_warning "darwin-rebuild not found"
        log_info "初回セットアップは以下を実行してください:"
        log_info "  sudo nix run nix-darwin -- switch --flake ${DOTFILES_DIR}/nix#archfill-to-Mac-mini"
      fi
    else
      log_info "Skipping package installation (CI environment)"
    fi

    # ghq.root を含む git config は bin/config.sh (全プラットフォーム共通) に統合済み
    ;;

  Linux)
    log_info "Linux setup starting"
    run "bin/platform/linux/packages.sh"
    if [[ "${SKIP_FONT_INSTALL:-0}" != "1" ]]; then
      log_info "Starting font installation..."
      if bash bin/apps/tools/fonts.sh; then
        log_success "Font installation completed successfully"
      else
        log_warning "Font installation failed (continuing with setup)"
      fi
    else
      log_info "Skipping font installation (SKIP_FONT_INSTALL=1)"
    fi
    ;;

  MINGW32_NT*|MINGW64_NT*)
    log_info "Windows (Cygwin) setup starting"
    run "bin/platform/cygwin/install_cygwin.sh"
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
