#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/common.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Installing Deno..."

# Denoの自動インストール（プロンプトなし）
export DENO_INSTALL_MODIFY_PATH=n
echo "N" | curl -fsSL https://deno.land/install.sh | sh

if [[ $? -eq 0 ]]; then
    log_success "Deno installation completed"
else
    log_error "Deno installation failed"
    exit 1
fi
