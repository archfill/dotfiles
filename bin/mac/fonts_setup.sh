#!/usr/bin/env bash

# macOS用モダンフォントセットアップスクリプト
# 新しいfont_managerライブラリを使用した統一フォント管理

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"
source "${SCRIPT_DIR}/../lib/font_manager.sh"

# エラーハンドリングを設定
setup_error_handling

log_info "Starting macOS font setup using modern font manager..."

# Homebrew cask-fonts tapが追加されているか確認
if command -v brew >/dev/null 2>&1; then
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        log_info "Adding homebrew/cask-fonts tap..."
        brew tap homebrew/cask-fonts
    fi
else
    log_warning "Homebrew not found, fonts will be installed from GitHub releases"
fi

# 推奨フォントセットのインストール
# 開発者向けプロファイル：JetBrains Mono NF, HackGen NF, PlemolJP
if install_recommended_fonts "developer"; then
    log_success "Developer font profile installed successfully"
else
    log_warning "Some fonts in developer profile failed to install"
fi

# 追加で日本語フォントセットをインストール
log_info "Installing additional Japanese fonts..."
japanese_fonts=("udev-gothic" "cica")

for font in "${japanese_fonts[@]}"; do
    if install_font "$font"; then
        log_success "$font installed successfully"
    else
        log_warning "$font installation failed"
    fi
done

# クラシックフォントも必要な場合
log_info "Installing classic development fonts..."
classic_fonts=("fira-code" "source-code-pro")

for font in "${classic_fonts[@]}"; do
    if install_font "$font"; then
        log_success "$font installed successfully"
    else
        log_warning "$font installation failed"
    fi
done

# インストール状況の確認
log_info "Current font installation status:"
list_installed_fonts

log_success "macOS font setup completed"
log_info "Please restart applications to see new fonts"