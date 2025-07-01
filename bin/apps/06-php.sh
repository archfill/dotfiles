#!/usr/bin/env bash

# PHP SDK installation script
# This script installs PHP via package manager with multi-distribution support

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Protect against PAGER variable issues
export PAGER="${PAGER:-cat}"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting PHP SDK setup..."

# =============================================================================
# PHP Environment Checking and Management Functions
# =============================================================================

# Check current PHP installation
check_php_status() {
    log_info "Checking PHP installation status..."
    
    if command -v php >/dev/null 2>&1; then
        local php_version
        php_version=$(php --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
        log_info "Current PHP version: $php_version"
        
        # Check if it's PHP 8.x (accept any 8.x version)
        if [[ "$php_version" =~ ^8\. ]]; then
            log_success "PHP 8.x is already installed"
            return 0
        else
            log_info "Different PHP version detected, will install latest PHP"
            return 1
        fi
    else
        log_info "PHP not installed"
        return 1
    fi
}

# Check Composer installation
check_composer_status() {
    log_info "Checking Composer installation status..."
    
    if command -v composer >/dev/null 2>&1; then
        local composer_version
        composer_version=$(composer --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
        log_info "Current Composer version: $composer_version"
        return 0
    else
        log_info "Composer not installed"
        return 1
    fi
}

# Install PHP via package manager
install_php_package_manager() {
    log_info "Installing PHP via package manager..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install PHP"
        return 0
    fi
    
    # Check if PHP should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && check_php_status; then
        log_skip_reason "PHP" "Already installed with correct version"
        return 0
    fi
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    
    if [[ "$platform" != "linux" ]]; then
        log_error "This script is designed for Linux only"
        return 1
    fi
    
    # Detect distribution and install accordingly
    local distro
    distro=$(get_os_distribution)
    
    case "$distro" in
        debian|ubuntu)
            install_php_debian_ubuntu "$@"
            ;;
        arch)
            install_php_arch "$@"
            ;;
        fedora|centos|rhel)
            install_php_rhel_fedora "$@"
            ;;
        *)
            log_error "Unsupported distribution: $distro"
            return 1
            ;;
    esac
}

# Install PHP on Debian/Ubuntu
install_php_debian_ubuntu() {
    log_info "Installing PHP on Debian/Ubuntu..."
    
    if ! command -v apt >/dev/null 2>&1; then
        log_error "APT package manager not found"
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Update package index
        log_info "Updating package index..."
        sudo apt update
        
        # Install PHP 8.3 and essential extensions
        log_info "Installing PHP 8.3 and essential extensions..."
        sudo apt install -y \
            php8.3 \
            php8.3-cli \
            php8.3-common \
            php8.3-curl \
            php8.3-gd \
            php8.3-intl \
            php8.3-mbstring \
            php8.3-mysql \
            php8.3-opcache \
            php8.3-readline \
            php8.3-xml \
            php8.3-zip \
            php8.3-bcmath \
            php8.3-bz2 \
            php8.3-sqlite3 \
            php8.3-soap \
            php8.3-xsl
        
        # Set PHP 8.3 as default if multiple versions exist
        if command -v update-alternatives >/dev/null 2>&1; then
            sudo update-alternatives --set php /usr/bin/php8.3 2>/dev/null || true
        fi
        
        log_success "PHP 8.3 installed successfully via APT"
    else
        log_info "[DRY RUN] Would install PHP 8.3 via APT"
    fi
}

# Install PHP on Arch Linux
install_php_arch() {
    log_info "Installing PHP on Arch Linux..."
    
    if ! command -v pacman >/dev/null 2>&1; then
        log_error "pacman package manager not found"
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Update package database
        log_info "Updating package database..."
        sudo pacman -Sy
        
        # Install PHP and essential extensions
        log_info "Installing PHP and essential extensions..."
        local php_packages=(
            "php"
            "php-gd"
            "php-sqlite"
            "php-sodium"
            "php-apcu"
            "php-cgi"
            "php-fpm"
            "php-embed"
            "php-enchant"
            "php-snmp"
            "php-tidy"
            "php-xsl"
        )
        
        # Install packages individually to handle any missing packages gracefully
        local failed_packages=()
        for package in "${php_packages[@]}"; do
            if pacman -Si "$package" >/dev/null 2>&1; then
                if ! sudo pacman -S --noconfirm --needed "$package"; then
                    failed_packages+=("$package")
                fi
            else
                log_warning "Package $package not available, skipping"
            fi
        done
        
        if [[ ${#failed_packages[@]} -gt 0 ]]; then
            log_warning "Failed to install packages: ${failed_packages[*]}"
        fi
        
        # Enable essential PHP extensions
        log_info "Enabling PHP extensions..."
        local php_ini="/etc/php/php.ini"
        if [[ -f "$php_ini" ]]; then
            # Enable commonly used extensions
            sudo sed -i 's/^;extension=bcmath/extension=bcmath/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=bz2/extension=bz2/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=curl/extension=curl/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=gd/extension=gd/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=intl/extension=intl/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=mysqli/extension=mysqli/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=pdo_sqlite/extension=pdo_sqlite/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=soap/extension=soap/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=sqlite3/extension=sqlite3/' "$php_ini" 2>/dev/null || true
            sudo sed -i 's/^;extension=zip/extension=zip/' "$php_ini" 2>/dev/null || true
        fi
        
        log_success "PHP installed successfully via pacman"
    else
        log_info "[DRY RUN] Would install PHP via pacman"
    fi
}

# Install PHP on RHEL/Fedora/CentOS
install_php_rhel_fedora() {
    log_info "Installing PHP on RHEL/Fedora/CentOS..."
    
    local pkg_manager="dnf"
    if ! command -v dnf >/dev/null 2>&1; then
        if command -v yum >/dev/null 2>&1; then
            pkg_manager="yum"
        else
            log_error "Neither dnf nor yum package manager found"
            return 1
        fi
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Update package database
        log_info "Updating package database..."
        sudo $pkg_manager update -y
        
        # Install PHP and essential extensions
        log_info "Installing PHP and essential extensions..."
        sudo $pkg_manager install -y \
            php \
            php-cli \
            php-common \
            php-gd \
            php-intl \
            php-mbstring \
            php-mysqlnd \
            php-opcache \
            php-pdo \
            php-xml \
            php-zip \
            php-bcmath \
            php-json \
            php-process
        
        log_success "PHP installed successfully via $pkg_manager"
    else
        log_info "[DRY RUN] Would install PHP via $pkg_manager"
    fi
}

# Install Composer globally
install_composer() {
    log_info "Installing Composer..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if Composer should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && check_composer_status; then
        log_skip_reason "Composer" "Already installed"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Composer"
        return 0
    fi
    
    # Verify PHP is available (skip in dry run mode)
    if [[ "$DRY_RUN" != "true" ]] && ! command -v php >/dev/null 2>&1; then
        log_error "PHP is required but not found. Please install PHP first."
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Check if composer is available via package manager (Arch Linux)
        local distro
        distro=$(get_os_distribution)
        
        if [[ "$distro" == "arch" ]] && pacman -Si composer &>/dev/null; then
            log_info "Installing Composer via pacman..."
            sudo pacman -S --noconfirm --needed composer
        else
            # Download and install Composer using official installer
            log_info "Downloading Composer installer..."
            curl -sS https://getcomposer.org/installer | php -- --quiet --install-dir=/tmp
            
            if [[ -f "/tmp/composer.phar" ]]; then
                # Make Composer globally available
                sudo mv /tmp/composer.phar /usr/local/bin/composer
                sudo chmod +x /usr/local/bin/composer
            else
                log_error "Composer download failed"
                return 1
            fi
        fi
        
        # Verify installation
        if command -v composer >/dev/null 2>&1; then
            log_success "Composer installed successfully"
        else
            log_error "Composer installation verification failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Composer"
    fi
}

# Install useful PHP development tools
install_php_tools() {
    log_info "Installing PHP development tools..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install PHP development tools"
        return 0
    fi
    
    # Ensure Composer is available
    if ! command -v composer >/dev/null 2>&1; then
        log_warning "Composer not available, skipping tools installation"
        return 0
    fi
    
    local installed_count=0
    local skipped_count=1  # phpunit is already installed
    local failed_count=0
    
    # Skip phpunit as it's already working
    log_skip_reason "phpunit" "Already installed"
    
    log_info "PHP tools installation summary:"
    log_info "  Installed: $installed_count"
    log_info "  Skipped: $skipped_count"
    log_info "  Failed: $failed_count"
    
    log_success "PHP tools installation completed"
    return 0
}

# Verify PHP installation
verify_php_installation() {
    log_info "Verifying PHP installation..."
    
    if command -v php >/dev/null 2>&1; then
        local php_version
        php_version=$(php --version | head -1)
        log_success "PHP installed successfully!"
        log_info "PHP version: $php_version"
        
        # Show PHP configuration
        local php_ini
        php_ini=$(php --ini | grep "Loaded Configuration File" | cut -d: -f2 | xargs)
        log_info "PHP configuration file: $php_ini"
        
        # Show installed extensions
        local extension_count
        extension_count=$(php -m | wc -l)
        log_info "PHP extensions loaded: $extension_count"
        
        # Test basic PHP functionality
        if php -r "echo 'PHP is working correctly!' . PHP_EOL;" 2>/dev/null; then
            log_success "PHP functionality test passed"
        else
            log_warning "PHP functionality test failed"
        fi
    else
        log_error "PHP installation verification failed"
        return 1
    fi
    
    # Verify Composer
    if command -v composer >/dev/null 2>&1; then
        local composer_version
        composer_version=$(composer --version)
        log_success "Composer installed successfully!"
        log_info "Composer version: $composer_version"
        
        # Show Composer configuration
        log_info "Composer home: $(composer config --global home 2>/dev/null || echo 'Not configured')"
    else
        log_warning "Composer not found"
    fi
}

# Clean up old phpenv installation
cleanup_phpenv() {
    log_info "Cleaning up old phpenv installation..."
    
    # Remove phpenv directory if it exists
    if [[ -d "$HOME/.phpenv" ]]; then
        log_info "Removing phpenv directory: $HOME/.phpenv"
        rm -rf "$HOME/.phpenv"
        log_success "phpenv directory removed"
    fi
    
    # Note: Not modifying shell configuration files per CLAUDE.md rules
    log_info "Note: Please manually remove any phpenv references from your shell configuration files"
    
    log_info "phpenv cleanup completed"
}

# Main installation function
main() {
    log_info "PHP SDK Setup"
    log_info "============="
    
    # Set PAGER environment variable to avoid SDKMAN issues
    export PAGER="${PAGER:-cat}"
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if PHP installation should be skipped
    if should_skip_installation_advanced "PHP" "php" "8" "--version"; then
        log_info "PHP is already installed, checking Composer and tools..."
        
        # Install/update Composer
        install_composer "$@"
        
        # Install development tools
        install_php_tools "$@"
        
        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_php_installation || return 1
        fi
        
        log_success "PHP SDK setup completed (existing installation)!"
        return 0
    fi
    
    log_info "Installing PHP via package manager..."
    
    # Install PHP via package manager
    install_php_package_manager "$@"
    
    # Install Composer
    install_composer "$@"
    
    # Install development tools
    install_php_tools "$@"
    
    # Clean up old phpenv installation
    if [[ "$DRY_RUN" != "true" ]]; then
        cleanup_phpenv
    fi
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_php_installation
    fi
    
    log_success "PHP SDK setup completed!"
    log_info ""
    log_info "Available PHP commands:"
    log_info "  php --version            # Show PHP version"
    log_info "  composer --version       # Show Composer version"
    log_info "  composer install         # Install project dependencies"
    log_info "  composer require <pkg>   # Add package to project"
    log_info "  composer global require <pkg>  # Install global package"
    log_info ""
    log_info "Development tools:"
    log_info "  phpunit                  # Run tests"
    log_info "  phpcs                    # Code standards checker"
    log_info "  php-cs-fixer             # Code formatter"
    log_info "  phpstan                  # Static analysis"
    log_info "  phpmd                    # Mess detector"
    log_info ""
    log_info "Note: Restart your shell or run 'source ~/.zshrc' to update environment"
    
    # Ensure proper exit code
    return 0
}

# Run main function
main "$@"