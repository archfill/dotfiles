#!/usr/bin/env bash

# uv (Python package manager) installation script
# This script installs uv and sets up Python environment

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/uv_installer.sh"

# エラーハンドリングを設定
setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting uv (Python package manager) setup..."

# =============================================================================
# Enhanced uv Environment Checking and Management Functions
# =============================================================================

# Check uv installation and environment
check_uv_environment() {
    log_info "Checking uv environment..."
    
    local all_checks_passed=true
    
    # Check uv command availability
    if ! command -v uv >/dev/null 2>&1; then
        log_info "uv not available"
        all_checks_passed=false
    else
        # Check uv version
        local uv_version
        uv_version=$(uv --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "uv version: $uv_version"
        
        # Check uv functionality
        if uv --help >/dev/null 2>&1; then
            log_info "uv functionality check passed"
        else
            log_warning "uv functionality check failed"
        fi
    fi
    
    # Check installation directories
    local install_dirs=(
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
    )
    
    for dir in "${install_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_info "Install directory exists: $dir"
        else
            log_info "Install directory missing: $dir"
        fi
    done
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "uv environment checks passed"
        return 0
    else
        log_info "uv environment checks failed"
        return 1
    fi
}

# Check Python environment compatibility
check_python_environment() {
    log_info "Checking Python environment compatibility..."
    
    # Check if Python is available
    if command -v python3 >/dev/null 2>&1; then
        local python_version
        python_version=$(python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        log_info "System Python version: $python_version"
    else
        log_info "No system Python found"
    fi
    
    # Check old Python tools
    local old_tools=("pyenv" "pipenv" "poetry")
    local found_tools=0
    
    for tool in "${old_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_info "Found existing tool: $tool"
            ((found_tools++))
        fi
    done
    
    if [[ $found_tools -gt 0 ]]; then
        log_info "Found $found_tools existing Python management tools"
        log_info "uv can coexist with these tools"
    fi
    
    log_success "Python environment check completed"
    return 0
}

# Comprehensive uv environment check
check_uv_comprehensive_environment() {
    log_info "Performing comprehensive uv environment check..."
    
    local all_checks_passed=true
    
    # Check uv installation
    if ! check_uv_environment; then
        all_checks_passed=false
    fi
    
    # Check Python environment
    check_python_environment
    
    if [[ "$all_checks_passed" == "true" ]]; then
        log_success "All uv environment checks passed"
        return 0
    else
        log_info "Some uv environment checks failed"
        return 1
    fi
}

# Main installation function
main() {
    log_info "uv (Python Package Manager) Setup"
    log_info "=================================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Get target uv version
    local uv_version="${UV_VERSION:-latest}"
    
    # Check if uv installation should be skipped
    if should_skip_installation_advanced "uv" "uv" "$uv_version" "--version"; then
        # Even if uv is installed, check and update environment
        log_info "uv is installed, checking environment..."
        
        # Perform comprehensive environment check
        check_uv_comprehensive_environment
        
        # Verify installation
        if [[ "$DRY_RUN" != "true" ]]; then
            verify_uv_installation "$@"
        fi
        
        return 0
    fi
    
    # Install uv using enhanced library
    install_uv "$@"
    
    # Verify installation
    if [[ "$DRY_RUN" != "true" ]]; then
        verify_uv_installation "$@"
    fi
    
    log_success "uv setup completed!"
    log_info ""
    log_info "Available uv commands:"
    log_info "  uv --version           # Show uv version"
    log_info "  uv init <name>         # Initialize new Python project"
    log_info "  uv add <package>       # Add package to project"
    log_info "  uv python install <ver> # Install Python version"
    log_info "  uv pip install <pkg>   # Install package globally"
    log_info ""
    log_info "Global Python aliases (if configured):"
    log_info "  python, pip, pyproject-init"
    log_info ""
    log_info "Note: You may need to restart your shell or run 'source ~/.zshrc' to update environment"
}

# Run main function
main "$@"
