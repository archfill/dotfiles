#!/usr/bin/env bash
# volta_installer.sh - Shared Volta installer library
# Provides unified Volta installation and setup functionality

# このファイルは単独で実行されるべきではなく、他のスクリプトから読み込まれる
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    echo "Error: This file should be sourced, not executed directly" >&2
    exit 1
}

# 共通ライブラリが読み込まれていることを確認
if [[ -z "$(type -t log_info 2>/dev/null)" ]]; then
    echo "Error: common.sh must be sourced before volta_installer.sh" >&2
    return 1
fi

# Voltaがインストールされているかチェック
is_volta_installed() {
    command -v volta >/dev/null 2>&1
}

# Voltaのバージョンを取得
get_volta_version() {
    if is_volta_installed; then
        volta --version 2>/dev/null | head -1 || echo "unknown"
    else
        echo "not installed"
    fi
}

# Volta環境変数の設定
setup_volta_environment() {
    export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"
    export PATH="$VOLTA_HOME/bin:$PATH"
    
    # シェル設定ファイルに追加（bashrcやzshrcに既に記載済みか確認）
    local shell_config=""
    if [[ -n "$BASH_VERSION" && -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" && -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    fi
    
    if [[ -n "$shell_config" ]] && ! grep -q "VOLTA_HOME" "$shell_config" 2>/dev/null; then
        log_info "Adding Volta environment to $shell_config"
        {
            echo ""
            echo "# Volta configuration"
            echo "export VOLTA_HOME=\"\$HOME/.volta\""
            echo "export PATH=\"\$VOLTA_HOME/bin:\$PATH\""
        } >> "$shell_config"
    fi
}

# Voltaをインストール
install_volta() {
    if is_volta_installed; then
        local version
        version=$(get_volta_version)
        log_info "Volta is already installed: $version"
        return 0
    fi
    
    log_info "Installing Volta JavaScript toolchain manager..."
    
    # Voltaの公式インストーラーを実行
    if curl -fsSL https://get.volta.sh | bash; then
        log_success "Volta installer completed"
    else
        log_error "Failed to download or execute Volta installer"
        return 1
    fi
    
    # 環境変数を設定
    setup_volta_environment
    
    # インストール確認
    if is_volta_installed; then
        local version
        version=$(get_volta_version)
        log_success "Volta installation verified: $version"
        return 0
    else
        log_error "Volta installation failed - command not found after install"
        log_warn "You may need to restart your shell or source your profile"
        return 1
    fi
}

# Node.js LTSとnpmをインストール
install_nodejs_toolchain() {
    if ! is_volta_installed; then
        log_error "Volta is not installed. Please install Volta first."
        return 1
    fi
    
    log_info "Installing Node.js LTS and npm..."
    
    # Node.js LTSをインストール
    if volta install node@lts; then
        log_success "Node.js LTS installed successfully"
    else
        log_error "Failed to install Node.js LTS"
        return 1
    fi
    
    # npmの最新版をインストール
    if volta install npm@latest; then
        log_success "npm latest installed successfully"
    else
        log_warn "Failed to install npm latest (may already be included with Node.js)"
    fi
    
    return 0
}

# インストール済みツールの一覧表示
show_volta_tools() {
    if ! is_volta_installed; then
        log_warn "Volta is not installed"
        return 1
    fi
    
    log_info "Installed Volta tools:"
    volta list
}

# 完全なVoltaセットアップ（インストール + Node.js toolchain）
setup_volta_complete() {
    log_info "Starting complete Volta setup..."
    
    # Voltaをインストール
    if ! install_volta; then
        log_error "Failed to install Volta"
        return 1
    fi
    
    # Node.js toolchainをインストール
    if ! install_nodejs_toolchain; then
        log_error "Failed to install Node.js toolchain"
        return 1
    fi
    
    # インストール結果を表示
    show_volta_tools
    
    log_success "Volta setup completed successfully!"
    log_info "Usage examples:"
    log_info "  volta pin node@18    # Pin Node.js 18 for this project"
    log_info "  volta pin npm@9      # Pin npm 9 for this project"
    log_info "  volta install yarn   # Install Yarn globally"
    
    return 0
}

# Voltaのアンインストール
uninstall_volta() {
    log_info "Uninstalling Volta..."
    
    if [[ -d "$HOME/.volta" ]]; then
        rm -rf "$HOME/.volta"
        log_success "Volta directory removed"
    else
        log_info "Volta directory not found"
    fi
    
    # PATHからVoltaを削除（現在のセッションのみ）
    export PATH="${PATH//$HOME\/.volta\/bin:/}"
    
    log_info "Volta uninstalled. You may need to remove Volta configuration from your shell profile manually."
}