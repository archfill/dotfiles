#!/usr/bin/env bash

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$DOTFILES_DIR/bin/lib/common.sh"

# Setup standardized error handling
setup_error_handling

log_info "Termux environment setup starting..."

ROOT_DIR="/data/data/com.termux/files/usr"

mkdir -p "${HOME}/.config"
mkdir -p "${HOME}/git"

mkdir -p "${HOME}/git/termux"
mkdir -p "${HOME}/.termux"

# Setup color scheme
log_info "Setting up Termux color scheme..."
if [[ ! -d "${HOME}/git/termux/termux-tokyonight" ]]; then
    git clone https://github.com/Iamafnan/termux-tokyonight.git "${HOME}/git/termux/termux-tokyonight"
fi
cp "${HOME}/git/termux/termux-tokyonight/colorschemes/tokyonight-night.properties" "${HOME}/.termux/colors.properties"

# Setup font
log_info "Setting up Termux font..."
HACKGEN_VERSION=v2.9.0
temp_dir=$(pwd)
rm -rf "${HOME}/temp"
mkdir -p "${HOME}/temp"
cd "${HOME}/temp"
curl -OL "https://github.com/yuru7/HackGen/releases/download/${HACKGEN_VERSION}/HackGen_NF_${HACKGEN_VERSION}.zip"
unzip "HackGen_NF_${HACKGEN_VERSION}.zip"
mv "HackGen_NF_${HACKGEN_VERSION}/HackGenConsoleNF-Regular.ttf" "${HOME}/.termux/font.ttf"
cd "$temp_dir"
termux-reload-settings

# Install packages
log_info "Installing Termux packages..."
bash "${DOTFILES_DIR}/bin/termux/install.sh"

# Setup symlinks
log_info "Setting up symlinks..."
bash "${DOTFILES_DIR}/bin/termux/link.sh"

# Setup applications
log_info "Setting up applications..."
bash "${DOTFILES_DIR}/bin/apps/zinit.sh"
bash "${DOTFILES_DIR}/bin/apps/uv.sh"

# Change default shell to zsh
log_info "Changing default shell to zsh..."
chsh -s zsh

log_success "Termux environment setup completed!"