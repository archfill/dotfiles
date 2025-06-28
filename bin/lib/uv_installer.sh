#!/usr/bin/env bash

# uvインストール用の共通ライブラリ

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/config_loader.sh"
source "${SCRIPT_DIR}/install_checker.sh"

# uvインストール用の統一関数（統一スキップロジック対応）
install_uv() {
    log_info "Installing uv (Python package manager)..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # uvがすでにインストールされているかチェック
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v uv >/dev/null 2>&1; then
        log_skip_reason "uv" "Already installed: $(uv --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install uv (Python package manager)"
        return 0
    fi
    
    # プラットフォーム固有の処理
    local platform
    platform="$(detect_platform)"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        case "$platform" in
            "macos")
                # macOSではHomebrew経由でインストール
                if command -v brew >/dev/null 2>&1; then
                    log_info "Installing uv via Homebrew..."
                    brew install uv
                else
                    log_warning "Homebrew not found, using official installer..."
                    install_uv_official "$@"
                fi
                ;;
            "linux"|"cygwin")
                # Linux/CygwinではOfficial installerを使用
                install_uv_official "$@"
                ;;
            *)
                log_error "Unsupported platform: $platform"
                return 1
                ;;
        esac
    else
        log_info "[DRY RUN] Would install uv for platform: $platform"
    fi
    
    # インストール確認
    if [[ "$DRY_RUN" != "true" ]]; then
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
    else
        log_info "[DRY RUN] Would verify uv installation"
        return 0
    fi
}

# Official installerを使用したuvインストール（統一スキップロジック対応）
install_uv_official() {
    log_info "Installing uv via official installer..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install uv via official installer"
        return 0
    fi
    
    # 必要なコマンドの確認
    if ! check_command_exists "curl"; then
        log_error "curl is required for uv installation"
        return 1
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
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
    else
        log_info "[DRY RUN] Would install uv via official installer"
        return 0
    fi
}

# uvの設定確認（統一スキップロジック対応）
verify_uv_installation() {
    log_info "Verifying uv installation..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would verify uv installation"
        return 0
    fi
    
    if [[ "$DRY_RUN" != "true" ]]; then
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
            
            # 追加の機能テスト
            log_info "Testing uv basic functionality..."
            if uv pip --help >/dev/null 2>&1; then
                log_info "uv pip functionality: OK"
            fi
            
            if uv python --help >/dev/null 2>&1; then
                log_info "uv python functionality: OK"
            fi
            
            return 0
        else
            log_error "uv installation is broken"
            return 1
        fi
    else
        log_info "[DRY RUN] Would verify uv installation and functionality"
        return 0
    fi
}

# Python関連の古い設定のクリーンアップ（オプション）（統一スキップロジック対応）
cleanup_old_python_tools() {
    log_info "Cleaning up old Python tool configurations..."
    
    # Parse command line options
    parse_install_options "$@"
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would check old Python tool configurations"
        return 0
    fi
    
    # pyenvの設定を無効化（完全削除はしない）
    local shell_configs=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
    )
    
    local found_configs=0
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # pyenv関連の行をコメントアウト
            if grep -q "pyenv" "$config" 2>/dev/null; then
                log_info "Found pyenv configuration in $config"
                ((found_configs++))
            fi
        fi
    done
    
    if [[ $found_configs -gt 0 ]]; then
        log_info "Found pyenv configurations in $found_configs files"
        log_info "Consider manually updating your shell configuration to use uv aliases"
        log_info "uv can coexist with pyenv, but you may want to migrate"
    else
        log_info "No conflicting Python tool configurations found"
    fi
    
    log_success "Python tool configuration check completed"
    return 0
}