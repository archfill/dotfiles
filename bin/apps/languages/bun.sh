#!/usr/bin/env bash

# Bun JavaScript/TypeScript runtime installation script
# This script installs Bun with unified skip logic support

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

# エラーハンドリングを設定
setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting Bun (JavaScript/TypeScript runtime & package manager) setup..."

# =============================================================================
# Enhanced Bun Environment Checking and Management Functions
# =============================================================================

# Check Bun installation and environment
check_bun_environment() {
    log_info "Checking Bun environment..."

    local all_checks_passed=true

    # Check Bun command availability
    if ! command -v bun >/dev/null 2>&1; then
        log_info "Bun not available"
        all_checks_passed=false
    else
        # Check Bun version
        local bun_version
        bun_version=$(bun --version 2>/dev/null || echo "unknown")
        log_info "Bun version: $bun_version"

        # Check Bun installation directory
        local bun_install_dir="${BUN_INSTALL:-$HOME/.bun}"
        if [[ -d "$bun_install_dir" ]]; then
            log_info "Bun install directory: $bun_install_dir"
        fi
    fi

    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Bun environment checks passed"
        return 0
    else
        log_info "Bun environment checks failed"
        return 1
    fi
}

# Install Bun with enhanced options
install_bun() {
    log_info "Installing Bun..."

    # Parse command line options
    parse_install_options "$@"

    # Check if Bun should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v bun >/dev/null 2>&1; then
        log_skip_reason "Bun" "Already installed: $(bun --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Bun (JavaScript/TypeScript runtime & package manager)"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Bunの自動インストール
        if curl -fsSL https://bun.sh/install | bash; then
            log_success "Bun installation completed"

            # Verify installation
            if command -v bun >/dev/null 2>&1 || [[ -f "$HOME/.bun/bin/bun" ]]; then
                log_success "Bun installed successfully"

                # Add to PATH for current session
                export PATH="$HOME/.bun/bin:$PATH"

                return 0
            else
                log_warning "Bun installation script completed but bun command not found"
                return 1
            fi
        else
            log_error "Bun installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Bun via official installer"
        return 0
    fi
}

# Verify Bun installation
verify_bun_installation() {
    log_info "Verifying Bun installation..."

    # Parse command line options
    parse_install_options "$@"

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would verify Bun installation"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Add Bun to PATH if not already there
        if [[ -f "$HOME/.bun/bin/bun" ]] && [[ ":$PATH:" != *":$HOME/.bun/bin:"* ]]; then
            export PATH="$HOME/.bun/bin:$PATH"
        fi

        if command -v bun >/dev/null 2>&1; then
            local bun_version
            bun_version=$(bun --version 2>/dev/null || echo "unknown")
            log_success "Bun is available: $bun_version"

            # Test basic Bun functionality
            if bun --help >/dev/null 2>&1; then
                log_success "Bun is working correctly"
                return 0
            else
                log_error "Bun installation is broken"
                return 1
            fi
        else
            log_error "Bun command not found in PATH"
            log_info "Current PATH: $PATH"
            log_info "Please restart your shell or run: export PATH=\"\$HOME/.bun/bin:\$PATH\""
            return 1
        fi
    else
        log_info "[DRY RUN] Would verify Bun installation and functionality"
        return 0
    fi
}

# Main installation function
main() {
    log_info "Bun (JavaScript/TypeScript Runtime & Package Manager) Setup"
    log_info "=========================================================="

    # Parse command line options
    parse_install_options "$@"

    # Detect platform
    local os_type=$(detect_platform)
    local distro=$(get_os_distribution)

    # Check if Bun should be managed by platform package manager
    if [[ "$os_type" == "macos" ]]; then
        log_info "macOS detected - Bun is managed by Homebrew (bin/platform/macos/packages.sh)"
        log_skip_reason "Bun" "Managed by Homebrew package manager"
        return 0
    elif [[ "$distro" == "arch" ]]; then
        log_info "Arch Linux detected - Bun is managed by yay (bin/platform/linux/packages.sh)"
        log_skip_reason "Bun" "Managed by yay (AUR: bun-bin)"
        return 0
    fi

    # For Debian/Ubuntu, use official install script
    log_info "Detected $distro - using official Bun install script"

    # Get target Bun version
    local bun_version="${BUN_VERSION:-latest}"

    # Check if Bun installation should be skipped
    if should_skip_installation_advanced "Bun" "bun" "$bun_version" "--version"; then
        # Even if Bun is installed, check and update environment
        log_info "Bun is installed, checking environment..."

        # Perform comprehensive environment check
        check_bun_environment

        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_bun_installation "$@"
        fi

        return 0
    fi

    # Install Bun
    install_bun "$@"

    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_bun_installation "$@"
    fi

    log_success "Bun setup completed!"
    log_info ""
    log_info "Available Bun commands:"
    log_info "  bun --version           # Show Bun version"
    log_info "  bun run <script.ts>     # Run TypeScript/JavaScript file"
    log_info "  bun install             # Install dependencies (faster than npm)"
    log_info "  bun add <package>       # Add package to project"
    log_info "  bun remove <package>    # Remove package from project"
    log_info "  bun test                # Run tests"
    log_info "  bun build <entry>       # Bundle TypeScript/JavaScript"
    log_info ""
    log_info "Key features:"
    log_info "  - Drop-in replacement for Node.js (runs npm packages)"
    log_info "  - Built-in bundler, transpiler, and test runner"
    log_info "  - Fast package manager (compatible with package.json)"
    log_info "  - Native TypeScript support (no tsc needed)"
    log_info ""
    log_info "Environment setup:"
    log_info "  export PATH=\"\$HOME/.bun/bin:\$PATH\""
    log_info ""
    log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"
