#!/usr/bin/env bash

# Neovim Installer (Stable & Nightly)
# このスクリプトはNeovimのstable版とnightly版をインストールします

set -euo pipefail

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../lib/common.sh
source "$DOTFILES_DIR/bin/lib/common.sh"
# shellcheck source=../lib/config_loader.sh
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# プラットフォーム検出
PLATFORM=$(detect_platform)
ARCHITECTURE=$(detect_architecture)

# 定数定義
readonly INSTALL_DIR="$HOME/.local/bin"
readonly NIGHTLY_URL_BASE="https://github.com/neovim/neovim/releases/download/nightly"
readonly STABLE_URL_BASE="https://github.com/neovim/neovim/releases/latest/download"

# プラットフォーム別ダウンロードURL（nightly版）
get_nightly_download_url() {
    case "$PLATFORM" in
        "macos")
            if [[ "$ARCHITECTURE" == "arm64" ]]; then
                echo "$NIGHTLY_URL_BASE/nvim-macos-arm64.tar.gz"
            else
                echo "$NIGHTLY_URL_BASE/nvim-macos-x86_64.tar.gz"
            fi
            ;;
        "linux")
            echo "$NIGHTLY_URL_BASE/nvim-linux-x86_64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
}

# プラットフォーム別ダウンロードURL（stable版）
get_stable_download_url() {
    case "$PLATFORM" in
        "macos")
            if [[ "$ARCHITECTURE" == "arm64" ]]; then
                echo "$STABLE_URL_BASE/nvim-macos-arm64.tar.gz"
            else
                echo "$STABLE_URL_BASE/nvim-macos-x86_64.tar.gz"
            fi
            ;;
        "linux")
            echo "$STABLE_URL_BASE/nvim-linux-x86_64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            return 1
            ;;
    esac
}

# Neovimのインストール（共通処理）
install_neovim() {
    local version="$1"
    local binary_name="$2"
    local download_url="$3"
    
    log_info "Neovim ${version}版をインストールしています..."
    
    local temp_dir
    temp_dir=$(mktemp -d)
    local archive_name="nvim-${version}.tar.gz"
    local archive_path="$temp_dir/$archive_name"
    
    # ダウンロード
    log_info "ダウンロード中: $download_url"
    if ! curl -L -o "$archive_path" "$download_url"; then
        log_error "ダウンロードに失敗しました"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # 展開
    log_info "展開中..."
    cd "$temp_dir"
    if ! tar -xzf "$archive_path"; then
        log_error "展開に失敗しました"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # インストール
    mkdir -p "$INSTALL_DIR"
    
    case "$PLATFORM" in
        "macos")
            # macOS: nvim-macos-*/bin/nvim を指定名で配置
            local nvim_dir
            nvim_dir=$(find . -maxdepth 1 -name "nvim-macos-*" -type d | head -n1)
            if [[ -n "$nvim_dir" && -f "$nvim_dir/bin/nvim" ]]; then
                cp "$nvim_dir/bin/nvim" "$INSTALL_DIR/$binary_name"
                chmod +x "$INSTALL_DIR/$binary_name"
            else
                log_error "Neovim実行ファイルが見つかりません"
                rm -rf "$temp_dir"
                return 1
            fi
            ;;
        "linux")
            # Linux: nvim-linux-x86_64/bin/nvim を指定名で配置
            if [[ -f "nvim-linux-x86_64/bin/nvim" ]]; then
                cp "nvim-linux-x86_64/bin/nvim" "$INSTALL_DIR/$binary_name"
                chmod +x "$INSTALL_DIR/$binary_name"
            else
                log_error "Neovim実行ファイルが見つかりません"
                rm -rf "$temp_dir"
                return 1
            fi
            ;;
    esac
    
    # クリーンアップ
    rm -rf "$temp_dir"
    
    # インストール確認
    if command -v "$binary_name" >/dev/null 2>&1; then
        log_success "Neovim ${version}版のインストールが完了しました"
        log_info "インストール場所: $INSTALL_DIR/$binary_name"
        log_info "バージョン確認: $binary_name --version"
    else
        log_error "インストールに失敗しました"
        return 1
    fi
}

# Neovim stable版のインストール
install_neovim_stable() {
    local download_url
    download_url=$(get_stable_download_url)
    
    # 既存のnvim-stableバイナリをバックアップ
    if [[ -f "$INSTALL_DIR/nvim-stable" ]]; then
        log_info "既存のnvim-stableをバックアップしています..."
        mv "$INSTALL_DIR/nvim-stable" "$INSTALL_DIR/nvim-stable.bak"
    fi
    
    install_neovim "stable" "nvim-stable" "$download_url"
    
    # nvimコマンドがない場合、シンボリックリンクを作成
    if [[ ! -f "$INSTALL_DIR/nvim" ]]; then
        log_info "nvimコマンドのシンボリックリンクを作成しています..."
        ln -sf "$INSTALL_DIR/nvim-stable" "$INSTALL_DIR/nvim"
    fi
}

# Neovim nightly版のインストール
install_neovim_nightly() {
    local download_url
    download_url=$(get_nightly_download_url)
    
    install_neovim "nightly" "nvim-nightly" "$download_url"
}

# Neovimのアンインストール
uninstall_neovim() {
    local version="$1"
    local binary_name
    
    case "$version" in
        "stable")
            binary_name="nvim"
            ;;
        "nightly")
            binary_name="nvim-nightly"
            ;;
        *)
            log_error "無効なバージョンです: $version"
            return 1
            ;;
    esac
    
    log_info "Neovim ${version}版をアンインストールしています..."
    
    if [[ -f "$INSTALL_DIR/$binary_name" ]]; then
        rm "$INSTALL_DIR/$binary_name"
        log_success "Neovim ${version}版をアンインストールしました"
        
        # stable版の場合、バックアップがあれば復元
        if [[ "$version" == "stable" && -f "$INSTALL_DIR/nvim.bak" ]]; then
            log_info "バックアップからnvimを復元しています..."
            mv "$INSTALL_DIR/nvim.bak" "$INSTALL_DIR/nvim"
        fi
    else
        log_warn "Neovim ${version}版が見つかりません"
    fi
}

# 使用方法を表示
show_usage() {
    cat << EOF
Neovim Installer (Stable & Nightly)

使用方法:
    $(basename "$0") [COMMAND] [VERSION]

コマンド:
    install     Neovimをインストール
    uninstall   Neovimをアンインストール
    check       インストール状況を確認
    help        このヘルプを表示

バージョン:
    stable      安定版 (推奨: 初心者・仕事用)
    nightly     開発版 (推奨: 経験者・最新機能)

例:
    $(basename "$0") install stable
    $(basename "$0") install nightly
    $(basename "$0") uninstall stable
    $(basename "$0") uninstall nightly
    $(basename "$0") check
EOF
}

# インストール状況の確認
check_installation() {
    echo "=== Neovim Installation Status ==="
    
    # Stable版の確認
    if command -v nvim >/dev/null 2>&1; then
        echo "✓ Neovim stable版: インストール済み"
        echo "  パス: $(command -v nvim)"
        echo "  バージョン: $(nvim --version | head -n1)"
    else
        echo "✗ Neovim stable版: 未インストール"
    fi
    
    # Nightly版の確認
    if command -v nvim-nightly >/dev/null 2>&1; then
        echo "✓ Neovim nightly版: インストール済み"
        echo "  パス: $(command -v nvim-nightly)"
        echo "  バージョン: $(nvim-nightly --version | head -n1)"
    else
        echo "✗ Neovim nightly版: 未インストール"
    fi
    
    echo ""
    echo "インストールディレクトリ: $INSTALL_DIR"
    echo "プラットフォーム: $PLATFORM ($ARCHITECTURE)"
    
    # バックアップファイルの確認
    if [[ -f "$INSTALL_DIR/nvim.bak" ]]; then
        echo ""
        echo "📦 バックアップファイル:"
        echo "  nvim.bak: $(file "$INSTALL_DIR/nvim.bak" 2>/dev/null | cut -d: -f2)"
    fi
}

# バージョン一覧表示
show_versions() {
    echo "=== 利用可能なNeovimバージョン ==="
    echo "stable  - 安定版 (推奨: 初心者・仕事用)"
    echo "          最新の正式リリース版"
    echo "nightly - 開発版 (推奨: 経験者・最新機能)" 
    echo "          最新の開発版（毎日更新）"
    echo ""
    echo "使用方法:"
    echo "  $(basename "$0") install stable   # stable版をインストール"
    echo "  $(basename "$0") install nightly  # nightly版をインストール"
}

# メイン処理
main() {
    local command="${1:-help}"
    local version="${2:-}"
    
    case "$command" in
        "install")
            if [[ -z "$version" ]]; then
                log_error "バージョンを指定してください (stable または nightly)"
                show_versions
                exit 1
            fi
            
            case "$version" in
                "stable")
                    install_neovim_stable
                    ;;
                "nightly")
                    install_neovim_nightly
                    ;;
                *)
                    log_error "無効なバージョンです: $version"
                    show_versions
                    exit 1
                    ;;
            esac
            ;;
        "uninstall")
            if [[ -z "$version" ]]; then
                log_error "バージョンを指定してください (stable または nightly)"
                show_versions
                exit 1
            fi
            
            uninstall_neovim "$version"
            ;;
        "check")
            check_installation
            ;;
        "versions")
            show_versions
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "無効なコマンドです: $command"
            show_usage
            exit 1
            ;;
    esac
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi