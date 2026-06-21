#!/usr/bin/env bash

# Load shared library
source "$(dirname "$0")/lib/common.sh"

setup_error_handling

# Use DOTFILES_DIR environment variable
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    DOTFILES_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
fi

log_info "Starting app setup from categorized directories..."

# Define categories in dependency order
# languages first (version managers), then devops, then tools
categories=("languages" "devops" "tools")

for category in "${categories[@]}"; do
  category_dir="${DOTFILES_DIR}/bin/apps/${category}"

  if [[ ! -d "$category_dir" ]]; then
    log_warning "Category directory not found: $category_dir"
    continue
  fi

  log_info "Processing category: $category"

  # Sort files to ensure consistent execution order
  for filepath in "$category_dir"/*.sh; do
    if [[ -f "$filepath" ]]; then
      script_name="$(basename "$filepath")"

      log_info "Running app setup: $category/$script_name"

      if ! bash "${filepath}"; then
        log_error "Script failed: $category/$script_name"
        log_error "Script path: $filepath"
        exit 1
      fi
    fi
  done

  log_success "Category $category completed"
done

log_success "All app setups completed successfully"
