#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../lib/config_loader.sh"

setup_error_handling

# Load configuration
load_dotfiles_config

# stackline - yabai
if [[ ! -d "${HOME}/.hammerspoon/stackline" ]]; then
    log_info "Installing stackline for yabai..."
    git clone https://github.com/AdamWagner/stackline.git ${HOME}/.hammerspoon/stackline
fi

# Set ghq root from configuration
log_info "Setting ghq.root to ${GHQ_ROOT}"
git config --global ghq.root "${GHQ_ROOT}"
