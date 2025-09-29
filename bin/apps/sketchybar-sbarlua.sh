#!/usr/bin/env bash

# SbarLua installation script for macOS
# Simplified version using official installation method

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"

setup_error_handling

log_info "SbarLua installation script"

# =============================================================================
# Helper Functions
# =============================================================================

check_dependencies() {
    local missing_deps=()

    # Check macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_error "This script is only for macOS"
        exit 1
    fi

    # Check required tools
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v make >/dev/null 2>&1 || missing_deps+=("make (Xcode command line tools)")
    command -v sketchybar >/dev/null 2>&1 || missing_deps+=("sketchybar")

    # Install Lua if missing
    if ! command -v lua >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            log_info "Installing Lua via Homebrew..."
            brew install lua
        else
            missing_deps+=("lua")
        fi
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            log_error "  - $dep"
        done
        log_error ""
        log_error "Install SketchyBar: brew tap FelixKratz/formulae && brew install sketchybar"
        log_error "Install Xcode tools: xcode-select --install"
        exit 1
    fi
}

check_installation() {
    lua -e "require('sketchybar')" >/dev/null 2>&1
}

# =============================================================================
# Installation Commands
# =============================================================================

install_sbarlua() {
    log_info "Installing SbarLua (official method)..."

    if (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua && make install && rm -rf /tmp/SbarLua); then
        log_info "✅ SbarLua installed successfully"
        return 0
    else
        log_error "❌ SbarLua installation failed"
        return 1
    fi
}

uninstall_sbarlua() {
    log_info "Uninstalling SbarLua..."

    if (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua && make uninstall && rm -rf /tmp/SbarLua); then
        log_info "✅ SbarLua uninstalled successfully"
        return 0
    else
        log_error "❌ SbarLua uninstall failed"
        return 1
    fi
}

# =============================================================================
# Main Logic
# =============================================================================

main() {
    local action="${1:-install}"

    case "$action" in
        "install"|"")
            check_dependencies

            if check_installation; then
                log_info "SbarLua is already installed and functional"
                log_info "💡 Next step: make sketchybar-convert"
            else
                if install_sbarlua; then
                    log_info ""
                    log_info "🎉 SbarLua setup completed!"
                    log_info ""
                    log_info "Next steps:"
                    log_info "  1. Convert to Lua config: make sketchybar-convert"
                    log_info "  2. Test the setup: make sketchybar-test"
                else
                    exit 1
                fi
            fi
            ;;
        "uninstall")
            if uninstall_sbarlua; then
                log_info ""
                log_info "🗑️ SbarLua uninstall completed!"
            else
                exit 1
            fi
            ;;
        *)
            log_error "Usage: $0 [install|uninstall]"
            exit 1
            ;;
    esac
}

main "$@"