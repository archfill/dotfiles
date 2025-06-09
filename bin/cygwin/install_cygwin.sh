#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/uv_installer.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting Cygwin setup"

# Install uv using common library
install_uv

log_success "Cygwin setup completed"
