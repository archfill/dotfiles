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

# ~/.config/git/config.local に個人情報を書き込む（XDG 配置、dotfiles 非管理）
LOCAL_GITCONFIG="${HOME}/.config/git/config.local"
mkdir -p "$(dirname "$LOCAL_GITCONFIG")"
log_info "Setting up Git local configuration for: $USER_NAME <$USER_EMAIL>"

git config --file "$LOCAL_GITCONFIG" user.name "$USER_NAME"
git config --file "$LOCAL_GITCONFIG" user.email "$USER_EMAIL"

# ghq.root も同じ config.local に書き込む（環境ごとにパスが異なるため共有 dotfiles
# に置けない）。GHQ_ROOT は config/versions.conf で定義 (~/git デフォルト)。
if [[ -n "${GHQ_ROOT:-}" ]]; then
    log_info "Setting ghq.root to ${GHQ_ROOT}"
    git config --file "$LOCAL_GITCONFIG" ghq.root "${GHQ_ROOT}"
fi

log_success "Git configuration completed (local: $LOCAL_GITCONFIG)"
