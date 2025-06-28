#!/usr/bin/env bash

# macOS用モダンフォントセットアップスクリプト
# 新しいfont_managerライブラリを使用した統一フォント管理

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/font_manager.sh"

# エラーハンドリングを設定
setup_error_handling

# 設定ファイルを読み込み
load_config

log_info "Starting macOS font setup using modern font manager..."

# Main function with unified skip logic
main() {
    log_info "macOS Font Installation"
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
    
    # Homebrew cask-fonts tapが追加されているか確認
    if [[ "$DRY_RUN" != "true" ]] && command -v brew >/dev/null 2>&1; then
        if ! brew tap | grep -q "homebrew/cask-fonts"; then
            log_info "Adding homebrew/cask-fonts tap..."
            brew tap homebrew/cask-fonts
        else
            log_info "homebrew/cask-fonts tap already added"
        fi
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would check and add homebrew/cask-fonts tap"
    else
        log_warning "Homebrew not found, fonts will be installed from GitHub releases"
    fi

    # 推奨フォントセットのインストール
    # 開発者向けプロファイル：JetBrains Mono NF, HackGen NF, PlemolJP
    if install_recommended_fonts "developer" "$@"; then
        log_success "Developer font profile processed successfully"
    else
        log_warning "Some fonts in developer profile failed to install"
    fi
    
    # 追加で日本語フォントセットをインストール
    log_info "Installing additional Japanese fonts..."
    local japanese_fonts=("udev-gothic" "cica")
    local japanese_success=0
    local japanese_failed=0
    local japanese_skipped=0
    
    for font in "${japanese_fonts[@]}"; do
        if [[ "$FORCE_INSTALL" != "true" ]] && check_font_installed "$font"; then
            log_skip_reason "Font: $font" "Already installed"
            ((japanese_skipped++))
            continue
        fi
        
        if [[ "$DRY_RUN" != "true" ]]; then
            if install_font "$font" "$@"; then
                ((japanese_success++))
            else
                ((japanese_failed++))
            fi
        else
            log_info "[DRY RUN] Would install font: $font"
            ((japanese_success++))
        fi
    done
    
    # クラシックフォントも必要な場合
    log_info "Installing classic development fonts..."
    local classic_fonts=("fira-code" "source-code-pro")
    local classic_success=0
    local classic_failed=0
    local classic_skipped=0
    
    for font in "${classic_fonts[@]}"; do
        if [[ "$FORCE_INSTALL" != "true" ]] && check_font_installed "$font"; then
            log_skip_reason "Font: $font" "Already installed"
            ((classic_skipped++))
            continue
        fi
        
        if [[ "$DRY_RUN" != "true" ]]; then
            if install_font "$font" "$@"; then
                ((classic_success++))
            else
                ((classic_failed++))
            fi
        else
            log_info "[DRY RUN] Would install font: $font"
            ((classic_success++))
        fi
    done
    
    # インストール状況の確認
    if [[ "$DRY_RUN" != "true" ]] && [[ "$QUICK_CHECK" != "true" ]]; then
        log_info "Current font installation status:"
        list_installed_fonts
    fi
    
    # Summary
    local total_success=$((japanese_success + classic_success))
    local total_skipped=$((japanese_skipped + classic_skipped))
    local total_failed=$((japanese_failed + classic_failed))
    
    if [[ "$DRY_RUN" != "true" ]]; then
        log_install_summary "$total_success" "$total_skipped" "$total_failed"
    else
        log_info "[DRY RUN] Total summary: $total_success would be installed, $total_skipped skipped"
    fi
    
    log_success "macOS font setup completed!"
    
    if [[ "$DRY_RUN" != "true" ]] && [[ $total_success -gt 0 ]]; then
        log_info "Please restart applications to see new fonts"
    fi
    
    log_info ""
    log_info "Available font management commands:"
    log_info "  make fonts-list            # List all installed fonts"
    log_info "  make fonts-install FONT=<name> # Install specific font"
    log_info "  fc-list | grep <font_name> # Check if font is available (Linux)"
    log_info "  Font Book.app              # Manage fonts on macOS"
}

# Run main function
main "$@"