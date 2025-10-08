#!/usr/bin/env bash

# Neovim AppImage管理スクリプト（Linux専用）
# stable/nightly版を管理し、AppImage共通ライブラリを活用
# macOS用は bin/installers/neovim.sh を使用してください

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/appimage_manager.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# Neovim設定
NVIM_REPO="neovim/neovim"
NVIM_APP_NAME="neovim"

# =============================================================================
# プラットフォームチェック
# =============================================================================

check_platform() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_error "This script is for Linux only (AppImage)"
        log_info "For macOS, use: bin/installers/neovim.sh"
        exit 1
    fi
}

# =============================================================================
# AppImageファイル名パターン取得
# =============================================================================

get_appimage_pattern() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64)
            echo "nvim-linux-x86_64.appimage"
            ;;
        aarch64|arm64)
            echo "nvim-linux-arm64.appimage"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
}

# =============================================================================
# Neovimインストール関数
# =============================================================================

install_neovim() {
    local version="${1:-stable}"  # stable or nightly

    check_platform

    log_info "Installing Neovim $version for Linux (AppImage)..."

    local pattern
    pattern=$(get_appimage_pattern) || return 1

    # バージョンに応じたダウンロードURL取得
    local api_version
    local download_url

    if [[ "$version" == "stable" ]]; then
        log_info "Fetching latest stable version..."
        api_version=$(appimage_get_latest_version "$NVIM_REPO" "true")
        if [[ $? -ne 0 ]] || [[ -z "$api_version" ]]; then
            log_error "Failed to get latest stable version"
            return 1
        fi
        log_info "Latest stable version: v${api_version}"
        download_url="https://github.com/neovim/neovim/releases/download/v${api_version}/${pattern}"
    else
        # nightlyの場合
        api_version="nightly"
        download_url="https://github.com/neovim/neovim/releases/download/nightly/${pattern}"
    fi

    # AppImageディレクトリとファイル名
    local app_dir="${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}"
    local appimage_filename="nvim-${version}.appimage"
    local install_path="${app_dir}/${appimage_filename}"

    # ダウンロード
    mkdir -p "$app_dir"
    if ! appimage_download "$download_url" "$install_path"; then
        return 1
    fi

    # シンボリックリンク作成
    local symlink_name="nvim-${version}"
    appimage_create_symlink "$install_path" "$symlink_name"

    # メタデータ保存
    appimage_save_metadata "${NVIM_APP_NAME}-${version}" "$api_version" "$download_url" "$appimage_filename"

    log_success "Neovim $version installed successfully"
    log_info "Command: $symlink_name"

    return 0
}

# デフォルトのnvimシンボリックリンクを設定
set_default_nvim() {
    local version="${1:-nightly}"  # stable or nightly

    check_platform

    local nvim_bin="${APPIMAGE_BIN_DIR}/nvim-${version}"
    local default_link="${APPIMAGE_BIN_DIR}/nvim"

    if [[ ! -e "$nvim_bin" ]]; then
        log_error "Neovim $version is not installed: $nvim_bin"
        return 1
    fi

    # 既存のリンク/ファイルを削除
    rm -f "$default_link"

    # 相対パスでシンボリックリンク作成
    local relative_path
    relative_path=$(realpath --relative-to="$APPIMAGE_BIN_DIR" "$nvim_bin" 2>/dev/null || echo "nvim-${version}")

    ln -s "$relative_path" "$default_link"
    log_success "Default nvim set to: $version"
    log_info "nvim -> $relative_path"
}

# =============================================================================
# 更新・アンインストール関数
# =============================================================================

update_neovim() {
    local version="${1:-}"  # stable, nightly, or empty (both)

    check_platform

    # 引数なしの場合は両方を更新（一括操作用）
    if [[ -z "$version" ]]; then
        log_info "Updating all installed Neovim versions..."
        local updated=false

        # stable版が存在すれば更新（実行可能ファイルまたはシンボリックリンクをチェック）
        if [[ -x "${APPIMAGE_BIN_DIR}/nvim-stable" ]] || \
           [[ -f "${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}/nvim-stable.appimage" ]]; then
            log_info "Updating Neovim stable..."
            install_neovim "stable"
            updated=true
        fi

        # nightly版が存在すれば更新
        if [[ -x "${APPIMAGE_BIN_DIR}/nvim-nightly" ]] || \
           [[ -f "${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}/nvim-nightly.appimage" ]]; then
            log_info "Updating Neovim nightly..."
            install_neovim "nightly"
            updated=true
        fi

        if [[ "$updated" == "false" ]]; then
            log_info "No Neovim versions installed to update"
        fi
    else
        log_info "Updating Neovim $version..."
        install_neovim "$version"
    fi
}

uninstall_neovim() {
    local version="${1:-all}"  # stable, nightly, or all

    check_platform

    if [[ "$version" == "all" ]]; then
        log_info "Uninstalling all Neovim versions..."

        # stable版
        local app_dir="${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}"
        rm -f "${app_dir}/nvim-stable.appimage"
        rm -f "${APPIMAGE_BIN_DIR}/nvim-stable"
        rm -rf "${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}-stable"

        # nightly版
        rm -f "${app_dir}/nvim-nightly.appimage"
        rm -f "${APPIMAGE_BIN_DIR}/nvim-nightly"
        rm -rf "${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}-nightly"

        # デフォルトシンボリックリンク
        rm -f "${APPIMAGE_BIN_DIR}/nvim"

        # 空になったディレクトリを削除
        if [[ -d "$app_dir" ]] && [[ -z "$(ls -A "$app_dir")" ]]; then
            rm -rf "$app_dir"
        fi

        log_success "All Neovim versions uninstalled"
    else
        log_info "Uninstalling Neovim $version..."
        local symlink_name="nvim-${version}"

        # AppImageファイル削除
        local app_dir="${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}"
        local appimage_file="${app_dir}/nvim-${version}.appimage"

        if [[ -f "$appimage_file" ]]; then
            rm -f "$appimage_file"
            log_info "Removed: $appimage_file"
        fi

        # シンボリックリンク削除
        local symlink_path="${APPIMAGE_BIN_DIR}/${symlink_name}"
        if [[ -L "$symlink_path" ]]; then
            rm -f "$symlink_path"
            log_info "Removed symlink: $symlink_path"
        fi

        # メタデータ削除
        local metadata_dir="${APPIMAGE_INSTALL_DIR}/${NVIM_APP_NAME}-${version}"
        if [[ -d "$metadata_dir" ]]; then
            rm -rf "$metadata_dir"
            log_info "Removed metadata: $metadata_dir"
        fi

        log_success "Neovim $version uninstalled"
    fi
}

check_version() {
    local version="${1:-stable}"

    check_platform

    local bin_path="${APPIMAGE_BIN_DIR}/nvim-${version}"

    if [[ -x "$bin_path" ]]; then
        log_info "Neovim $version version:"
        "$bin_path" --version | head -3
        return 0
    else
        log_info "Neovim $version is not installed"
        return 1
    fi
}

show_status() {
    check_platform

    log_info "Neovim Installation Status (Linux AppImage)"
    log_info "$(printf '=%.0s' {1..50})"
    log_info ""

    # Stable版
    log_info "Stable version:"
    if check_version "stable" >/dev/null 2>&1; then
        local stable_version
        stable_version=$("${APPIMAGE_BIN_DIR}/nvim-stable" --version 2>/dev/null | head -1 || echo "unknown")
        log_success "  Installed: $stable_version"
    else
        log_info "  Not installed"
    fi

    log_info ""

    # Nightly版
    log_info "Nightly version:"
    if check_version "nightly" >/dev/null 2>&1; then
        local nightly_version
        nightly_version=$("${APPIMAGE_BIN_DIR}/nvim-nightly" --version 2>/dev/null | head -1 || echo "unknown")
        log_success "  Installed: $nightly_version"
    else
        log_info "  Not installed"
    fi

    log_info ""

    # デフォルト設定
    local default_link="${APPIMAGE_BIN_DIR}/nvim"
    if [[ -L "$default_link" ]]; then
        local target
        target=$(readlink "$default_link")
        log_info "Default nvim: $target"
    else
        log_info "Default nvim: Not set"
    fi
}

# =============================================================================
# メイン関数
# =============================================================================

main() {
    local command="${1:-install}"
    shift || true

    case "$command" in
        install)
            local version="${1:-stable}"
            log_info "Neovim Installation (Linux AppImage)"
            log_info "====================================="
            log_info ""

            if install_neovim "$version"; then
                log_success "Neovim $version installed successfully!"
                log_info ""
                log_info "Set as default: $0 default $version"
                log_info "Check version:  nvim-$version --version"
                log_info ""
                log_info "Note: For macOS, use bin/installers/neovim.sh"
            fi
            ;;

        install-both)
            log_info "Installing both stable and nightly versions..."
            install_neovim "stable" && install_neovim "nightly"
            ;;

        update)
            local version="${1:-}"  # 引数なし=両方更新
            update_neovim "$version"
            ;;

        uninstall)
            local version="${1:-all}"
            uninstall_neovim "$version"
            ;;

        default)
            local version="${1:-nightly}"
            set_default_nvim "$version"
            ;;

        status)
            show_status
            ;;

        version)
            local version="${1:-stable}"
            check_version "$version"
            ;;

        *)
            log_error "Unknown command: $command"
            log_info ""
            log_info "Usage: $0 {install|install-both|update|uninstall|default|status|version} [stable|nightly]"
            log_info ""
            log_info "Commands:"
            log_info "  install [stable|nightly]   Install Neovim AppImage (default: stable)"
            log_info "  install-both               Install both stable and nightly"
            log_info "  update [stable|nightly]    Update Neovim (default: stable)"
            log_info "  uninstall [stable|nightly|all]  Uninstall Neovim (default: all)"
            log_info "  default [stable|nightly]   Set default nvim symlink (default: nightly)"
            log_info "  status                     Show installation status"
            log_info "  version [stable|nightly]   Check installed version"
            log_info ""
            log_info "Note: This script is for Linux only (AppImage)"
            log_info "      For macOS, use: bin/installers/neovim.sh"
            exit 1
            ;;
    esac
}

# メイン関数を実行
main "$@"
