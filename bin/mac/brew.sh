#!/usr/bin/env bash

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

setup_error_handling

log_info "Starting Homebrew package installation..."

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    log_error "Homebrew is not installed. Please run 'make macos-setup-minimal' first."
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

# Choose which categories to install based on environment variable
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

# Add homebrew taps
log_info "Adding Homebrew taps..."
taps=(
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

for tap in "${taps[@]}"; do
    if ! brew tap | grep -q "^$tap$"; then
        log_info "Adding tap: $tap"
        brew tap "$tap" || log_warning "Failed to add tap: $tap"
    else
        log_info "Tap already added: $tap"
    fi
done

# Install packages
log_info "Installing Homebrew packages..."
installed_count=0
failed_count=0

for v in "${apps[@]}"; do
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

    # Check if already installed
    if [[ "${v}" == *--cask* ]]; then
        # Cask check
        if brew list --cask | grep -q "^${app_name}$"; then
            log_info "✅ Already installed (cask): ${app_name}"
            continue
        fi
    else
        # Formula check
        if brew list | grep -q "^${app_name}$"; then
            log_info "✅ Already installed: ${app_name}"
            continue
        fi
    fi

    log_info "🔄 Installing: ${v}"
    if brew install "${v}"; then
        log_success "✅ Installed: ${app_name}"
        ((installed_count++))
    else
        log_error "❌ Failed to install: ${v}"
        ((failed_count++))
    fi
done

log_info "Installation summary:"
log_success "✅ Successfully installed: ${installed_count} packages"
if [[ $failed_count -gt 0 ]]; then
    log_warning "⚠️  Failed to install: ${failed_count} packages"
else
    log_success "🎉 All packages installed successfully!"
fi

