#!/usr/bin/env bash
# neovim_installer.sh
# Neovim stable/nightly版インストーラー
# AppImageまたはプリビルドバイナリを使用

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# ===== 定数定義 =====
readonly NVIM_BIN_DIR="$HOME/.local/bin"
readonly NVIM_STABLE_BIN="$NVIM_BIN_DIR/nvim-stable"
readonly NVIM_NIGHTLY_BIN="$NVIM_BIN_DIR/nvim-nightly"
readonly NVIM_DOWNLOAD_DIR="$HOME/.local/share/nvim-downloads"

# GitHub Release URLs
readonly STABLE_RELEASE_URL="https://github.com/neovim/neovim/releases/latest/download"
readonly NIGHTLY_RELEASE_URL="https://github.com/neovim/neovim/releases/download/nightly"

# ===== プラットフォーム検出 =====
detect_platform_architecture() {
    local platform=""
    local arch=""

    case "$(uname -s)" in
        Darwin*)
            platform="macos"
            arch=$(uname -m)
            ;;
        Linux*)
            platform="linux"
            arch=$(uname -m)
            ;;
        *)
            log_error "Unsupported platform: $(uname -s)"
            return 1
            ;;
    esac

    echo "${platform}:${arch}"
}

# ===== ダウンロードURL生成 =====
get_download_url() {
    local version="$1"  # stable or nightly
    local platform_arch
    platform_arch=$(detect_platform_architecture) || return 1

    local platform="${platform_arch%%:*}"
    local arch="${platform_arch##*:}"

    # Linux用のAppImageを使用
    if [[ "$platform" == "linux" ]]; then
        local appimage_name=""
        if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
            appimage_name="nvim-linux-arm64.appimage"
        else
            appimage_name="nvim-linux-x86_64.appimage"
        fi

        if [[ "$version" == "stable" ]]; then
            echo "https://github.com/neovim/neovim/releases/latest/download/${appimage_name}"
        else
            echo "https://github.com/neovim/neovim/releases/download/nightly/${appimage_name}"
        fi
        return 0
    fi

    # macOS用はtar.gzを使用
    local base_url=""
    if [[ "$version" == "stable" ]]; then
        base_url="$STABLE_RELEASE_URL"
    else
        base_url="$NIGHTLY_RELEASE_URL"
    fi

    case "$platform:$arch" in
        macos:x86_64)
            echo "${base_url}/nvim-macos-x86_64.tar.gz"
            ;;
        macos:arm64)
            echo "${base_url}/nvim-macos-arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform/architecture: $platform:$arch"
            return 1
            ;;
    esac
}

# ===== バイナリのダウンロードとインストール =====
download_and_install() {
    local version="$1"
    local download_url
    download_url=$(get_download_url "$version") || return 1

    log_info "Downloading Neovim $version from: $download_url"

    # ダウンロードディレクトリ作成
    mkdir -p "$NVIM_DOWNLOAD_DIR"
    mkdir -p "$NVIM_BIN_DIR"

    local platform_arch
    platform_arch=$(detect_platform_architecture) || return 1
    local platform="${platform_arch%%:*}"

    # バイナリの配置先
    local target_bin=""
    if [[ "$version" == "stable" ]]; then
        target_bin="$NVIM_STABLE_BIN"
    else
        target_bin="$NVIM_NIGHTLY_BIN"
    fi

    # Linux: AppImageを直接ダウンロード
    if [[ "$platform" == "linux" ]]; then
        local appimage_file="$NVIM_DOWNLOAD_DIR/nvim-${version}.appimage"

        # 既存のファイルを削除
        rm -f "$appimage_file"

        # ダウンロード
        if ! curl -L -o "$appimage_file" "$download_url"; then
            log_error "Failed to download Neovim $version AppImage"
            return 1
        fi

        log_success "Downloaded AppImage to: $appimage_file"

        # 既存のバイナリを削除
        rm -f "$target_bin"

        # AppImageをコピーして実行可能にする
        cp "$appimage_file" "$target_bin"
        chmod +x "$target_bin"

        # クリーンアップ
        rm -f "$appimage_file"

    # macOS: tar.gzをダウンロード・展開
    else
        local archive_file="$NVIM_DOWNLOAD_DIR/nvim-${version}.tar.gz"
        local extract_dir="$NVIM_DOWNLOAD_DIR/nvim-${version}-extracted"

        # 既存のファイルを削除
        rm -rf "$archive_file" "$extract_dir"

        # ダウンロード
        if ! curl -L -o "$archive_file" "$download_url"; then
            log_error "Failed to download Neovim $version"
            return 1
        fi

        log_success "Downloaded to: $archive_file"

        # 展開
        log_info "Extracting archive..."
        mkdir -p "$extract_dir"
        if ! tar -xzf "$archive_file" -C "$extract_dir" --strip-components=1; then
            log_error "Failed to extract archive"
            return 1
        fi

        if [[ ! -f "$extract_dir/bin/nvim" ]]; then
            log_error "nvim binary not found in extracted archive"
            return 1
        fi

        # 既存のバイナリを削除
        rm -f "$target_bin"

        # バイナリをコピー
        cp "$extract_dir/bin/nvim" "$target_bin"
        chmod +x "$target_bin"

        # 共有ライブラリとランタイムファイルもコピー
        local nvim_runtime_dir="$HOME/.local/share/nvim-${version}"
        rm -rf "$nvim_runtime_dir"
        mkdir -p "$nvim_runtime_dir"

        # runtimeディレクトリをコピー
        if [[ -d "$extract_dir/share/nvim/runtime" ]]; then
            cp -r "$extract_dir/share/nvim/runtime" "$nvim_runtime_dir/"
        fi

        # libディレクトリをコピー（必要な場合）
        if [[ -d "$extract_dir/lib" ]]; then
            cp -r "$extract_dir/lib" "$nvim_runtime_dir/"
        fi

        # クリーンアップ
        rm -rf "$archive_file" "$extract_dir"
    fi

    log_info "Installing to: $target_bin"

    # バージョン確認
    if [[ -x "$target_bin" ]]; then
        local installed_version=$("$target_bin" --version 2>/dev/null | head -1 || echo "Unknown")
        log_success "Installed Neovim $version: $installed_version"
        log_info "Binary location: $target_bin"
        return 0
    else
        log_error "Installation failed: binary not executable"
        return 1
    fi
}

# ===== バージョン確認 =====
check_version() {
    local version="$1"
    local bin_path=""

    if [[ "$version" == "stable" ]]; then
        bin_path="$NVIM_STABLE_BIN"
    else
        bin_path="$NVIM_NIGHTLY_BIN"
    fi

    if [[ -x "$bin_path" ]]; then
        log_info "Neovim $version version:"
        "$bin_path" --version | head -3
        return 0
    else
        log_info "Neovim $version is not installed"
        return 1
    fi
}

# ===== アンインストール =====
uninstall() {
    local version="$1"
    local bin_path=""
    local runtime_dir=""

    if [[ "$version" == "stable" ]]; then
        bin_path="$NVIM_STABLE_BIN"
        runtime_dir="$HOME/.local/share/nvim-stable"
    else
        bin_path="$NVIM_NIGHTLY_BIN"
        runtime_dir="$HOME/.local/share/nvim-nightly"
    fi

    log_info "Uninstalling Neovim $version..."

    if [[ -f "$bin_path" ]]; then
        rm -f "$bin_path"
        log_success "Removed binary: $bin_path"
    fi

    if [[ -d "$runtime_dir" ]]; then
        rm -rf "$runtime_dir"
        log_success "Removed runtime: $runtime_dir"
    fi

    log_success "Neovim $version uninstalled"
}

# ===== ステータス表示 =====
show_status() {
    echo "=== Neovim Installer Status ==="
    echo ""

    for version in stable nightly; do
        echo "[$version]"
        if check_version "$version" 2>/dev/null; then
            echo ""
        else
            echo "  Not installed"
            echo ""
        fi
    done
}

# ===== メイン処理 =====
main() {
    local command="${1:-}"
    local version="${2:-}"

    case "$command" in
        "install")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            if [[ "$version" != "stable" && "$version" != "nightly" ]]; then
                log_error "Invalid version: $version (use stable or nightly)"
                exit 1
            fi

            download_and_install "$version"
            ;;
        "uninstall")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            uninstall "$version"
            ;;
        "check")
            if [[ -z "$version" ]]; then
                log_error "Version required: stable or nightly"
                exit 1
            fi

            check_version "$version"
            ;;
        "status")
            show_status
            ;;
        *)
            cat << 'EOF'
Neovim Installer (stable/nightly versions)

Usage: neovim_installer.sh [COMMAND] [VERSION]

Commands:
  install <version>    Download and install Neovim (stable or nightly)
  uninstall <version>  Uninstall Neovim version
  check <version>      Check installed version
  status               Show installation status

Examples:
  neovim_installer.sh install stable
  neovim_installer.sh install nightly
  neovim_installer.sh check stable
  neovim_installer.sh status
EOF
            exit 1
            ;;
    esac
}

main "$@"
