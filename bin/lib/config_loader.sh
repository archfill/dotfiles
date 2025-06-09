#!/usr/bin/env bash

# 設定ファイルローダー - dotfiles設定管理

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# dotfilesのルートディレクトリを取得
get_dotfiles_root() {
    log_info "DEBUG: get_dotfiles_root called - DOTFILES_DIR = ${DOTFILES_DIR:-'unset'}"
    
    # 環境変数DOTFILES_DIRが設定されている場合はそれを使用
    if [[ -n "${DOTFILES_DIR:-}" ]]; then
        log_info "DEBUG: returning existing DOTFILES_DIR = $DOTFILES_DIR"
        echo "$DOTFILES_DIR"
        return 0
    fi
    
    log_info "DEBUG: searching for dotfiles root starting from SCRIPT_DIR = $SCRIPT_DIR"
    local current_dir="$SCRIPT_DIR"
    while [[ "$current_dir" != "/" ]]; do
        log_info "DEBUG: checking directory: $current_dir"
        if [[ -f "$current_dir/CLAUDE.md" ]] || [[ -f "$current_dir/.gitignore" ]]; then
            log_info "DEBUG: found dotfiles root: $current_dir"
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # フォールバック
    local fallback="${HOME}/dotfiles"
    log_info "DEBUG: using fallback: $fallback"
    echo "$fallback"
}

# 設定ファイルの読み込み
load_config() {
    log_info "DEBUG: load_config start - DOTFILES_DIR = ${DOTFILES_DIR:-'unset'}"
    
    # DOTFILES_DIRが未設定の場合のみ取得・設定
    if [[ -z "${DOTFILES_DIR:-}" ]]; then
        log_info "DEBUG: DOTFILES_DIR is unset, calling get_dotfiles_root"
        local dotfiles_root
        dotfiles_root="$(get_dotfiles_root)"
        export DOTFILES_DIR="$dotfiles_root"
        log_info "DEBUG: set DOTFILES_DIR = $DOTFILES_DIR"
    else
        log_info "DEBUG: DOTFILES_DIR is already set, skipping get_dotfiles_root"
    fi
    
    # バージョン設定ファイルの読み込み
    local versions_file="${DOTFILES_DIR}/config/versions.conf"
    if [[ -f "$versions_file" ]]; then
        log_info "Loading versions configuration from $versions_file"
        source "$versions_file"
    else
        log_warning "Versions configuration file not found: $versions_file"
    fi
    
    # 個人設定ファイルの読み込み（存在する場合）
    local personal_config="${DOTFILES_DIR}/config/personal.conf"
    if [[ -f "$personal_config" ]]; then
        log_info "Loading personal configuration from $personal_config"
        source "$personal_config"
    else
        log_info "Personal configuration file not found (optional): $personal_config"
        # デフォルト値を使用
        export USER_NAME="${DEFAULT_USER_NAME}"
        export USER_EMAIL="${DEFAULT_USER_EMAIL}"
    fi
    
    # 環境変数の読み込み（.env.local）
    local env_file="${DOTFILES_DIR}/.env.local"
    if [[ -f "$env_file" ]]; then
        log_info "Loading environment variables from $env_file"
        set -a  # 変数を自動でexport
        source "$env_file"
        set +a
    fi
    
    # 設定値の検証
    validate_config
}

# 設定値の検証
validate_config() {
    local errors=0
    
    # 必須設定のチェック
    if [[ -z "${USER_NAME:-}" ]]; then
        log_error "USER_NAME is not set"
        errors=$((errors + 1))
    fi
    
    if [[ -z "${USER_EMAIL:-}" ]]; then
        log_error "USER_EMAIL is not set"
        errors=$((errors + 1))
    fi
    
    # バージョン設定のチェック
    local required_versions=(
        "NVM_VERSION"
        "FONT_CICA_VERSION"
        "FONT_HACKGEN_VERSION"
        "LAZYGIT_VERSION"
    )
    
    for version_var in "${required_versions[@]}"; do
        if [[ -z "${!version_var:-}" ]]; then
            log_warning "$version_var is not set, using default"
        fi
    done
    
    if [[ $errors -gt 0 ]]; then
        log_error "Configuration validation failed with $errors errors"
        return 1
    fi
    
    log_success "Configuration validation passed"
    return 0
}

# 設定値の表示（デバッグ用）
show_config() {
    log_info "Current configuration:"
    echo "  USER_NAME: ${USER_NAME:-'(not set)'}"
    echo "  USER_EMAIL: ${USER_EMAIL:-'(not set)'}"
    echo "  NVM_VERSION: ${NVM_VERSION:-'(not set)'}"
    echo "  FONT_CICA_VERSION: ${FONT_CICA_VERSION:-'(not set)'}"
    echo "  FONT_HACKGEN_VERSION: ${FONT_HACKGEN_VERSION:-'(not set)'}"
    echo "  LAZYGIT_VERSION: ${LAZYGIT_VERSION:-'(not set)'}"
    echo "  DOTFILES_DIR: ${DOTFILES_DIR:-'(not set)'}"
}

# 個人設定ファイルのテンプレート作成
create_personal_config_template() {
    local dotfiles_root
    dotfiles_root="$(get_dotfiles_root)"
    local template_file="${dotfiles_root}/config/personal.conf.template"
    
    cat > "$template_file" << 'EOF'
# 個人設定ファイル - personal.conf.template
# このファイルをpersonal.confにコピーして編集してください
# personal.confは.gitignoreに含まれており、Gitで管理されません

# 個人情報
export USER_NAME="Your Full Name"
export USER_EMAIL="your.email@example.com"

# カスタム設定（必要に応じて）
# export CUSTOM_INSTALL_DIR="/opt/custom"
# export CUSTOM_EDITOR="code"

# Nextcloudディレクトリ（使用する場合）
# export NEXTCLOUD_DIR="$HOME/Nextcloud"
EOF
    
    log_success "Personal configuration template created: $template_file"
    log_info "Copy it to personal.conf and edit with your settings:"
    log_info "  cp config/personal.conf.template config/personal.conf"
}

# 設定ファイルの初期化
init_config() {
    local dotfiles_root
    dotfiles_root="$(get_dotfiles_root)"
    
    # configディレクトリの作成
    mkdir -p "${dotfiles_root}/config"
    
    # テンプレートの作成
    create_personal_config_template
    
    # .gitignoreの更新（personal.confと.env.localを除外）
    local gitignore_file="${dotfiles_root}/.gitignore"
    if [[ -f "$gitignore_file" ]]; then
        if ! grep -q "config/personal.conf" "$gitignore_file"; then
            echo "config/personal.conf" >> "$gitignore_file"
            log_info "Added config/personal.conf to .gitignore"
        fi
        if ! grep -q ".env.local" "$gitignore_file"; then
            echo ".env.local" >> "$gitignore_file"
            log_info "Added .env.local to .gitignore"
        fi
    fi
}