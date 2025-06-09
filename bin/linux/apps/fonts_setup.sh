#!/usr/bin/env bash

# Linux用モダンフォントセットアップスクリプト
# 新しいfont_managerライブラリを使用した統一フォント管理

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/common.sh"
source "${SCRIPT_DIR}/../../lib/font_manager.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting Linux font setup using modern font manager..."

# 推奨フォントセットのインストール
# 開発者向けプロファイル：JetBrains Mono NF, HackGen NF, PlemolJP
if install_recommended_fonts "developer"; then
    log_success "Developer font profile installed successfully"
else
    log_warning "Some fonts in developer profile failed to install"
fi

# 追加で日本語フォントも必要な場合はUDEV Gothicを追加
if install_font "udev-gothic"; then
    log_success "UDEV Gothic installed successfully"
else
    log_warning "UDEV Gothic installation failed"
fi

# インストール状況の確認
log_info "Current font installation status:"
list_installed_fonts

log_success "Linux font setup completed"
