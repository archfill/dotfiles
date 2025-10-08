#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/uv_installer.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting Chromebook setup"

# Install uv using common library
install_uv

# alacritty
log_info "Setting up alacritty for chromebook"
ALACRITTY_DIR=~/.config/alacritty
ALACRITTY_FILE=$ALACRITTY_DIR/alacritty.yml
unlink $ALACRITTY_DIR 2>/dev/null || true
rm -rf $ALACRITTY_DIR
mkdir -p $ALACRITTY_DIR
ln -sf ~/dotfiles/.config/alacritty/alacritty_chromebook.yml $ALACRITTY_FILE

log_success "Chromebook setup completed"
