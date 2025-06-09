#!/usr/bin/env bash

# Flutter installation script
# This script installs Flutter SDK and FVM (Flutter Version Management)

set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Flutter setup..."

# Platform-specific Flutter installation
install_flutter() {
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    macos)
      install_flutter_macos
      ;;
    linux)
      install_flutter_linux
      ;;
    *)
      log_error "Unsupported platform: $platform"
      exit 1
      ;;
  esac
}

# Install Flutter on macOS
install_flutter_macos() {
  log_info "Installing Flutter on macOS..."
  
  # Check if Flutter is already installed
  if command -v flutter >/dev/null 2>&1; then
    log_success "Flutter is already installed: $(flutter --version | head -1)"
    return 0
  fi
  
  # Install Flutter via Homebrew if available
  if command -v brew >/dev/null 2>&1; then
    log_info "Installing Flutter via Homebrew..."
    brew install --cask flutter
  else
    # Manual installation
    install_flutter_manual_macos
  fi
  
  # Verify installation
  verify_flutter_installation
}

# Install Flutter on Linux
install_flutter_linux() {
  log_info "Installing Flutter on Linux..."
  
  # Check if Flutter is already installed
  if command -v flutter >/dev/null 2>&1; then
    log_success "Flutter is already installed: $(flutter --version | head -1)"
    return 0
  fi
  
  # Manual installation for Linux
  install_flutter_manual_linux
  
  # Verify installation
  verify_flutter_installation
}

# Manual Flutter installation for macOS
install_flutter_manual_macos() {
  local flutter_version="${FLUTTER_VERSION:-stable}"
  local install_dir="$HOME/development"
  local flutter_dir="$install_dir/flutter"
  
  log_info "Installing Flutter manually for macOS..."
  
  # Create installation directory
  mkdir -p "$install_dir"
  cd "$install_dir"
  
  # Download Flutter
  local download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${flutter_version}.zip"
  if [[ "$(uname -m)" == "x86_64" ]]; then
    download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${flutter_version}.zip"
  fi
  
  log_info "Downloading Flutter from: $download_url"
  curl -L -o flutter.zip "$download_url"
  
  # Extract Flutter
  unzip -q flutter.zip
  rm flutter.zip
  
  log_success "Flutter installed to: $flutter_dir"
}

# Manual Flutter installation for Linux
install_flutter_manual_linux() {
  local flutter_version="${FLUTTER_VERSION:-stable}"
  local install_dir="$HOME/development"
  local flutter_dir="$install_dir/flutter"
  
  log_info "Installing Flutter manually for Linux..."
  
  # Create installation directory
  mkdir -p "$install_dir"
  cd "$install_dir"
  
  # Download Flutter
  local download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}.tar.xz"
  
  log_info "Downloading Flutter from: $download_url"
  curl -L -o flutter.tar.xz "$download_url"
  
  # Extract Flutter
  tar xf flutter.tar.xz
  rm flutter.tar.xz
  
  log_success "Flutter installed to: $flutter_dir"
}

# Install FVM (Flutter Version Management)
install_fvm() {
  log_info "Installing FVM (Flutter Version Management)..."
  
  # Check if FVM is already installed
  if command -v fvm >/dev/null 2>&1; then
    log_success "FVM is already installed: $(fvm --version)"
    return 0
  fi
  
  # Install FVM via pub global
  if command -v dart >/dev/null 2>&1; then
    dart pub global activate fvm
    log_success "FVM installed via dart pub global"
  else
    log_warning "Dart not available, skipping FVM installation"
    log_info "FVM can be installed later with: dart pub global activate fvm"
  fi
}

# Verify Flutter installation
verify_flutter_installation() {
  log_info "Verifying Flutter installation..."
  
  if command -v flutter >/dev/null 2>&1; then
    log_success "Flutter installed successfully!"
    flutter --version
    
    # Run flutter doctor for diagnostics
    log_info "Running Flutter doctor..."
    flutter doctor || log_warning "Flutter doctor found some issues (this is normal for fresh installation)"
  else
    log_error "Flutter installation verification failed"
    log_info "Please ensure Flutter is in your PATH"
    exit 1
  fi
}

# Setup Flutter development dependencies
setup_flutter_dependencies() {
  log_info "Setting up Flutter development dependencies..."
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    macos)
      setup_flutter_dependencies_macos
      ;;
    linux)
      setup_flutter_dependencies_linux
      ;;
  esac
}

# Setup Flutter dependencies on macOS
setup_flutter_dependencies_macos() {
  log_info "Setting up Flutter dependencies for macOS..."
  
  # Install Xcode Command Line Tools if not installed
  if ! xcode-select -p >/dev/null 2>&1; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install || log_warning "Xcode Command Line Tools installation may have failed"
  fi
  
  # Install CocoaPods if available via Homebrew
  if command -v brew >/dev/null 2>&1; then
    if ! command -v pod >/dev/null 2>&1; then
      log_info "Installing CocoaPods..."
      brew install cocoapods
    fi
  fi
}

# Setup Flutter dependencies on Linux
setup_flutter_dependencies_linux() {
  log_info "Setting up Flutter dependencies for Linux..."
  
  # Install required packages
  local packages=(
    "curl"
    "git"
    "unzip"
    "xz-utils"
    "zip"
    "libglu1-mesa"
  )
  
  local pkg_manager
  pkg_manager=$(detect_package_manager)
  
  case "$pkg_manager" in
    apt)
      log_info "Installing dependencies via apt..."
      sudo apt-get update
      sudo apt-get install -y "${packages[@]}"
      ;;
    yum|dnf)
      log_info "Installing dependencies via $pkg_manager..."
      sudo "$pkg_manager" install -y curl git unzip xz zip mesa-libGLU
      ;;
    pacman)
      log_info "Installing dependencies via pacman..."
      sudo pacman -S --noconfirm curl git unzip xz zip glu
      ;;
    *)
      log_warning "Unknown package manager: $pkg_manager"
      log_info "Please install the following packages manually: ${packages[*]}"
      ;;
  esac
}

# Main installation function
main() {
  log_info "Flutter Setup Script"
  log_info "===================="
  
  # Install Flutter
  install_flutter
  
  # Install FVM
  install_fvm
  
  # Setup dependencies
  setup_flutter_dependencies
  
  log_success "Flutter setup completed!"
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update PATH"
  log_info "Run 'flutter doctor' to check for any additional setup requirements"
}

# Run main function
main "$@"