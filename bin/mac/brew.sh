#!/usr/bin/env bash

# Homebrew package installation script for macOS
# This script installs essential development tools and applications via Homebrew

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting Homebrew package installation..."

# =============================================================================
# Enhanced Homebrew Environment Checking Functions
# =============================================================================

# Check Homebrew installation and environment
check_homebrew_environment() {
    log_info "Checking Homebrew environment..."
    
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew is not installed. Please run 'make macos-setup-minimal' first."
        return 1
    fi
    
    # Check Homebrew version and status
    local brew_version
    brew_version=$(brew --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log_info "Homebrew version: $brew_version"
    
    # Check Homebrew prefix
    local brew_prefix
    brew_prefix=$(brew --prefix 2>/dev/null || echo "unknown")
    log_info "Homebrew prefix: $brew_prefix"
    
    # Quick health check
    if brew doctor >/dev/null 2>&1; then
        log_info "Homebrew doctor check: OK"
    else
        log_warning "Homebrew doctor found issues (this may be normal)"
    fi
    
    log_success "Homebrew environment check completed"
    return 0
}

# Check if Homebrew is available
if ! check_homebrew_environment; then
    exit 1
fi

# Essential development tools
essential_apps=(
  'git'
  'curl'
  'wget'
  'jq'
  'yq'
  'fzf'
  'ripgrep'
  'bat'
  'tmux'
  'make'
  'coreutils'
  'openssl'
  'readline'
  'xz'
  'zlib'
)

# Programming languages and tools
dev_apps=(
  'uv'
  'volta'
  'deno'
  'bun'
  'go'
  'openjdk'
  'openjdk@11'
  'jenv'
)

# Development utilities
utils_apps=(
  'ghq'
  'lazygit'
  'direnv'
  'the_silver_searcher'
  'awscli'
  'stripe'
)

# macOS specific tools
macos_apps=(
  'yabai'
  'skhd'
  'displayplacer'
  'dmg2img'
  'wakeonlan'
)

# Optional/specialized tools
optional_apps=(
  'bazelisk'
  'neomutt'
  'qmk'
  'ranger'
  'sqlite3'
  'tcl-tk'
  'w3m'
)

# GUI applications (casks)
cask_apps=(
  '--cask wezterm'
  '--cask aquaskk'
  '--cask hammerspoon'
  '--cask kitty'
  '--cask android-platform-tools'
  '--cask google-cloud-sdk'
  '--cask brewlet'
  '--cask cheatsheet'
)

# Optional casks (can be skipped)
optional_casks=(
  '--cask altserver'
  '--cask appflowy'
  '--cask biscuit'
  '--cask yt-music'
  '--cask utm'
  '--cask via'
  '--cask warp'
  '--cask xcodes'
  '--cask lapce'
  '--cask nextcloud'
  '--cask gitup'
  '--cask cscreen'
  '--cask devtoys'
  '--cask finch'
  '--cask blackhole-16ch'
  '--cask blackhole-2ch'
  '--cask blackhole-64ch'
  '--cask --no-quarantine gcenx/wine/unofficial-wineskin'
)

# Main installation function
main() {
    log_info "Homebrew Package Installation"
    log_info "============================="
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if Homebrew installation should be skipped entirely
    if should_skip_installation_simple "Homebrew packages" "brew"; then
        log_info "Homebrew packages installation skipped"
        return 0
    fi
    
    # Choose which categories to install based on environment variable
    local apps
    if [[ "${DOTFILES_INSTALL_MODE:-full}" == "minimal" ]]; then
        apps=("${essential_apps[@]}" "${dev_apps[@]}")
        log_info "Installing minimal package set (${#apps[@]} packages)"
    elif [[ "${DOTFILES_INSTALL_MODE:-full}" == "essential" ]]; then
        apps=("${essential_apps[@]}" "${dev_apps[@]}" "${utils_apps[@]}" "${cask_apps[@]}")
        log_info "Installing essential package set (${#apps[@]} packages)"
    else
        # Full installation
        apps=("${essential_apps[@]}" "${dev_apps[@]}" "${utils_apps[@]}" "${macos_apps[@]}" "${optional_apps[@]}" "${cask_apps[@]}" "${optional_casks[@]}")
        log_info "Installing full package set (${#apps[@]} packages)"
    fi
    
    # Add Homebrew taps
    add_homebrew_taps "$@"
    
    # Install packages
    install_homebrew_packages "$@"
    
    log_success "Homebrew setup completed!"
    log_info ""
    log_info "Available Homebrew commands:"
    log_info "  brew search <package>      # Search for packages"
    log_info "  brew install <package>     # Install package"
    log_info "  brew uninstall <package>   # Uninstall package"
    log_info "  brew list                  # List installed packages"
    log_info "  brew update && brew upgrade # Update all packages"
    log_info "  brew cleanup               # Clean up old versions"
    log_info ""
    log_info "Cask commands (GUI applications):"
    log_info "  brew search --cask <app>   # Search for GUI apps"
    log_info "  brew install --cask <app>  # Install GUI app"
    log_info "  brew list --cask           # List installed GUI apps"
}

# Run main function
main "$@"

# Add homebrew taps with enhanced options
add_homebrew_taps() {
    log_info "Adding Homebrew taps..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would add Homebrew taps"
        return 0
    fi
    
    local taps=(
        "gcenx/wine"
        "homebrew/cask"
        "homebrew/core"
        "homebrew/services"
        "jakehilborn/jakehilborn"
        "koekeishiya/formulae"
        "osx-cross/arm"
        "osx-cross/avr"
        "qmk/qmk"
        "stripe/stripe-cli"
    )
    
    local added_count=0
    local skipped_count=0
    
    for tap in "${taps[@]}"; do
        if ! brew tap | grep -q "^$tap$"; then
            if [[ "$DRY_RUN" != "true" ]]; then
                log_info "Adding tap: $tap"
                if brew tap "$tap" 2>/dev/null; then
                    ((added_count++))
                else
                    log_warning "Failed to add tap: $tap"
                fi
            else
                log_info "[DRY RUN] Would add tap: $tap"
                ((added_count++))
            fi
        else
            log_info "Tap already added: $tap"
            ((skipped_count++))
        fi
    done
    
    log_info "Taps summary: $added_count added, $skipped_count skipped"
}

# Install packages with enhanced options
install_homebrew_packages() {
    log_info "Installing Homebrew packages..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install ${#apps[@]} Homebrew packages"
        return 0
    fi
    
    local installed_count=0
    local skipped_count=0
    local failed_count=0
    
    for v in "${apps[@]}"; do
        local app_name
        if [[ "${v}" == *--HEAD* ]]; then
            # build install
            app_name=$(echo "${v}" | sed -e "s/--HEAD//")
        elif [[ "${v}" == *gcenx/wine/unofficial-wineskin* ]]; then
            # cask install
            app_name=$(echo "${v}" | sed -e "s/--cask --no-quarantine gcenx\/wine\///")
        elif [[ "${v}" == *--cask* ]]; then
            # cask install
            app_name=$(echo "${v}" | sed -e "s/--cask//")
        else
            # latest install
            app_name="${v}"
        fi
        
        # Clean app name
        app_name=$(echo "$app_name" | xargs)
    
        # Check if already installed (enhanced skip logic)
        local already_installed=false
        if [[ "${v}" == *--cask* ]]; then
            # Cask check
            if brew list --cask 2>/dev/null | grep -q "^${app_name}$"; then
                already_installed=true
            fi
        else
            # Formula check
            if brew list 2>/dev/null | grep -q "^${app_name}$"; then
                already_installed=true
            fi
        fi
        
        if [[ "$already_installed" == "true" ]] && [[ "$FORCE_INSTALL" != "true" ]]; then
            log_skip_reason "${app_name}" "Already installed"
            ((skipped_count++))
            continue
        fi
    
        if [[ "$DRY_RUN" != "true" ]]; then
            log_info "🔄 Installing: ${v}"
            if brew install "${v}" 2>/dev/null; then
                log_success "✅ Installed: ${app_name}"
                ((installed_count++))
            else
                log_error "❌ Failed to install: ${v}"
                ((failed_count++))
            fi
        else
            log_info "[DRY RUN] Would install: ${v}"
            ((installed_count++))
        fi
    done
    
    # Enhanced summary with install_checker.sh integration
    if [[ "$DRY_RUN" != "true" ]]; then
        log_install_summary "$installed_count" "$skipped_count" "$failed_count"
    else
        log_info "[DRY RUN] Package summary: $installed_count would be installed, $skipped_count skipped"
    fi
    
    if [[ $failed_count -gt 0 ]]; then
        log_warning "⚠️  Some packages failed to install. This may be normal for optional packages."
    else
        log_success "🎉 All packages processed successfully!"
    fi
}

