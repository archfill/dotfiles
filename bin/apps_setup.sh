#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/lib/common.sh"

setup_error_handling

# Use DOTFILES_DIR environment variable
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    DOTFILES_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
fi

files="${DOTFILES_DIR}/bin/apps/*"
for filepath in $files; do
  if [[ -f "$filepath" && ! "${filepath}" == *setup.sh* ]]; then
    script_name="$(basename "$filepath")"
    log_info "Running app setup: $script_name"
    
    # Skip certain scripts in CI environment
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]] && [[ "$script_name" == "ghq.sh" ]]; then
      log_info "Skipping $script_name in CI environment"
      continue
    fi
    
    if ! bash "${filepath}"; then
      log_error "Script failed: $script_name"
      log_error "Script path: $filepath"
      exit 1
    fi
  fi
done

