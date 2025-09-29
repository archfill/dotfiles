#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../lib/config_loader.sh"

setup_error_handling

# Load configuration
load_config


# Set ghq root from configuration
log_info "Setting ghq.root to ${GHQ_ROOT}"
git config --global ghq.root "${GHQ_ROOT}"
