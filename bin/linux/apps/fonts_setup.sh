#!/usr/bin/env bash

# Linux用モダンフォントセットアップスクリプト
# 新しいfont_managerライブラリを使用した統一フォント管理

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/font_manager.sh"

# エラーハンドリングを設定
setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting Linux font setup using modern font manager..."

# Main function with unified skip logic
main() {
    log_info "Linux Font Installation"
    log_info "======================"
    
    # Parse command line options
    parse_install_options "$@"
    
    # Check if font installation should be skipped entirely
    if should_skip_font_install; then
        log_info "Font installation skipped"
        return 0
    fi
    
    # Check font environment
    check_font_environment
    
    # 推奨フォントセットのインストール
    # 開発者向けプロファイル：JetBrains Mono NF, HackGen NF, PlemolJP
    if install_recommended_fonts "developer" "$@"; then
        log_success "Developer font profile processed successfully"
    else
        log_warning "Some fonts in developer profile failed to install"
    fi
    
    # 追加で日本語フォントも必要な場合はUDEV Gothicを追加
    log_info "Installing additional Japanese font..."
    local udev_success=0
    local udev_failed=0
    local udev_skipped=0
    
    if [[ "$FORCE_INSTALL" != "true" ]] && check_font_installed "udev-gothic"; then
        log_skip_reason "Font: udev-gothic" "Already installed"
        udev_skipped=1
    elif [[ "$DRY_RUN" != "true" ]]; then
        if install_font "udev-gothic" "$@"; then
            udev_success=1
        else
            udev_failed=1
        fi
    else
        log_info "[DRY RUN] Would install font: udev-gothic"
        udev_success=1
    fi
    
    # インストール状況の確認
    if [[ "$DRY_RUN" != "true" ]] && [[ "$QUICK_CHECK" != "true" ]]; then
        log_info "Current font installation status:"
        list_installed_fonts
        
        # fontconfigキャッシュの更新
        if command -v fc-cache >/dev/null 2>&1; then
            log_info "Updating fontconfig cache..."
            fc-cache -f -v >/dev/null 2>&1
            log_success "Fontconfig cache updated"
        fi
    fi
    
    # Summary for additional fonts
    if [[ "$DRY_RUN" != "true" ]]; then
        log_install_summary "$udev_success" "$udev_skipped" "$udev_failed"
    else
        log_info "[DRY RUN] Additional font summary: $udev_success would be installed, $udev_skipped skipped"
    fi
    
    log_success "Linux font setup completed!"
    
    if [[ "$DRY_RUN" != "true" ]] && [[ $udev_success -gt 0 ]]; then
        log_info "Please restart applications to see new fonts"
    fi
    
    log_info ""
    log_info "Available font management commands:"
    log_info "  fc-list                    # List all available fonts"
    log_info "  fc-list | grep <font_name> # Check if specific font is installed"
    log_info "  fc-cache -f -v             # Refresh font cache"
    log_info "  make fonts-list            # List fonts via dotfiles manager"
}

# Run main function
main "$@"
