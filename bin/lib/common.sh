#!/usr/bin/env bash

# 共通ライブラリ - dotfiles共通関数
# このファイルは他のスクリプトからsourceして使用する

# エラーハンドリングの共通設定
setup_error_handling() {
    set -euo pipefail
    trap 'echo "[Error] Command \"$BASH_COMMAND\" failed at line $LINENO in ${BASH_SOURCE[0]}"; exit 1' ERR
}

# ログ出力用の共通関数
log_info() {
    echo "[Info] $*"
}

log_success() {
    echo "[Success] $*"
}

log_warning() {
    echo "[Warning] $*"
}

log_error() {
    echo "[Error] $*" >&2
}

# プラットフォーム検出の共通関数群

# 基本プラットフォーム検出
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*)    echo "cygwin" ;;
        *)          echo "unknown" ;;
    esac
}

# アーキテクチャ検出（get_os_bitと互換性維持）
get_os_bit() {
    uname -m
}

# 詳細なアーキテクチャ情報
detect_architecture() {
    local arch
    arch="$(uname -m)"
    
    case "$arch" in
        x86_64|amd64)   echo "x86_64" ;;
        arm64|aarch64)  echo "arm64" ;;
        armv7l)         echo "armv7" ;;
        i386|i686)      echo "i386" ;;
        *)              echo "$arch" ;;
    esac
}

# Linuxディストリビューション検出（get_os_distributionと互換性維持）
get_os_distribution() {
    local distri_name="unknown"

    if [[ -e /etc/lsb-release ]]; then
        distri_name="ubuntu"
    elif [[ -e /etc/debian_version || -e /etc/debian_release ]]; then
        distri_name="debian"
    elif [[ -e /etc/fedora-release ]]; then
        distri_name="fedora"
    elif [[ -e /etc/oracle-release ]]; then
        distri_name="oracle"
    elif [[ -e /etc/redhat-release ]]; then
        distri_name="redhat"
    elif [[ -e /etc/arch-release ]]; then
        distri_name="arch"
    elif [[ -e /etc/SuSE-release ]]; then
        distri_name="suse"
    elif [[ -e /etc/mandriva-release ]]; then
        distri_name="mandriva"
    elif [[ -e /etc/vine-release ]]; then
        distri_name="vine"
    elif [[ -e /etc/gentoo-release ]]; then
        distri_name="gentoo"
    fi

    echo "${distri_name}"
}

# 従来のget_os_info関数（互換性維持）
get_os_info() {
    echo "$(get_os_distribution) $(get_os_bit)"
}

# 詳細なプラットフォーム情報
detect_detailed_platform() {
    local platform arch distro
    platform="$(detect_platform)"
    arch="$(detect_architecture)"
    
    if [[ "$platform" == "linux" ]]; then
        distro="$(get_os_distribution)"
        echo "$platform:$distro:$arch"
    else
        echo "$platform:$arch"
    fi
}

# プラットフォーム固有の処理判定
is_macos() {
    [[ "$(detect_platform)" == "macos" ]]
}

is_linux() {
    [[ "$(detect_platform)" == "linux" ]]
}

is_cygwin() {
    [[ "$(detect_platform)" == "cygwin" ]]
}

is_termux() {
    [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]
}

is_x86_64() {
    [[ "$(detect_architecture)" == "x86_64" ]]
}

is_arm64() {
    [[ "$(detect_architecture)" == "arm64" ]]
}

# パッケージマネージャー検出
detect_package_manager() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# ファイル存在チェック
check_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_error "Required file not found: $file"
        return 1
    fi
}

# ディレクトリ存在チェック
check_dir_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        log_error "Required directory not found: $dir"
        return 1
    fi
}

# コマンド存在チェック
check_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Required command not found: $cmd"
        return 1
    fi
}