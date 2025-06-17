#!/usr/bin/env bash

# Load shared libraries
source "$(dirname "$0")/../lib/common.sh"
source "$(dirname "$0")/../lib/volta_installer.sh"

setup_error_handling

# Use the shared Volta installer for complete setup
setup_volta_complete
