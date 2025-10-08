#!/usr/bin/env bash

# fonts.sh - 統合フォント管理スクリプト
# クロスプラットフォーム対応（macOS, Linux）
# font_manager.sh ライブラリを使用

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

log_info "Starting unified font setup (cross-platform)..."

# Main function with unified skip logic
main() {
    log_info "Font Installation (Cross-Platform)"
    log_info "==================================="

    # Parse command line options
    parse_install_options "$@"

    # Check if font installation should be skipped
    if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then
        log_info "Font installation skipped (SKIP_FONT_INSTALL=1)"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install developer fonts"
        return 0
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install recommended fonts for developers
        log_info "Installing recommended fonts for developers..."
        install_recommended_fonts developer

        log_success "Font installation completed!"
    else
        log_info "[DRY RUN] Would install developer font set"
    fi

    return 0
}

# Run main function
main "$@"
