#!/usr/bin/env bash

# PHP SDK installation script using phpenv
# This script installs phpenv and PHP 8.3 LTS version

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting PHP SDK setup via phpenv..."

# Install platform-specific PHP build dependencies
install_php_dependencies() {
  log_info "Installing PHP build dependencies..."
  
  local platform
  platform=$(detect_platform)
  
  case "$platform" in
    linux)
      install_linux_php_deps
      ;;
    macos)
      install_macos_php_deps
      ;;
    *)
      log_warning "Platform $platform may not be fully supported"
      ;;
  esac
}

# Install PHP dependencies on Linux
install_linux_php_deps() {
  log_info "Installing Linux PHP build dependencies..."
  
  local distro
  distro=$(get_os_distribution)
  
  case "$distro" in
    debian|ubuntu)
      sudo apt update
      sudo apt install -y \
        build-essential git curl \
        libssl-dev libxml2-dev libcurl4-openssl-dev \
        libpng-dev libjpeg-dev libfreetype6-dev \
        libzip-dev libonig-dev libsqlite3-dev \
        pkg-config autoconf bison re2c \
        libreadline-dev libedit-dev
      ;;
    arch)
      sudo pacman -Syu --needed --noconfirm \
        base-devel git curl \
        openssl libxml2 curl \
        libpng libjpeg-turbo freetype2 \
        libzip oniguruma sqlite \
        pkgconf autoconf bison re2c \
        readline libedit
      ;;
    fedora|centos|rhel)
      sudo yum groupinstall -y "Development Tools"
      sudo yum install -y \
        git curl \
        openssl-devel libxml2-devel libcurl-devel \
        libpng-devel libjpeg-devel freetype-devel \
        libzip-devel oniguruma-devel sqlite-devel \
        pkgconfig autoconf bison re2c \
        readline-devel libedit-devel
      ;;
    *)
      log_warning "Unknown Linux distribution: $distro"
      log_info "Please install PHP build dependencies manually"
      ;;
  esac
}

# Install PHP dependencies on macOS
install_macos_php_deps() {
  log_info "Installing macOS PHP build dependencies..."
  
  # Check if Homebrew is installed
  if ! command -v brew >/dev/null 2>&1; then
    log_error "Homebrew is required but not installed"
    log_info "Please install Homebrew first: https://brew.sh"
    exit 1
  fi
  
  # Install dependencies via Homebrew
  brew install \
    openssl libxml2 curl \
    libpng jpeg freetype \
    libzip oniguruma sqlite \
    pkg-config autoconf bison re2c \
    readline libedit
  
  log_success "macOS PHP dependencies installed"
}

# Install phpenv
install_phpenv() {
  log_info "Installing phpenv..."
  
  # Check if phpenv is already installed
  if command -v phpenv >/dev/null 2>&1; then
    log_success "phpenv is already installed: $(phpenv --version)"
    return 0
  fi
  
  # Install phpenv via git
  local phpenv_dir="$HOME/.phpenv"
  
  if [[ -d "$phpenv_dir" ]]; then
    log_info "phpenv directory exists, updating..."
    cd "$phpenv_dir" && git pull
  else
    log_info "Cloning phpenv..."
    git clone https://github.com/phpenv/phpenv.git "$phpenv_dir"
  fi
  
  # Add phpenv to PATH for current session
  export PATH="$phpenv_dir/bin:$PATH"
  
  # Initialize phpenv
  eval "$(phpenv init -)"
  
  if command -v phpenv >/dev/null 2>&1; then
    log_success "phpenv installed successfully"
  else
    log_error "phpenv installation failed"
    exit 1
  fi
}

# Install php-build plugin
install_php_build() {
  log_info "Installing php-build plugin..."
  
  local php_build_dir="$HOME/.phpenv/plugins/php-build"
  
  if [[ -d "$php_build_dir" ]]; then
    log_info "php-build already exists, updating..."
    cd "$php_build_dir" && git pull
  else
    log_info "Cloning php-build..."
    git clone https://github.com/php-build/php-build.git "$php_build_dir"
  fi
  
  log_success "php-build plugin installed"
}

# Get latest PHP 8.3 version
get_php_version() {
  local php_major_minor="${PHP_VERSION:-8.3}"
  
  log_info "Determining latest PHP $php_major_minor version..."
  
  # Use a known stable version to avoid phpenv list issues
  local fallback_version="8.3.22"
  
  # Try to get available versions if phpenv is available
  if command -v phpenv >/dev/null 2>&1; then
    local latest_version
    latest_version=$(phpenv install --list 2>/dev/null | \
      grep -E "^[[:space:]]*${php_major_minor}\.[0-9]+$" | \
      tail -1 | tr -d '[:space:]' 2>/dev/null || echo "")
    
    if [[ -n "$latest_version" && "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      log_success "Found latest PHP $php_major_minor: $latest_version"
      echo "$latest_version"
      return 0
    fi
  fi
  
  # Use fallback version
  log_success "Found latest PHP $php_major_minor: $fallback_version"
  echo "$fallback_version"
}

# Install specified PHP version
install_php_version() {
  local php_version="$1"
  
  log_info "Installing PHP $php_version..."
  
  # Ensure phpenv is available
  if ! command -v phpenv >/dev/null 2>&1; then
    export PATH="$HOME/.phpenv/bin:$PATH"
    eval "$(phpenv init -)"
  fi
  
  # Check if this version is already installed
  if phpenv versions | grep -q "$php_version"; then
    log_success "PHP $php_version is already installed"
    phpenv global "$php_version"
    return 0
  fi
  
  # Check if definition exists
  if ! phpenv install --list 2>/dev/null | grep -q "^[[:space:]]*$php_version[[:space:]]*$"; then
    log_warning "Definition $php_version not found."
    log_info "Available versions:"
    phpenv install --list 2>/dev/null | head -10
    
    # Try to find an alternative 8.3.x version
    local alternative_version
    alternative_version=$(phpenv install --list 2>/dev/null | \
      grep -E "^[[:space:]]*8\.3\.[0-9]+[[:space:]]*$" | \
      tail -1 | tr -d '[:space:]')
    
    if [[ -n "$alternative_version" ]]; then
      log_info "Trying alternative version: $alternative_version"
      php_version="$alternative_version"
    else
      log_error "No suitable PHP 8.3.x version found"
      return 1
    fi
  fi
  
  # Install PHP version
  log_info "This may take several minutes..."
  if phpenv install "$php_version"; then
    log_success "PHP $php_version installed successfully"
    
    # Set as global version
    phpenv global "$php_version"
    
    # Rehash to update shims
    phpenv rehash
  else
    log_error "PHP $php_version installation failed"
    log_info "Check build dependencies and try again"
    exit 1
  fi
}

# Install Composer (PHP dependency manager)
install_composer() {
  log_info "Installing Composer..."
  
  # Check if Composer is already installed
  if command -v composer >/dev/null 2>&1; then
    log_success "Composer is already installed: $(composer --version)"
    return 0
  fi
  
  # Download and install Composer
  local expected_checksum="$(curl -s https://composer.github.io/installer.sig)"
  curl -s https://getcomposer.org/installer | php -- --quiet
  
  if [[ -f "composer.phar" ]]; then
    # Make Composer globally available
    mkdir -p "$HOME/.local/bin"
    mv composer.phar "$HOME/.local/bin/composer"
    chmod +x "$HOME/.local/bin/composer"
    
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v composer >/dev/null 2>&1; then
      log_success "Composer installed successfully"
    else
      log_warning "Composer installation may have failed"
    fi
  else
    log_error "Composer installation failed"
  fi
}

# Install useful PHP tools
install_php_tools() {
  log_info "Installing useful PHP tools..."
  
  # Ensure PHP and Composer are available
  if ! command -v php >/dev/null 2>&1; then
    export PATH="$HOME/.phpenv/bin:$PATH"
    eval "$(phpenv init -)"
    export PATH="$HOME/.phpenv/shims:$PATH"
  fi
  
  if ! command -v composer >/dev/null 2>&1; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  
  # List of useful PHP tools
  local tools=(
    "phpunit/phpunit"               # Testing framework
    "squizlabs/php_codesniffer"     # Code standards checker
    "friendsofphp/php-cs-fixer"     # Code formatter
    "phpstan/phpstan"               # Static analysis tool
    "psalm/phar"                    # Static analysis tool
  )
  
  for tool in "${tools[@]}"; do
    local tool_name=$(basename "$tool")
    log_info "Installing $tool_name via Composer..."
    composer global require "$tool" --quiet --no-interaction || log_warning "Failed to install $tool"
  done
  
  # Ensure Composer global bin is in PATH
  local composer_bin_dir="$HOME/.composer/vendor/bin"
  if [[ -d "$composer_bin_dir" ]]; then
    export PATH="$composer_bin_dir:$PATH"
  fi
  
  log_success "PHP tools installation completed"
}

# Setup PHP environment
setup_php_environment() {
  log_info "Setting up PHP environment..."
  
  # Add phpenv to PATH and init for current session
  export PATH="$HOME/.phpenv/bin:$PATH"
  eval "$(phpenv init -)"
  
  # Add Composer global bin to PATH
  local composer_bin_dir="$HOME/.composer/vendor/bin"
  if [[ -d "$composer_bin_dir" ]]; then
    export PATH="$composer_bin_dir:$PATH"
  fi
  
  # Set environment variables
  export PHPENV_ROOT="${PHPENV_ROOT:-$HOME/.phpenv}"
  
  log_info "PHPENV_ROOT: $PHPENV_ROOT"
  
  if command -v php >/dev/null 2>&1; then
    log_info "Current PHP: $(php --version | head -1)"
    log_info "PHP location: $(which php)"
    log_info "PHP configuration: $(php --ini | grep 'Loaded Configuration File' | cut -d: -f2 | tr -d ' ')"
  fi
}

# Verify PHP installation
verify_php_installation() {
  log_info "Verifying PHP installation..."
  
  # Setup environment if needed
  setup_php_environment
  
  if command -v php >/dev/null 2>&1; then
    log_success "PHP installed successfully!"
    log_info "PHP version: $(php --version | head -1)"
    
    # Show phpenv info
    if command -v phpenv >/dev/null 2>&1; then
      log_info "phpenv version: $(phpenv --version)"
      log_info "Available PHP versions:"
      phpenv versions
      log_info "Global PHP version: $(phpenv global)"
    fi
    
    # Show Composer info
    if command -v composer >/dev/null 2>&1; then
      log_info "Composer version: $(composer --version)"
      log_info "Composer global packages:"
      composer global show --quiet 2>/dev/null || log_info "No global packages installed"
    fi
    
    # Test basic PHP functionality
    log_info "Testing PHP installation..."
    if php -r "echo 'PHP is working!' . PHP_EOL;" >/dev/null 2>&1; then
      log_success "PHP installation test passed"
    else
      log_warning "PHP installation test failed"
    fi
  else
    log_error "PHP installation verification failed"
    log_info "Please restart your shell and try again"
    exit 1
  fi
}

# Setup PHP development environment
setup_php_development() {
  log_info "Setting up PHP development environment..."
  
  # Create a sample composer.json for testing
  local test_dir="$HOME/tmp/php-test"
  if [[ ! -d "$test_dir" ]]; then
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    cat > composer.json << 'EOF'
{
    "name": "test/php-project",
    "description": "Test PHP project",
    "require": {
        "php": ">=8.3"
    },
    "require-dev": {
        "phpunit/phpunit": "^10.0"
    }
}
EOF
    
    if command -v composer >/dev/null 2>&1; then
      composer install --quiet >/dev/null 2>&1
      if [[ -f "composer.lock" ]]; then
        log_success "Composer working correctly"
        rm -rf "$test_dir"
      fi
    fi
  fi
}

# Main installation function
main() {
  log_info "PHP SDK Setup via phpenv"
  log_info "========================="
  
  # Install platform dependencies
  install_php_dependencies
  
  # Install phpenv
  install_phpenv
  
  # Install php-build plugin
  install_php_build
  
  # Get target PHP version
  local php_version
  php_version=$(get_php_version)
  
  # Validate version format
  if [[ ! "$php_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_warning "Invalid PHP version format: $php_version, using fallback"
    php_version="8.3.22"
  fi
  
  log_info "Target PHP version: $php_version"
  
  # Install PHP version
  install_php_version "$php_version"
  
  # Install Composer
  install_composer
  
  # Setup environment
  setup_php_environment
  
  # Install useful tools
  install_php_tools
  
  # Setup development environment
  setup_php_development
  
  # Verify installation
  verify_php_installation
  
  log_success "PHP SDK setup completed!"
  log_info ""
  log_info "Available phpenv commands:"
  log_info "  phpenv versions          # List installed PHP versions"
  log_info "  phpenv install <version> # Install specific PHP version"
  log_info "  phpenv global <version>  # Set global PHP version"
  log_info "  phpenv local <version>   # Set local PHP version for project"
  log_info "  phpenv which <command>   # Show path to command"
  log_info ""
  log_info "PHP development tools:"
  log_info "  php --version            # Show PHP version"
  log_info "  composer --version       # Show Composer version"
  log_info "  composer install         # Install project dependencies"
  log_info "  phpunit                  # Run tests"
  log_info "  php-cs-fixer             # Code formatter"
  log_info "  phpstan                  # Static analysis"
  log_info ""
  log_info "Environment setup:"
  log_info "  Add to your shell profile (~/.zshrc or ~/.bashrc):"
  log_info "    export PATH=\"\$HOME/.phpenv/bin:\$PATH\""
  log_info "    eval \"\$(phpenv init -)\""
  log_info "    export PATH=\"\$HOME/.composer/vendor/bin:\$PATH\""
  log_info ""
  log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"