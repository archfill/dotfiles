#!/usr/bin/env bash

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config_loader.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Configuring Git settings"

# 設定ファイルを読み込み
load_config

# 設定値の確認
if [[ -z "${USER_NAME:-}" ]] || [[ -z "${USER_EMAIL:-}" ]]; then
    log_error "USER_NAME and USER_EMAIL must be set"
    log_info "Please create config/personal.conf with your settings"
    log_info "Use: cp config/personal.conf.template config/personal.conf"
    exit 1
fi

# git config
log_info "Setting up Git configuration for: $USER_NAME <$USER_EMAIL>"
git config --global user.name "$USER_NAME"
git config --global user.email "$USER_EMAIL"
git config --global core.editor 'nvim'

log_info "Setting up Git delta configuration"
git config --global core.pager 'delta'
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate 'true'
git config --global delta.light 'false'

log_info "Setting up Git aliases"
git config --global alias.tree "log --graph --pretty=format:'%x09%C(auto) %h %Cgreen %ar %Creset%x09by\"%C(cyan ul)%an%Creset\" %x09%C(auto)%s %d'"

log_success "Git configuration completed"
