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
    
    # Note: homebrew/cask-fonts tap is now deprecated (fonts are available directly)
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would install fonts via Homebrew casks"
    elif ! command -v brew >/dev/null 2>&1; then
        log_warning "Homebrew not found, fonts will be installed from GitHub releases"
    fi

    # 推奨フォントセットのインストール
    # 開発者向けプロファイル：JetBrains Mono NF, HackGen NF, PlemolJP
    if install_recommended_fonts "developer" "$@"; then
        log_success "Developer font profile processed successfully"
    else
        log_warning "Some fonts in developer profile failed to install"
    fi
    
    # 追加で日本語フォントセットをインストール（Homebrewのみ）
    log_info "Installing additional Japanese fonts via Homebrew..."
    local japanese_fonts=("udev-gothic" "cica")
    local japanese_success=0
    local japanese_failed=0
    local japanese_skipped=0

    for font in "${japanese_fonts[@]}"; do
        # Homebrewでのインストールのみ試行（簡素化）
        if [[ "$DRY_RUN" != "true" ]]; then
            log_info "Attempting to install font via Homebrew: $font"

            # フォント設定の取得
            local brew_cask=""
            case "$font" in
                "udev-gothic") brew_cask="font-udev-gothic" ;;
                "cica") brew_cask="font-cica" ;;
                "plemoljp") brew_cask="font-plemol-jp" ;;
                *) brew_cask="font-$font" ;;
            esac

            # Homebrewでインストール試行（既にインストール済みでもエラーにならない）
            if brew install --cask "$brew_cask" 2>/dev/null; then
                log_success "Font installed/updated successfully: $font"
                ((japanese_success++))
            else
                log_info "Font already installed or not available via Homebrew: $font"
                ((japanese_skipped++))
            fi
        else
            log_info "[DRY RUN] Would install font: $font"
            ((japanese_success++))
        fi
    done
    
    # 2024-2025年人気フォントをインストール
    log_info "Installing 2024-2025 popular programming fonts via Homebrew..."
    local popular_fonts=("cascadia-code" "jetbrains-mono")
    local popular_success=0
    local popular_failed=0
    local popular_skipped=0

    for font in "${popular_fonts[@]}"; do
        # Homebrewでのインストールのみ試行（簡素化）
        if [[ "$DRY_RUN" != "true" ]]; then
            log_info "Attempting to install popular font via Homebrew: $font"

            # Homebrewでインストール試行（既にインストール済みでもエラーにならない）
            if brew install --cask "font-$font" 2>/dev/null; then
                log_success "Font installed/updated successfully: $font"
                ((popular_success++))
            else
                log_info "Font already installed or not available via Homebrew: $font"
                ((popular_skipped++))
            fi
        else
            log_info "[DRY RUN] Would install popular font: $font"
            ((popular_success++))
        fi
    done

    # クラシックフォントも必要な場合（Homebrewのみ）
    log_info "Installing classic development fonts via Homebrew..."
    local classic_fonts=("fira-code" "source-code-pro")
    local classic_success=0
    local classic_failed=0
    local classic_skipped=0

    for font in "${classic_fonts[@]}"; do
        if [[ "$DRY_RUN" != "true" ]]; then
            log_info "Attempting to install font via Homebrew: $font"

            # Homebrewでインストール試行（既にインストール済みでもエラーにならない）
            if brew install --cask "font-$font" 2>/dev/null; then
                log_success "Font installed/updated successfully: $font"
                ((classic_success++))
            else
                log_info "Font already installed or not available via Homebrew: $font"
                ((classic_skipped++))
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
    local total_success=$((japanese_success + popular_success + classic_success))
    local total_skipped=$((japanese_skipped + popular_skipped + classic_skipped))
    local total_failed=$((japanese_failed + popular_failed + classic_failed))
    
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