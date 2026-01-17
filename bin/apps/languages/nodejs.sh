#!/usr/bin/env bash

# mise (Node.js version manager) - Node.js management script
# This script ensures Node.js is installed and managed by mise

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# Setup error handling
setup_error_handling

# Load configuration
load_config

log_info "Starting Node.js setup via mise..."

# =============================================================================
# mise Node.js Management Functions
# =============================================================================

# Check mise installation
check_mise_environment() {
    log_info "Checking mise environment..."

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise is not installed. Please install mise first."
        log_info "  macOS: brew install mise"
        log_info "  Linux: curl https://mise.run | sh"
        return 1
    fi

    local mise_version
    mise_version=$(mise --version 2>/dev/null | head -1)
    log_info "mise version: $mise_version"

    log_success "mise environment check passed"
    return 0
}

# Check Node.js installation status via mise
check_nodejs_status() {
    log_info "Checking Node.js installation status..."

    if ! command -v mise >/dev/null 2>&1; then
        log_info "mise not available"
        return 1
    fi

    # Check if Node.js is managed by mise
    if mise list node 2>/dev/null | grep -q "node"; then
        local node_version
        node_version=$(node --version 2>/dev/null || echo "unknown")
        log_info "Node.js version (mise): $node_version"

        if command -v npm >/dev/null 2>&1; then
            local npm_version
            npm_version=$(npm --version 2>/dev/null || echo "unknown")
            log_info "npm version: $npm_version"
        fi

        log_success "Node.js is managed by mise"
        return 0
    else
        log_info "Node.js not installed via mise"
        return 1
    fi
}

# Install Node.js LTS via mise
install_nodejs_via_mise() {
    log_info "Installing Node.js LTS via mise..."

    # Parse command line options
    parse_install_options "$@"

    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Node.js LTS via mise"
        return 0
    fi

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise not available, cannot install Node.js"
        return 1
    fi

    # Check if already installed
    if check_nodejs_status && [[ "$FORCE_INSTALL" != "true" ]]; then
        log_skip_reason "Node.js" "Already installed via mise"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install Node.js LTS globally
        local target_version="${NODE_VERSION:-lts}"
        log_info "Installing Node.js $target_version..."

        if mise use -g "node@$target_version"; then
            log_success "Node.js $target_version installed successfully"
        else
            log_error "Failed to install Node.js"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Node.js LTS via mise"
    fi

    return 0
}

# Install essential npm packages globally
install_essential_packages() {
    log_info "Installing essential npm packages..."

    # Parse command line options
    parse_install_options "$@"

    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install essential npm packages"
        return 0
    fi

    if ! command -v npm >/dev/null 2>&1; then
        log_warning "npm not available, skipping package installation"
        return 0
    fi

    # Essential packages for development
    local packages=(
        "pnpm"           # Fast package manager
        "yarn"           # Alternative package manager
        "neovim"         # Neovim Node.js provider
        "typescript"     # TypeScript compiler
    )

    local installed_count=0
    local skipped_count=0

    for package in "${packages[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            log_skip_reason "$package" "Already installed"
            skipped_count=$((skipped_count + 1))
        else
            if [[ "$DRY_RUN" != "true" ]]; then
                log_info "Installing $package..."
                if npm install -g "$package" 2>/dev/null; then
                    log_success "$package installed"
                    installed_count=$((installed_count + 1))
                else
                    log_warning "Failed to install $package"
                fi
            else
                log_info "[DRY RUN] Would install $package"
                installed_count=$((installed_count + 1))
            fi
        fi
    done

    log_info "Packages summary: $installed_count installed, $skipped_count skipped"
    return 0
}

# Main installation function
main() {
    log_info "Node.js Setup via mise"
    log_info "======================"

    # Parse command line options
    parse_install_options "$@"

    # Check mise environment
    if ! check_mise_environment; then
        log_error "mise environment check failed"
        exit 1
    fi

    # Check if Node.js should be skipped
    if should_skip_installation_advanced "Node.js" "node" "" "--version"; then
        log_info "Node.js installation skipped (already installed)"

        # Still install essential packages if Node.js exists
        install_essential_packages "$@"
        return 0
    fi

    # Install Node.js via mise
    install_nodejs_via_mise "$@"

    # Install essential packages
    install_essential_packages "$@"

    log_success "Node.js setup completed!"
    log_info ""
    log_info "Available commands:"
    log_info "  mise use node@20        # Install specific version"
    log_info "  mise use -g node@lts    # Set global version"
    log_info "  mise list node          # List installed versions"
    log_info "  node --version          # Show current version"
    log_info "  npm --version           # Show npm version"
    log_info ""
    log_info "Current status:"
    if command -v node >/dev/null 2>&1; then
        log_info "  Node.js: $(node --version 2>/dev/null)"
        log_info "  npm: $(npm --version 2>/dev/null)"
    fi
}

# Run main function
main "$@"
