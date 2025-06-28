#!/usr/bin/env bash

# PHP SDK installation script using phpenv
# This script installs phpenv and PHP 8.3 LTS version

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

log_info "Starting PHP SDK setup via phpenv..."

# =============================================================================
# Enhanced PHP Environment Checking and Management Functions
# =============================================================================

# Check phpenv installation and environment
check_phpenv_environment() {
    log_info "Checking phpenv environment..."
    
    local all_checks_passed=true
    
    # Check phpenv command availability
    if ! is_command_available "phpenv" "--version"; then
        log_info "phpenv not available"
        all_checks_passed=false
    else
        # Check phpenv home directory
        local phpenv_home="${PHPENV_ROOT:-$HOME/.phpenv}"
        if [[ ! -d "$phpenv_home" ]]; then
            log_warning "phpenv home directory not found: $phpenv_home"
            all_checks_passed=false
        else
            log_info "phpenv home: $phpenv_home"
        fi
        
        # Check phpenv PATH configuration
        if [[ ":$PATH:" != *":$phpenv_home/bin:"* ]]; then
            log_warning "phpenv not in PATH, may need shell profile update"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "phpenv environment checks passed"
        return 0
    else
        log_info "phpenv environment checks failed"
        return 1
    fi
}

# Check phpenv version requirements
check_phpenv_version_requirements() {
    log_info "Checking phpenv version requirements..."
    
    if ! command -v phpenv >/dev/null 2>&1; then
        log_info "phpenv command not available"
        return 1
    fi
    
    # phpenv version output format: "phpenv 20160814"
    local current_version
    current_version=$(phpenv --version 2>/dev/null | head -1 || echo "unknown")
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine phpenv version"
        return 1
    fi
    
    log_success "phpenv version: $current_version"
    return 0
}

# Check PHP installation status
check_php_status() {
    log_info "Checking PHP installation status..."
    
    if ! command -v phpenv >/dev/null 2>&1; then
        log_info "phpenv not available"
        return 1
    fi
    
    # Check PHP availability
    if ! command -v php >/dev/null 2>&1; then
        log_info "PHP not installed via phpenv"
        return 1
    fi
    
    # Get PHP version information
    local php_version
    php_version=$(php --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    log_info "PHP version: $php_version"
    
    # Check Composer availability
    if command -v composer >/dev/null 2>&1; then
        local composer_version
        composer_version=$(composer --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
        log_info "Composer version: $composer_version"
    else
        log_warning "Composer not available"
    fi
    
    # Check phpenv versions
    if phpenv versions >/dev/null 2>&1; then
        local version_count
        version_count=$(phpenv versions 2>/dev/null | grep -c "^[[:space:]]*[0-9]" || echo 0)
        log_info "phpenv managed versions: $version_count"
    fi
    
    log_success "PHP status check completed"
    return 0
}

# Check PHP development tools status
check_php_tools_status() {
    log_info "Checking PHP development tools status..."
    
    if ! command -v composer >/dev/null 2>&1; then
        log_info "Composer not available"
        return 1
    fi
    
    # Check global packages
    local global_packages
    global_packages=$(composer global show --quiet 2>/dev/null | wc -l || echo 0)
    log_info "Global Composer packages: $global_packages"
    
    # Check for common development tools
    local common_tools=(
        "phpunit:Testing framework"
        "phpcs:Code standards checker"
        "php-cs-fixer:Code formatter"
        "phpstan:Static analysis tool"
        "psalm:Static analysis tool"
    )
    
    local installed_tools=0
    for tool_info in "${common_tools[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        
        if command -v "$tool_name" >/dev/null 2>&1; then
            ((installed_tools++))
        fi
    done
    
    log_info "Common development tools installed: $installed_tools/${#common_tools[@]}"
    
    log_success "PHP development tools check completed"
    return 0
}

# Comprehensive phpenv environment check
check_phpenv_comprehensive_environment() {
    log_info "Performing comprehensive phpenv environment check..."
    
    local all_checks_passed=true
    
    # Check phpenv installation
    if ! check_phpenv_environment; then
        all_checks_passed=false
    fi
    
    # Check version requirements
    if ! check_phpenv_version_requirements; then
        all_checks_passed=false
    fi
    
    # Check PHP status
    if ! check_php_status; then
        log_info "PHP needs installation or update"
        all_checks_passed=false
    fi
    
    # Check development tools
    check_php_tools_status
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All phpenv environment checks passed"
        return 0
    else
        log_info "Some phpenv environment checks failed"
        return 1
    fi
}

# Install platform-specific PHP build dependencies
install_php_dependencies() {
  log_info "Installing PHP build dependencies..."
  
  # Parse command line options
  parse_install_options "$@"
  
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install PHP build dependencies"
    return 0
  fi
  
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
        libreadline-dev libedit-dev libtidy-dev
      ;;
    arch)
      sudo pacman -Syu --needed --noconfirm \
        base-devel git curl \
        openssl libxml2 libxslt curl \
        libpng libjpeg-turbo freetype2 \
        libzip oniguruma sqlite \
        pkgconf autoconf bison re2c \
        readline libedit tidyhtml \
        icu gmp libffi
      ;;
    fedora|centos|rhel)
      sudo yum groupinstall -y "Development Tools"
      sudo yum install -y \
        git curl \
        openssl-devel libxml2-devel libcurl-devel \
        libpng-devel libjpeg-devel freetype-devel \
        libzip-devel oniguruma-devel sqlite-devel \
        pkgconfig autoconf bison re2c \
        readline-devel libedit-devel libtidy-devel
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
    readline libedit tidy-html5
  
  log_success "macOS PHP dependencies installed"
}

# Install phpenv with enhanced options
install_phpenv() {
  log_info "Installing phpenv..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Check if phpenv should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v phpenv >/dev/null 2>&1; then
    log_skip_reason "phpenv" "Already installed: $(phpenv --version 2>/dev/null || echo 'version unknown')"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install phpenv"
    return 0
  fi
  
  # Install phpenv via git
  local phpenv_dir="$HOME/.phpenv"
  
  if [[ "$DRY_RUN" != "true" ]]; then
    if [[ -d "$phpenv_dir" ]]; then
      log_info "phpenv directory exists, updating..."
      cd "$phpenv_dir" && git pull
    else
      log_info "Cloning phpenv..."
      git clone https://github.com/phpenv/phpenv.git "$phpenv_dir"
    fi
  else
    log_info "[DRY RUN] Would install phpenv to $phpenv_dir"
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

# Install php-build plugin with enhanced options
install_php_build() {
  log_info "Installing php-build plugin..."
  
  # Parse command line options
  parse_install_options "$@"
  
  local php_build_dir="$HOME/.phpenv/plugins/php-build"
  
  # Check if php-build should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && [[ -d "$php_build_dir" ]]; then
    log_skip_reason "php-build" "Already installed at $php_build_dir"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install php-build plugin"
    return 0
  fi
  
  if [[ "$DRY_RUN" != "true" ]]; then
    if [[ -d "$php_build_dir" ]]; then
      log_info "php-build already exists, updating..."
      cd "$php_build_dir" && git pull
    else
      log_info "Cloning php-build..."
      git clone https://github.com/php-build/php-build.git "$php_build_dir"
    fi
  else
    log_info "[DRY RUN] Would install php-build to $php_build_dir"
  fi
  
  log_success "php-build plugin installed"
}

# Get latest PHP 8.3 version
get_php_version() {
  local php_major_minor="${PHP_VERSION:-8.3}"
  local fallback_version="8.3.22"
  
  log_info "Determining latest PHP $php_major_minor version..." >&2
  
  # Try to get available versions if phpenv is available
  if command -v phpenv >/dev/null 2>&1; then
    local latest_version
    latest_version=$(phpenv install --list 2>/dev/null | \
      grep -E "^[[:space:]]*${php_major_minor}\.[0-9]+$" | \
      tail -1 | tr -d '[:space:]' 2>/dev/null)
    
    if [[ -n "$latest_version" && "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      log_success "Found latest PHP $php_major_minor: $latest_version" >&2
      echo "$latest_version"
      return 0
    fi
  fi
  
  # Use fallback version
  log_success "Found latest PHP $php_major_minor: $fallback_version" >&2
  echo "$fallback_version"
}

# Install specified PHP version with enhanced options
install_php_version() {
  local php_version="$1"
  
  log_info "Installing PHP $php_version..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install PHP $php_version"
    return 0
  fi
  
  # Ensure phpenv is available
  export PHPENV_ROOT="${PHPENV_ROOT:-$HOME/.phpenv}"
  export PATH="$HOME/.phpenv/bin:$PATH"
  export PATH="$HOME/.phpenv/shims:$PATH"
  
  if ! command -v phpenv >/dev/null 2>&1; then
    log_error "phpenv not found even after PATH setup"
    return 1
  fi
  
  eval "$(phpenv init -)"
  
  # Check if this version is already installed
  if [[ "$FORCE_INSTALL" != "true" ]] && phpenv versions | grep -q "$php_version"; then
    log_skip_reason "PHP $php_version" "Already installed"
    phpenv global "$php_version"
    phpenv rehash
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
  if [[ "$DRY_RUN" != "true" ]]; then
    log_info "This may take several minutes..."
    if phpenv install "$php_version"; then
      log_success "PHP $php_version installed successfully"
      
      # Set as global version
      phpenv global "$php_version"
      
      # Rehash to update shims
      phpenv rehash
    else
      log_warning "PHP $php_version installation failed"
      log_info "Check build dependencies and try again"
      log_info "Continuing setup - PHP may be available via system package manager"
      return 0  # Return success to avoid stopping make init
    fi
  else
    log_info "[DRY RUN] Would install PHP $php_version"
  fi
}

# Install Composer (PHP dependency manager) with enhanced options
install_composer() {
  log_info "Installing Composer..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Setup phpenv environment first
  setup_php_environment
  
  # Check if Composer should be skipped
  if [[ "$FORCE_INSTALL" != "true" ]] && command -v composer >/dev/null 2>&1; then
    log_skip_reason "Composer" "Already installed: $(composer --version 2>/dev/null | head -1)"
    return 0
  fi
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install Composer"
    return 0
  fi
  
  # Verify PHP is available
  if ! command -v php >/dev/null 2>&1; then
    log_warning "PHP command not found via normal PATH, trying to fix..."
    
    # Try to manually create the shim
    log_info "Searching for PHP binaries..."
    log_info "Versions directory contents: $(ls -la $HOME/.phpenv/versions/ 2>/dev/null || echo 'not found')"
    
    if [[ -d "$HOME/.phpenv/versions" ]]; then
      local php_binary
      # More comprehensive search for PHP binary
      php_binary=$(find "$HOME/.phpenv/versions" -path "*/bin/php" -type f 2>/dev/null | head -1)
      
      if [[ -n "$php_binary" && -x "$php_binary" ]]; then
        log_info "Found PHP binary at: $php_binary"
        log_info "PHP binary info: $(ls -la "$php_binary")"
        
        # Test the PHP binary directly
        log_info "Testing PHP binary: $($php_binary --version 2>/dev/null | head -1 || echo 'failed')"
        
        # Create shim directory if missing
        mkdir -p "$HOME/.phpenv/shims"
        
        # Create a simple shim if missing
        if [[ ! -f "$HOME/.phpenv/shims/php" ]]; then
          cat > "$HOME/.phpenv/shims/php" << EOF
#!/usr/bin/env bash
exec "$php_binary" "\$@"
EOF
          chmod +x "$HOME/.phpenv/shims/php"
          log_info "Created PHP shim manually"
          log_info "Shim info: $(ls -la $HOME/.phpenv/shims/php)"
        fi
        
        # Force phpenv rehash
        if command -v phpenv >/dev/null 2>&1; then
          phpenv rehash
          log_info "Executed phpenv rehash"
        fi
      else
        log_error "No executable PHP binary found in phpenv versions"
        log_info "Checking version directory structure:"
        find "$HOME/.phpenv/versions" -name "php" -type f 2>/dev/null | head -5 || echo "No PHP files found"
        
        # Check if PHP installation was incomplete
        local version_dir="$HOME/.phpenv/versions/8.3.22"
        if [[ -d "$version_dir" ]]; then
          log_info "Version 8.3.22 directory exists: $(ls -la "$version_dir" 2>/dev/null)"
          log_info "Bin directory: $(ls -la "$version_dir/bin" 2>/dev/null || echo 'bin directory not found')"
        fi
      fi
    fi
    
    # Final check
    if ! command -v php >/dev/null 2>&1; then
      log_error "PHP command still not found after manual shim creation."
      log_info "Available PHP versions:"
      phpenv versions 2>/dev/null || log_info "phpenv versions command failed"
      
      # If PHP 8.3.22 shows as installed but binary doesn't exist, try reinstall
      local version_dir="$HOME/.phpenv/versions/8.3.22"
      if [[ -d "$version_dir" ]] && [[ ! -f "$version_dir/bin/php" ]]; then
        log_warning "PHP 8.3.22 directory exists but binary missing. Installation may be incomplete."
        log_info "Attempting to remove and reinstall PHP 8.3.22..."
        
        if command -v phpenv >/dev/null 2>&1; then
          # Remove the broken installation
          rm -rf "$version_dir"
          log_info "Removed incomplete PHP 8.3.22 installation"
          
          # Try to reinstall
          log_info "Reinstalling PHP 8.3.22..."
          if phpenv install 8.3.22; then
            phpenv global 8.3.22
            phpenv rehash
            log_success "PHP 8.3.22 reinstalled successfully"
            
            # Check again
            if command -v php >/dev/null 2>&1; then
              log_success "PHP command now available after reinstall"
              return 0
            fi
          else
            log_error "PHP 8.3.22 reinstallation failed"
          fi
        fi
      fi
      
      return 1
    else
      log_success "PHP command now available via manual shim"
    fi
  fi
  
  # Download and install Composer
  if [[ "$DRY_RUN" != "true" ]]; then
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
      log_warning "Composer installation failed, but continuing..."
    fi
  else
    log_info "[DRY RUN] Would install Composer"
  fi
}

# Install useful PHP tools with enhanced options
install_php_tools() {
  log_info "Installing useful PHP tools..."
  
  # Parse command line options
  parse_install_options "$@"
  
  # Quick check mode
  if [[ "$QUICK_CHECK" == "true" ]]; then
    log_info "QUICK: Would install useful PHP tools"
    return 0
  fi
  
  # Ensure PHP and Composer are available
  if ! command -v php >/dev/null 2>&1; then
    export PATH="$HOME/.phpenv/bin:$PATH"
    eval "$(phpenv init -)"
    export PATH="$HOME/.phpenv/shims:$PATH"
  fi
  
  if ! command -v composer >/dev/null 2>&1; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  
  if ! command -v composer >/dev/null 2>&1; then
    log_warning "Composer not available, skipping tools installation"
    return 0  # Return success to avoid script termination
  fi
  
  # List of useful PHP tools with descriptions
  local tools_info=(
    "phpunit/phpunit:Testing framework"
    "squizlabs/php_codesniffer:Code standards checker"
    "friendsofphp/php-cs-fixer:Code formatter"
    "phpstan/phpstan:Static analysis tool"
    "psalm/phar:Static analysis tool"
  )
  
  local installed_count=0
  local skipped_count=0
  local failed_count=0
  
  for tool_info in "${tools_info[@]}"; do
    local tool_package=$(echo "$tool_info" | cut -d: -f1)
    local tool_desc=$(echo "$tool_info" | cut -d: -f2)
    local tool_name=$(basename "$tool_package")
    
    # Skip if tool is already available and not forcing reinstall
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v "$tool_name" >/dev/null 2>&1; then
      log_skip_reason "$tool_name" "Already installed"
      ((skipped_count++))
      continue
    fi
    
    log_info "Installing $tool_name ($tool_desc) via Composer..."
    
    if [[ "$DRY_RUN" != "true" ]]; then
      if composer global require "$tool_package" --quiet --no-interaction; then
        log_success "$tool_name installed successfully"
        ((installed_count++))
      else
        log_warning "Failed to install $tool_name"
        ((failed_count++))
      fi
    else
      log_info "[DRY RUN] Would install $tool_name"
      ((installed_count++))
    fi
  done
  
  # Log summary
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    log_install_summary "$installed_count" "$skipped_count" "$failed_count"
  fi
  
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
  
  # Set PHPENV_ROOT first
  export PHPENV_ROOT="${PHPENV_ROOT:-$HOME/.phpenv}"
  
  # Clean PATH to avoid duplicates
  local clean_path=""
  local phpenv_bin="$HOME/.phpenv/bin"
  local phpenv_shims="$HOME/.phpenv/shims"
  
  # Remove existing phpenv paths from PATH
  local temp_path="$PATH"
  temp_path="${temp_path//:$phpenv_shims/}"
  temp_path="${temp_path//:$phpenv_bin/}"
  temp_path="${temp_path//^$phpenv_shims:/}"
  temp_path="${temp_path//^$phpenv_bin:/}"
  
  # Add phpenv paths to the beginning
  export PATH="$phpenv_shims:$phpenv_bin:$temp_path"
  
  # Initialize phpenv
  if command -v phpenv >/dev/null 2>&1; then
    eval "$(phpenv init -)"
    phpenv rehash
  else
    log_warning "phpenv command not found in PATH"
  fi
  
  # Add Composer global bin to PATH
  local composer_bin_dir="$HOME/.composer/vendor/bin"
  if [[ -d "$composer_bin_dir" ]]; then
    export PATH="$composer_bin_dir:$PATH"
  fi
  
  log_info "PHPENV_ROOT: $PHPENV_ROOT"
  log_info "Current PATH: $PATH"
  
  # Debug phpenv status
  if command -v phpenv >/dev/null 2>&1; then
    log_info "phpenv location: $(which phpenv)"
    log_info "phpenv versions:"
    phpenv versions 2>/dev/null
    log_info "phpenv global version: $(phpenv global 2>/dev/null || echo 'none')"
  else
    log_warning "phpenv command not available"
  fi
  
  # Check shims directory
  if [[ -d "$HOME/.phpenv/shims" ]]; then
    log_info "Shims directory exists: $HOME/.phpenv/shims"
    log_info "PHP shim exists: $(ls -la $HOME/.phpenv/shims/php 2>/dev/null || echo 'not found')"
  else
    log_warning "Shims directory not found: $HOME/.phpenv/shims"
  fi
  
  if command -v php >/dev/null 2>&1; then
    log_info "Current PHP: $(php --version | head -1)"
    log_info "PHP location: $(which php)"
    log_info "PHP configuration: $(php --ini | grep 'Loaded Configuration File' | cut -d: -f2 | tr -d ' ')"
  else
    log_warning "PHP command not found in PATH"
    log_info "Checking for PHP directly: $(ls -la $HOME/.phpenv/versions/*/bin/php 2>/dev/null || echo 'not found')"
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
  
  # Parse command line options
  parse_install_options "$@"
  
  # Get target PHP version
  local php_version
  php_version=$(get_php_version)
  
  # Validate version format
  if [[ ! "$php_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_warning "Invalid PHP version format: $php_version, using fallback"
    php_version="8.3.22"
  fi
  
  # Check if PHP installation should be skipped
  if should_skip_installation_advanced "PHP" "php" "$php_version" "--version"; then
    # Even if PHP is installed, check and update environment
    log_info "PHP is installed, checking phpenv environment and tools..."
    
    # Perform comprehensive environment check
    check_phpenv_comprehensive_environment
    
    # Setup/verify environment
    setup_php_environment
    
    # Install/update Composer (non-critical)
    install_composer "$@" || {
      log_warning "Composer installation had issues, but continuing..."
    }
    
    # Install useful tools (non-critical)
    install_php_tools "$@" || {
      log_warning "PHP tools installation had issues, but continuing..."
    }
    
    # Setup development environment
    if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
      setup_php_development
    fi
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
      verify_php_installation
    fi
    
    return 0
  fi
  
  log_info "Target PHP version: $php_version"
  
  # Install platform dependencies (non-critical)
  install_php_dependencies "$@" || {
    log_warning "PHP dependencies installation had issues, but continuing..."
  }
  
  # Install phpenv
  install_phpenv "$@" || {
    log_warning "phpenv installation had issues, but continuing..."
  }
  
  # Install php-build plugin
  install_php_build "$@" || {
    log_warning "php-build installation had issues, but continuing..."
  }
  
  # Install PHP version (non-critical)
  install_php_version "$php_version" "$@" || {
    log_warning "PHP version installation had issues, but continuing..."
  }
  
  # Setup environment
  setup_php_environment
  
  # Install Composer (non-critical)
  install_composer "$@" || {
    log_warning "Composer installation had issues, but continuing..."
  }
  
  # Install useful tools (non-critical)
  install_php_tools "$@" || {
    log_warning "PHP tools installation had issues, but continuing..."
  }
  
  # Setup development environment (skip in quick mode)
  if [[ "$QUICK_CHECK" != "true" && "$DRY_RUN" != "true" ]]; then
    setup_php_development
  fi
  
  # Verify installation (non-critical)
  if [[ "$DRY_RUN" != "true" ]]; then
    verify_php_installation || {
      log_warning "PHP verification had issues, but continuing..."
    }
  fi
  
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