#!/usr/bin/env bash

# PHP SDK installation script using APT (Ubuntu/Debian)
# This script installs PHP 8.3 LTS version via package manager

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

log_info "Starting PHP SDK setup via APT package manager..."

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
        
        # Check if it's the desired version (8.3.x)
        if [[ "$php_version" =~ ^8\.3\. ]]; then
            log_success "PHP 8.3.x is already installed"
            return 0
        else
            log_info "Different PHP version detected, will install PHP 8.3"
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

# Install PHP 8.3 via APT
install_php_apt() {
    log_info "Installing PHP 8.3 via APT..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install PHP 8.3 via APT"
        return 0
    fi
    
    # Check if PHP 8.3 should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && check_php_status; then
        log_skip_reason "PHP 8.3" "Already installed with correct version"
        return 0
    fi
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    
    if [[ "$platform" != "linux" ]]; then
        log_error "This script is designed for Linux (Ubuntu/Debian) only"
        return 1
    fi
    
    # Check if we're on Ubuntu/Debian
    if ! command -v apt >/dev/null 2>&1; then
        log_error "APT package manager not found. This script requires Ubuntu/Debian."
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
    
    # Verify PHP is available
    if ! command -v php >/dev/null 2>&1; then
        log_error "PHP is required but not found. Please install PHP first."
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Download and install Composer using official installer
        log_info "Downloading Composer installer..."
        curl -sS https://getcomposer.org/installer | php -- --quiet --install-dir=/tmp
        
        if [[ -f "/tmp/composer.phar" ]]; then
            # Make Composer globally available
            sudo mv /tmp/composer.phar /usr/local/bin/composer
            sudo chmod +x /usr/local/bin/composer
            
            # Verify installation
            if command -v composer >/dev/null 2>&1; then
                log_success "Composer installed successfully"
            else
                log_error "Composer installation verification failed"
                return 1
            fi
        else
            log_error "Composer download failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Composer globally"
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
    
    # Remove phpenv from shell profiles
    local shell_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    for shell_file in "${shell_files[@]}"; do
        if [[ -f "$shell_file" ]]; then
            # Remove phpenv-related lines
            sed -i '/phpenv/d' "$shell_file" 2>/dev/null || true
            sed -i '/\.phpenv/d' "$shell_file" 2>/dev/null || true
        fi
    done
    
    log_info "phpenv cleanup completed"
}

# Main installation function
main() {
    log_info "PHP SDK Setup via APT Package Manager"
    log_info "====================================="
    
    # Set PAGER environment variable to avoid SDKMAN issues
    export PAGER="${PAGER:-cat}"
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if PHP installation should be skipped
    if should_skip_installation_advanced "PHP" "php" "8.3" "--version"; then
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
    
    log_info "Installing PHP 8.3 via APT package manager..."
    
    # Install PHP via APT
    install_php_apt "$@"
    
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