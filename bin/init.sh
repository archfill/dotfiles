#!/usr/bin/env bash

# Set DOTFILES_DIR if not already set
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="$HOME/dotfiles"
fi

# Load shared libraries
source "$DOTFILES_DIR/bin/lib/common.sh"

# Setup standardized error handling
setup_error_handling

run() {
  bash "$DOTFILES_DIR/$1"
}

prepare_common_environment() {
  log_info "Dotfiles setup starting at $(date)"
}

apply_common_configuration() {
  log_info "Starting config setup"
  run "bin/config.sh"
}

resolve_linux_home_attr() {
  local distro
  distro="$(get_os_distribution)"

  if is_wsl; then
    echo "archfill@wsl-ubuntu"
    return 0
  fi

  case "$distro" in
    arch) echo "archfill@arch-desktop" ;;
    ubuntu | debian) echo "archfill@ubuntu-desktop" ;;
    *) echo "" ;;
  esac
}

apply_nix_linux_configuration() {
  if [[ "${SKIP_PACKAGE_INSTALL:-}" == "1" ]]; then
    log_info "Skipping Nix switch (SKIP_PACKAGE_INSTALL=1)"
    return 0
  fi

  if ! command -v nix >/dev/null 2>&1; then
    log_warning "nix command not found"
    log_info "Install Nix first, then run make init again:"
    log_info "  https://nixos.org/download/"
    return 0
  fi

  if [[ -e /etc/NIXOS ]]; then
    log_info "Applying NixOS configuration..."
    if command -v nh >/dev/null 2>&1; then
      nh os switch "${DOTFILES_DIR}/nix"
    elif command -v nixos-rebuild >/dev/null 2>&1; then
      sudo nixos-rebuild switch --flake "${DOTFILES_DIR}/nix"
    else
      log_warning "Neither nh nor nixos-rebuild was found"
      log_info "Run manually after installing nh:"
      log_info "  make nix-rebuild"
    fi
    return 0
  fi

  local attr
  attr="${NIX_ATTR:-$(resolve_linux_home_attr)}"

  if [[ -z "$attr" ]]; then
    log_warning "No standalone home-manager attr is defined for this Linux distribution"
    log_info "Set NIX_ATTR explicitly, for example:"
    log_info "  make init NIX_ATTR='archfill@ubuntu-desktop'"
    return 0
  fi

  local flake_ref
  flake_ref="${DOTFILES_DIR}/nix#${attr}"

  log_info "Applying standalone home-manager configuration: ${attr}"
  if command -v nh >/dev/null 2>&1; then
    nh home switch "$flake_ref"
  elif command -v home-manager >/dev/null 2>&1; then
    home-manager switch --flake "$flake_ref"
  else
    log_info "home-manager command not found; using nix run fallback"
    nix run github:nix-community/home-manager -- switch --flake "$flake_ref"
  fi
}

prepare_common_environment

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
    install_mode="${DOTFILES_INSTALL_MODE:-nix}"
    log_info "Linux setup starting (mode: $install_mode)"

    if [[ "${DOTFILES_LEGACY_INSTALL:-0}" == "1" || "$install_mode" == "legacy" ]]; then
      log_warning "Running legacy Linux base OS package installer"
      run "bin/linux-bootstrap.sh"
    else
      log_info "Using Nix/Home Manager for Linux user environment"
      apply_nix_linux_configuration
    fi
    ;;

  *)
    log_error "Unsupported OS: $OS_NAME"
    exit 1
    ;;
esac

apply_common_configuration

log_success "Dotfiles setup completed at $(date)"

exit 0
