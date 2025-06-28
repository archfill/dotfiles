#!/usr/bin/env bash

# Deno JavaScript/TypeScript runtime installation script
# This script installs Deno with unified skip logic support

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

log_info "Starting Deno (JavaScript/TypeScript runtime) setup..."

# =============================================================================
# Enhanced Deno Environment Checking and Management Functions
# =============================================================================

# Check Deno installation and environment
check_deno_environment() {
    log_info "Checking Deno environment..."
    
    local all_checks_passed=true
    
    # Check Deno command availability
    if ! command -v deno >/dev/null 2>&1; then
        log_info "Deno not available"
        all_checks_passed=false
    else
        # Check Deno version
        local deno_version
        deno_version=$(deno --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "Deno version: $deno_version"
        
        # Check Deno installation directory
        local deno_install_dir="${DENO_INSTALL:-$HOME/.deno}"
        if [[ -d "$deno_install_dir" ]]; then
            log_info "Deno install directory: $deno_install_dir"
        fi
    fi
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "Deno environment checks passed"
        return 0
    else
        log_info "Deno environment checks failed"
        return 1
    fi
}

# Install Deno with enhanced options
install_deno() {
    log_info "Installing Deno..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if Deno should be skipped
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v deno >/dev/null 2>&1; then
        log_skip_reason "Deno" "Already installed: $(deno --version 2>/dev/null | head -1 || echo 'version unknown')"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Deno (JavaScript/TypeScript runtime)"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Denoの自動インストール（プロンプトなし）
        export DENO_INSTALL_MODIFY_PATH=n
        
        if curl -fsSL https://deno.land/install.sh | sh -s -- -y; then
            log_success "Deno installation completed"
            
            # Verify installation
            if command -v deno >/dev/null 2>&1 || [[ -f "$HOME/.deno/bin/deno" ]]; then
                log_success "Deno installed successfully"
                
                # Add to PATH for current session
                export PATH="$HOME/.deno/bin:$PATH"
                
                return 0
            else
                log_warning "Deno installation script completed but deno command not found"
                return 1
            fi
        else
            log_error "Deno installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install Deno via official installer"
        return 0
    fi
}

# Verify Deno installation
verify_deno_installation() {
    log_info "Verifying Deno installation..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would verify Deno installation"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Add Deno to PATH if not already there
        if [[ -f "$HOME/.deno/bin/deno" ]] && [[ ":$PATH:" != *":$HOME/.deno/bin:"* ]]; then
            export PATH="$HOME/.deno/bin:$PATH"
        fi
        
        if command -v deno >/dev/null 2>&1; then
            local deno_version
            deno_version=$(deno --version 2>/dev/null | head -1 || echo "unknown")
            log_success "Deno is available: $deno_version"
            
            # Test basic Deno functionality
            if deno --help >/dev/null 2>&1; then
                log_success "Deno is working correctly"
                return 0
            else
                log_error "Deno installation is broken"
                return 1
            fi
        else
            log_error "Deno command not found in PATH"
            log_info "Current PATH: $PATH"
            log_info "Please restart your shell or run: export PATH=\"\$HOME/.deno/bin:\$PATH\""
            return 1
        fi
    else
        log_info "[DRY RUN] Would verify Deno installation and functionality"
        return 0
    fi
}

# Main installation function
main() {
    log_info "Deno (JavaScript/TypeScript Runtime) Setup"
    log_info "=========================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get target Deno version
    local deno_version="${DENO_VERSION:-latest}"
    
    # Check if Deno installation should be skipped
    if should_skip_installation_advanced "Deno" "deno" "$deno_version" "--version"; then
        # Even if Deno is installed, check and update environment
        log_info "Deno is installed, checking environment..."
        
        # Perform comprehensive environment check
        check_deno_environment
        
        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_deno_installation "$@"
        fi
        
        return 0
    fi
    
    # Install Deno
    install_deno "$@"
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_deno_installation "$@"
    fi
    
    log_success "Deno setup completed!"
    log_info ""
    log_info "Available Deno commands:"
    log_info "  deno --version          # Show Deno version"
    log_info "  deno run <script.ts>    # Run TypeScript/JavaScript file"
    log_info "  deno install <package>  # Install package globally"
    log_info "  deno info               # Show Deno environment info"
    log_info "  deno fmt                # Format code"
    log_info "  deno lint               # Lint code"
    log_info "  deno test               # Run tests"
    log_info ""
    log_info "Environment setup:"
    log_info "  export PATH=\"\$HOME/.deno/bin:\$PATH\""
    log_info ""
    log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"
