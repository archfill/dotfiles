#!/usr/bin/env bash

# uvインストール用の共通ライブラリ

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# uvインストール用の統一関数
install_uv() {
    log_info "Installing uv (Python package manager)..."
    
    # uvがすでにインストールされているかチェック
    if command -v uv >/dev/null 2>&1; then
        log_info "uv is already installed"
        uv --version
        return 0
    fi
    
    # プラットフォーム固有の処理
    local platform
    platform="$(detect_platform)"
    
    case "$platform" in
        "macos")
            # macOSではHomebrew経由でインストール
            if command -v brew >/dev/null 2>&1; then
                log_info "Installing uv via Homebrew..."
                brew install uv
            else
                log_warning "Homebrew not found, using official installer..."
                install_uv_official
            fi
            ;;
        "linux"|"cygwin")
            # Linux/CygwinではOfficial installerを使用
            install_uv_official
            ;;
        *)
            log_error "Unsupported platform: $platform"
            return 1
            ;;
    esac
    
    # インストール確認
    if command -v uv >/dev/null 2>&1; then
        log_success "uv installation completed successfully"
        uv --version
        
        # PATH設定の案内
        log_info "Make sure ~/.local/bin and ~/.cargo/bin are in your PATH"
        log_info "Add this to your shell profile: export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\""
        
        return 0
    else
        log_error "uv installation failed"
        return 1
    fi
}

# Official installerを使用したuvインストール
install_uv_official() {
    log_info "Installing uv via official installer..."
    
    # 必要なコマンドの確認
    check_command_exists "curl" || return 1
    
    # インストール実行
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        log_info "Official uv installer completed"
        
        # 環境変数の更新（現在のセッション用）
        # uvは~/.local/binにインストールされる
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
        
        return 0
    else
        log_error "Failed to install uv via official installer"
        return 1
    fi
}

# uvの設定確認
verify_uv_installation() {
    log_info "Verifying uv installation..."
    
    if ! command -v uv >/dev/null 2>&1; then
        log_error "uv command not found in PATH"
        log_info "Current PATH: $PATH"
        return 1
    fi
    
    local uv_version
    uv_version="$(uv --version 2>/dev/null || echo "unknown")"
    log_success "uv is available: $uv_version"
    
    # uvの基本機能テスト
    if uv --help >/dev/null 2>&1; then
        log_success "uv is working correctly"
        return 0
    else
        log_error "uv installation is broken"
        return 1
    fi
}

# Python関連の古い設定のクリーンアップ（オプション）
cleanup_old_python_tools() {
    log_info "Cleaning up old Python tool configurations..."
    
    # pyenvの設定を無効化（完全削除はしない）
    local shell_configs=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
    )
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # pyenv関連の行をコメントアウト
            if grep -q "pyenv" "$config" 2>/dev/null; then
                log_info "Found pyenv configuration in $config"
                log_info "Consider manually updating your shell configuration to use uv aliases"
            fi
        fi
    done
}