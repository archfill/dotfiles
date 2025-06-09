#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/lib/common.sh"

setup_error_handling

# Use DOTFILES_DIR environment variable
if [[ -z "$DOTFILES_DIR" ]]; then
    DOTFILES_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
fi

files="${DOTFILES_DIR}/bin/apps/*"
for filepath in $files; do
  if [[ -f "$filepath" && ! "${filepath}" == *setup.sh* ]]; then
    log_info "Running app setup: $(basename "$filepath")"
    bash "${filepath}"
  fi
done

