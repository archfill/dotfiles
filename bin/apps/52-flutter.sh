#!/usr/bin/env bash

# Flutter installation script
# This script installs Flutter SDK and FVM (Flutter Version Management)

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Flutter setup..."

# =============================================================================
# Enhanced Flutter Environment Checking and Management Functions
# =============================================================================

# Check Flutter installation and environment
check_flutter_environment() {
    log_info "Checking Flutter environment..."
    
    local all_checks_passed=true
    
    # Check Flutter command availability
    if ! command -v flutter >/dev/null 2>&1; then
        log_info "Flutter not available"
        all_checks_passed=false
    else
        # Check Flutter version and status
        local flutter_version
        flutter_version=$(flutter --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "Flutter version: $flutter_version"
        
        # Check Flutter doctor status (quick check)
        if flutter doctor >/dev/null 2>&1; then
            log_info "Flutter doctor check passed"
        else
            log_warning "Flutter doctor found issues (this may be normal)"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Flutter environment checks passed"
        return 0
    else
        log_info "Flutter environment checks failed"
        return 1
    fi
}

# Check FVM (Flutter Version Management) status
check_fvm_environment() {
    log_info "Checking FVM environment..."
    
    # Check FVM command availability
    if ! command -v fvm >/dev/null 2>&1; then
        log_info "FVM not available"
        return 1
    fi
    
    # Check FVM installation directory
    local fvm_dir="$HOME/fvm"
    if [[ ! -d "$fvm_dir" ]]; then
        log_warning "FVM directory not found: $fvm_dir"
    else
        log_info "FVM directory: $fvm_dir"
    fi
    
    # Check installed Flutter versions
    local installed_versions
    if installed_versions=$(fvm list 2>/dev/null | grep -c "Flutter" || echo 0); then
        log_info "FVM managed Flutter versions: $installed_versions"
    fi
    
    log_success "FVM environment check completed"
    return 0
}

# Check Dart SDK status
check_dart_environment() {
    log_info "Checking Dart environment..."
    
    if ! command -v dart >/dev/null 2>&1; then
        log_info "Dart SDK not available"
        return 1
    fi
    
    local dart_version
    dart_version=$(dart --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log_info "Dart version: $dart_version"
    
    # Check pub cache directory
    if [[ -d "$HOME/.pub-cache" ]]; then
        log_info "Dart pub cache: $HOME/.pub-cache"
    fi
    
    log_success "Dart environment check completed"
    return 0
}

# Comprehensive Flutter environment check
check_flutter_comprehensive_environment() {
    log_info "Performing comprehensive Flutter environment check..."
    
    local all_checks_passed=true
    
    # Check Flutter installation
    if ! check_flutter_environment; then
        all_checks_passed=false
    fi
    
    # Check FVM status
    check_fvm_environment
    
    # Check Dart status
    check_dart_environment
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All Flutter environment checks passed"
        return 0
    else
        log_info "Some Flutter environment checks failed"
        return 1
    fi
}

# Platform-specific Flutter installation with enhanced options
install_flutter() {
  # Parse command line options
  parse_install_options "$@"
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    macos)
      install_flutter_macos "$@"
      ;;
    linux)
      install_flutter_linux "$@"
      ;;
    *)
      log_error "Unsupported platform: $platform"
      exit 1
      ;;
  esac
}

# Install Flutter on macOS with enhanced options
install_flutter_macos() {
  log_info "Installing Flutter on macOS..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if Flutter is already installed via FVM
  if command -v fvm >/dev/null 2>&1; then
    log_info "FVM detected, using FVM for Flutter management"
    install_flutter_via_fvm "$@"
    return 0
  fi
  
  # Check if Flutter is already installed directly
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v flutter >/dev/null 2>&1; then
    log_skip_reason "Flutter" "Already installed: $(flutter --version | head -1)"
    log_info "Consider using FVM for better version management"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Flutter on macOS"
    return 0
  fi
  
  # Try FVM first, then fall back to Homebrew or manual installation
  if install_fvm_first "$@"; then
    install_flutter_via_fvm "$@"
  elif [[ "$DRY_RUN" != "true" ]] && command -v brew >/dev/null 2>&1; then
    log_info "FVM installation failed, trying Homebrew..."
    brew install --cask flutter
  elif [[ "$DRY_RUN" != "true" ]]; then
    log_info "Neither FVM nor Homebrew available, falling back to manual installation"
    install_flutter_manual_macos "$@"
  else
    log_info "[DRY RUN] Would install Flutter via FVM or Homebrew"
  fi
  
  # Verify installation
  if [[ "$DRY_RUN" != "true" ]]; then
    verify_flutter_installation
  fi
}

# Install Flutter on Linux with enhanced options
install_flutter_linux() {
  log_info "Installing Flutter on Linux..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if Flutter is already installed via FVM
  if command -v fvm >/dev/null 2>&1; then
    log_info "FVM detected, using FVM for Flutter management"
    install_flutter_via_fvm "$@"
    return 0
  fi
  
  # Check if Flutter is already installed directly
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v flutter >/dev/null 2>&1; then
    log_skip_reason "Flutter" "Already installed: $(flutter --version | head -1)"
    log_info "Consider using FVM for better version management"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Flutter on Linux"
    return 0
  fi
  
  # Try FVM first, then fall back to manual installation
  if install_fvm_first "$@"; then
    install_flutter_via_fvm "$@"
  elif [[ "$DRY_RUN" != "true" ]]; then
    log_info "FVM installation failed, falling back to manual Flutter installation"
    install_flutter_manual_linux "$@"
  else
    log_info "[DRY RUN] Would install Flutter via FVM or manual installation"
  fi
  
  # Verify installation
  if [[ "$DRY_RUN" != "true" ]]; then
    verify_flutter_installation
  fi
}

# Manual Flutter installation for macOS with enhanced options
install_flutter_manual_macos() {
  # Parse command line options
  parse_install_options "$@"
  
  local flutter_version="${FLUTTER_VERSION:-stable}"
  local install_dir="$HOME/development"
  local flutter_dir="$install_dir/flutter"
  
  log_info "Installing Flutter manually for macOS..."
  
  # Skip if already installed and not forcing
  if [[ "$FORCE_INSTALL" != "true" ]] && [[ -d "$flutter_dir" ]]; then
    log_skip_reason "Flutter (manual)" "Already installed in $flutter_dir"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Flutter manually for macOS"
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would install Flutter manually to $flutter_dir"
    return 0
  fi
  
  # Create installation directory
  mkdir -p "$install_dir"
  cd "$install_dir"
  
  # Use Flutter's releases.json to get the latest stable version
  log_info "Fetching latest Flutter stable release information..."
  local flutter_releases_json="https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json"
  local flutter_version
  
  # Try to get the latest stable version from Flutter's releases API
  flutter_version=$(curl -s --connect-timeout 10 "$flutter_releases_json" 2>/dev/null | \
    grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null)
  
  if [[ -z "$flutter_version" ]]; then
    # Fallback to a known stable version
    flutter_version="3.24.3"
    log_info "API fetch failed, using fallback version: $flutter_version"
  else
    log_info "Latest Flutter stable version: $flutter_version"
  fi
  
  # Construct download URL based on architecture
  local download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${flutter_version}-stable.zip"
  if [[ "$(uname -m)" == "x86_64" ]]; then
    download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${flutter_version}-stable.zip"
  fi
  
  log_info "Downloading Flutter from: $download_url"
  if ! curl -L -o flutter.zip "$download_url"; then
    log_error "Failed to download Flutter"
    return 1
  fi
  
  # Verify the downloaded file is a valid zip archive
  if ! file flutter.zip | grep -q "Zip archive data"; then
    log_error "Downloaded file is not a valid ZIP archive"
    log_info "File content preview:"
    head -n 5 flutter.zip
    rm -f flutter.zip
    return 1
  fi
  
  # Extract Flutter
  unzip -q flutter.zip
  rm flutter.zip
  
  log_success "Flutter installed to: $flutter_dir"
}

# Manual Flutter installation for Linux with enhanced options
install_flutter_manual_linux() {
  # Parse command line options
  parse_install_options "$@"
  
  local flutter_version="${FLUTTER_VERSION:-stable}"
  local install_dir="$HOME/development"
  local flutter_dir="$install_dir/flutter"
  
  log_info "Installing Flutter manually for Linux..."
  
  # Skip if already installed and not forcing
  if [[ "$FORCE_INSTALL" != "true" ]] && [[ -d "$flutter_dir" ]]; then
    log_skip_reason "Flutter (manual)" "Already installed in $flutter_dir"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Flutter manually for Linux"
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would install Flutter manually to $flutter_dir"
    return 0
  fi
  
  # Create installation directory
  mkdir -p "$install_dir"
  cd "$install_dir"
  
  # Use known stable version to avoid API issues
  log_info "Using known stable Flutter version..."
  local flutter_version="3.24.3"
  
  # Try to get the latest stable version from Flutter's releases API (optional)
  log_info "Attempting to fetch latest version information..."
  local flutter_releases_json="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
  local api_response
  
  # Use timeout to prevent hanging
  if api_response=$(timeout 10 curl -s --connect-timeout 5 "$flutter_releases_json" 2>/dev/null); then
    if [[ -n "$api_response" ]]; then
      # Parse version from API response
      local latest_version
      latest_version=$(echo "$api_response" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null)
      
      if [[ -n "$latest_version" ]]; then
        flutter_version="$latest_version"
        log_info "Latest Flutter stable version: $flutter_version"
      else
        log_info "Using fallback version: $flutter_version"
      fi
    else
      log_info "Empty API response, using fallback version: $flutter_version"
    fi
  else
    log_info "API fetch failed or timed out, using fallback version: $flutter_version"
  fi
  
  # Construct download URL
  local download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz"
  
  log_info "Downloading Flutter from: $download_url"
  if ! curl -L -o flutter.tar.xz "$download_url"; then
    log_error "Failed to download Flutter from: $download_url"
    return 1
  fi
  
  # Check if file was downloaded successfully
  if [[ ! -f flutter.tar.xz ]] || [[ ! -s flutter.tar.xz ]]; then
    log_error "Downloaded file is empty or does not exist"
    rm -f flutter.tar.xz
    return 1
  fi
  
  # Verify the downloaded file is a valid tar archive
  if ! file flutter.tar.xz | grep -q "XZ compressed data"; then
    log_error "Downloaded file is not a valid XZ archive"
    log_info "File content preview:"
    head -n 5 flutter.tar.xz
    rm -f flutter.tar.xz
    return 1
  fi
  
  # Extract Flutter
  log_info "Extracting Flutter archive..."
  if ! tar xf flutter.tar.xz; then
    log_error "Failed to extract Flutter archive"
    rm -f flutter.tar.xz
    return 1
  fi
  
  rm flutter.tar.xz
  
  log_success "Flutter installed to: $flutter_dir"
}

# Install FVM first (before Flutter) with enhanced options
install_fvm_first() {
  log_info "Installing FVM (Flutter Version Management)..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if FVM should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v fvm >/dev/null 2>&1; then
    log_skip_reason "FVM" "Already installed: $(fvm --version 2>/dev/null || echo 'version unknown')"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install FVM (Flutter Version Management)"
    return 0
  fi
  
  # Try to install Dart first if not available
  if ! command -v dart >/dev/null 2>&1; then
    log_info "Installing Dart SDK for FVM..."
    install_dart_sdk "$@"
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Install FVM via pub global
    if command -v dart >/dev/null 2>&1; then
      dart pub global activate fvm
      
      # Add pub cache to PATH for current session
      export PATH="$HOME/.pub-cache/bin:$PATH"
      
      if command -v fvm >/dev/null 2>&1; then
        log_success "FVM installed successfully: $(fvm --version)"
        return 0
      else
        log_warning "FVM installation may have failed"
        return 1
      fi
    else
      log_warning "Dart not available, cannot install FVM"
      return 1
    fi
  else
    log_info "[DRY RUN] Would install FVM (Flutter Version Management)"
    return 0
  fi
}

# Install Flutter via FVM with enhanced options
install_flutter_via_fvm() {
  log_info "Installing Flutter via FVM..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Flutter via FVM"
    return 0
  fi
  
  # Check if Flutter stable is already installed via FVM
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v fvm >/dev/null 2>&1; then
    if fvm list 2>/dev/null | grep -q "stable"; then
      log_skip_reason "Flutter (via FVM)" "Stable version already installed"
      # Ensure it's set as global
      fvm global stable 2>/dev/null || true
      export PATH="$HOME/fvm/default/bin:$PATH"
      return 0
    fi
  fi
  
  # Get latest stable Flutter version from GitHub releases
  local flutter_version
  flutter_version=$(get_latest_flutter_stable_version)
  
  log_info "Installing Flutter $flutter_version via FVM..."
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Install Flutter stable via FVM
    if fvm install stable; then
      log_success "Flutter stable installed via FVM"
      
      # Set global Flutter version
      fvm global stable
      log_info "Set Flutter stable as global version"
      
      # Add FVM Flutter to PATH
      export PATH="$HOME/fvm/default/bin:$PATH"
      
      return 0
    else
      log_error "Failed to install Flutter via FVM"
      return 1
    fi
  else
    log_info "[DRY RUN] Would install Flutter $flutter_version via FVM"
    return 0
  fi
}

# Install Dart SDK with enhanced options
install_dart_sdk() {
  log_info "Installing Dart SDK..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if Dart should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v dart >/dev/null 2>&1; then
    log_skip_reason "Dart SDK" "Already installed: $(dart --version 2>&1 | head -1)"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Dart SDK"
    return 0
  fi
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    linux)
      # Install Dart on Linux
      if command -v apt >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y apt-transport-https
        wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
        echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
        sudo apt update
        sudo apt install -y dart
      elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -S --needed --noconfirm dart
      else
        log_warning "Unsupported package manager for Dart installation"
        return 1
      fi
      ;;
    macos)
      # Install Dart via Homebrew
      if command -v brew >/dev/null 2>&1; then
        brew install dart
      else
        log_warning "Homebrew not available for Dart installation"
        return 1
      fi
      ;;
    *)
      log_warning "Unsupported platform for Dart installation: $platform"
      return 1
      ;;
  esac
  
  if [[ "$DRY_RUN" != "true" ]]; then
    if command -v dart >/dev/null 2>&1; then
      log_success "Dart SDK installed successfully: $(dart --version)"
      return 0
    else
      log_error "Dart SDK installation failed"
      return 1
    fi
  else
    log_info "[DRY RUN] Would install Dart SDK"
    return 0
  fi
}

# Get latest stable Flutter version from GitHub releases
get_latest_flutter_stable_version() {
  log_info "Fetching latest Flutter stable version from GitHub..."
  
  local github_api="https://api.github.com/repos/flutter/flutter/releases"
  local flutter_version
  
  # Get stable releases (not pre-release)
  flutter_version=$(curl -s --connect-timeout 10 "$github_api" 2>/dev/null | \
    grep -A 2 '"prerelease": false' | \
    grep '"tag_name"' | \
    head -1 | \
    cut -d'"' -f4 2>/dev/null)
  
  if [[ -n "$flutter_version" ]]; then
    log_info "Latest stable Flutter version from GitHub: $flutter_version"
    echo "$flutter_version"
  else
    log_info "Failed to fetch from GitHub, using fallback version"
    echo "3.24.3"
  fi
}

# Install FVM (Flutter Version Management) - Legacy function
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

# Setup Flutter development dependencies with enhanced options
setup_flutter_dependencies() {
  log_info "Setting up Flutter development dependencies..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would setup Flutter development dependencies"
    return 0
  fi
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    macos)
      setup_flutter_dependencies_macos "$@"
      ;;
    linux)
      setup_flutter_dependencies_linux "$@"
      ;;
  esac
}

# Setup Flutter dependencies on macOS with enhanced options
setup_flutter_dependencies_macos() {
  log_info "Setting up Flutter dependencies for macOS..."
  
  # Parse command line options
  parse_install_options "$@"
  
  if [[ "$DRY_RUN" != "true" ]]; then
    # Install Xcode Command Line Tools if not installed
    if ! xcode-select -p >/dev/null 2>&1; then
      log_info "Installing Xcode Command Line Tools..."
      xcode-select --install || log_warning "Xcode Command Line Tools installation may have failed"
    else
      log_info "Xcode Command Line Tools already installed"
    fi
    
    # Install CocoaPods if available via Homebrew
    if command -v brew >/dev/null 2>&1; then
      if [[ "$FORCE_INSTALL" != "true" ]] && command -v pod >/dev/null 2>&1; then
        log_skip_reason "CocoaPods" "Already installed: $(pod --version 2>/dev/null || echo 'version unknown')"
      else
        log_info "Installing CocoaPods..."
        brew install cocoapods
      fi
    fi
  else
    log_info "[DRY RUN] Would setup Xcode Command Line Tools and CocoaPods"
  fi
}

# Setup Flutter dependencies on Linux with enhanced options
setup_flutter_dependencies_linux() {
  log_info "Setting up Flutter dependencies for Linux..."
  
  # Parse command line options
  parse_install_options "$@"
  
  if [[ "$DRY_RUN" != "true" ]]; then
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
  else
    log_info "[DRY RUN] Would install Flutter dependencies via package manager"
  fi
}

# Main installation function
main() {
  log_info "Flutter Setup Script"
  log_info "===================="
  
  # Parse command line options
  parse_install_options "$@"
  
  # Get target Flutter version
  local flutter_version="${FLUTTER_VERSION:-stable}"
  
  # Check if Flutter installation should be skipped
  if should_skip_installation_advanced "Flutter" "flutter" "$flutter_version" "--version"; then
    # Even if Flutter is installed, check and update environment
    log_info "Flutter is installed, checking environment and tools..."
    
    # Perform comprehensive environment check
    check_flutter_comprehensive_environment
    
    # Setup/verify environment
    setup_flutter_environment
    
    # Show helpful information
    if [[ "$DRY_RUN" != "true" ]]; then
      show_flutter_info
    fi
    
    return 0
  fi
  
  # Setup dependencies first
  setup_flutter_dependencies "$@"
  
  # Install Flutter (FVM-first approach)
  install_flutter "$@"
  
  # Setup Flutter environment
  setup_flutter_environment
  
  # Show helpful information
  if [[ "$DRY_RUN" != "true" ]]; then
    show_flutter_info
  fi
  
  log_success "Flutter setup completed!"
  log_info ""
  log_info "Available Flutter commands:"
  log_info "  flutter --version       # Show Flutter version"
  log_info "  flutter doctor          # Check Flutter installation"
  log_info "  flutter create <name>   # Create new Flutter project"
  log_info ""
  log_info "Available FVM commands (if installed):"
  log_info "  fvm list                # List installed Flutter versions"
  log_info "  fvm install <version>   # Install specific Flutter version"
  log_info "  fvm use <version>       # Use version for current project"
  log_info "  fvm global <version>    # Set global Flutter version"
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Setup Flutter environment
setup_flutter_environment() {
  log_info "Setting up Flutter environment..."
  
  # Add FVM Flutter to PATH if using FVM
  if command -v fvm >/dev/null 2>&1 && [[ -d "$HOME/fvm/default" ]]; then
    export PATH="$HOME/fvm/default/bin:$PATH"
    log_info "Added FVM Flutter to PATH"
  fi
  
  # Add pub cache to PATH
  if [[ -d "$HOME/.pub-cache/bin" ]]; then
    export PATH="$HOME/.pub-cache/bin:$PATH"
    log_info "Added Dart pub cache to PATH"
  fi
  
  # Setup shell integration
  local shell_rc
  # シェル設定ファイルへの自動PATH追加を無効化
  # ユーザーが手動で設定する必要があります
  log_info "Flutter setup completed. Manual shell configuration required:"
  log_info "  Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
  log_info "    export PATH=\"\$HOME/fvm/default/bin:\$PATH\"      # FVM Flutter"
  log_info "    export PATH=\"\$HOME/.pub-cache/bin:\$PATH\"       # Dart pub cache"
}

# Show Flutter information
show_flutter_info() {
  log_info ""
  log_info "Flutter Setup Information:"
  log_info "========================="
  
  if command -v flutter >/dev/null 2>&1; then
    log_info "Flutter: $(flutter --version | head -1)"
  else
    log_warning "Flutter command not found in PATH"
  fi
  
  if command -v fvm >/dev/null 2>&1; then
    log_info "FVM: $(fvm --version)"
    if fvm list >/dev/null 2>&1; then
      log_info "Installed Flutter versions:"
      fvm list 2>/dev/null | head -5 || log_info "  No versions installed yet"
    fi
  fi
  
  if command -v dart >/dev/null 2>&1; then
    log_info "Dart: $(dart --version)"
  fi
  
  log_info ""
  log_info "Next steps:"
  log_info "  • Restart your shell: source ~/.zshrc (or restart terminal)"
  log_info "  • Run: flutter doctor"
  log_info "  • Install Flutter versions: fvm install 3.24.3"
  log_info "  • Set global version: fvm global 3.24.3"
  log_info "  • Use in project: fvm use 3.24.3"
}

# Run main function
main "$@"