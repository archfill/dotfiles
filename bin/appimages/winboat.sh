#!/usr/bin/env bash

# WinBoat (Windows applications on Linux) AppImage管理スクリプト
# AppImage共通ライブラリを使用したシンプルな管理

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/appimage_manager.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# WinBoat設定
WINBOAT_REPO="TibixDev/winboat"
WINBOAT_APP_NAME="winboat"
WINBOAT_FILENAME_PATTERN="winboat-*-x86_64.AppImage"

log_info "Starting WinBoat (Windows for Penguins) setup..."

# =============================================================================
# 依存関係の自動インストール
# =============================================================================

install_winboat_dependencies() {
    log_info "Installing WinBoat dependencies..."

    local needs_install=false

    # FreeRDPのチェックとインストール (xfreerdp3 or xfreerdp)
    local freerdp_cmd=""
    if command -v xfreerdp3 >/dev/null 2>&1; then
        freerdp_cmd="xfreerdp3"
    elif command -v xfreerdp >/dev/null 2>&1; then
        freerdp_cmd="xfreerdp"
    fi

    if [[ -z "$freerdp_cmd" ]]; then
        log_info "Installing FreeRDP..."
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm freerdp || log_warning "Failed to install FreeRDP"
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y freerdp2-x11 || log_warning "Failed to install FreeRDP"
        else
            log_warning "Cannot automatically install FreeRDP - please install manually"
        fi
        needs_install=true
    else
        local freerdp_version
        freerdp_version=$($freerdp_cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local major_version="${freerdp_version%%.*}"

        if [[ "$major_version" -lt 3 ]]; then
            log_warning "FreeRDP 3.x required, found: $freerdp_version"
            log_info "Please upgrade FreeRDP manually"
        fi
    fi

    # カーネルモジュールのロード
    for module in iptable_nat; do
        if ! lsmod | grep -qw "^${module}"; then
            log_info "Loading kernel module: $module"
            if sudo modprobe "$module" 2>/dev/null; then
                log_success "Loaded kernel module: $module"

                # 永続化設定
                local modules_load_dir="/etc/modules-load.d"
                if [[ -d "$modules_load_dir" ]] && [[ ! -f "$modules_load_dir/winboat.conf" ]]; then
                    echo "$module" | sudo tee "$modules_load_dir/winboat.conf" >/dev/null
                    log_info "Module will be loaded automatically on boot"
                fi
            else
                log_warning "Failed to load kernel module: $module"
            fi
        fi
    done

    if [[ "$needs_install" == "true" ]]; then
        log_info "Dependencies installation completed"
    fi

    return 0
}

# =============================================================================
# システム要件チェック
# =============================================================================

check_winboat_requirements() {
    log_info "Checking WinBoat system requirements..."

    local requirements_met=true

    # AppImage共通要件チェック
    if ! appimage_check_requirements 2>/dev/null; then
        requirements_met=false
    fi

    # Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_warning "Docker not found (required for WinBoat)"
        log_info "Please install Docker manually: https://docs.docker.com/engine/install/"
        requirements_met=false
    else
        log_success "Docker found"

        # Docker Desktopチェック（非対応）
        if docker version 2>/dev/null | grep -qi "docker desktop"; then
            log_error "Docker Desktop detected - WinBoat requires standard Docker (not Docker Desktop)"
            requirements_met=false
        fi
    fi

    # Docker Compose v2
    if ! docker compose version >/dev/null 2>&1; then
        log_warning "Docker Compose v2 not found (required for WinBoat)"
        log_info "Docker Compose v2 is usually included with Docker Engine"
        requirements_met=false
    else
        log_success "Docker Compose v2 found"
    fi

    # FreeRDP 3.x (xfreerdp3 or xfreerdp)
    local freerdp_cmd=""
    if command -v xfreerdp3 >/dev/null 2>&1; then
        freerdp_cmd="xfreerdp3"
    elif command -v xfreerdp >/dev/null 2>&1; then
        freerdp_cmd="xfreerdp"
    fi

    if [[ -n "$freerdp_cmd" ]]; then
        local freerdp_version
        freerdp_version=$($freerdp_cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        local major_version="${freerdp_version%%.*}"

        if [[ "$major_version" -ge 3 ]]; then
            log_success "FreeRDP 3.x found: $freerdp_version ($freerdp_cmd)"
        else
            log_warning "FreeRDP 3.x required, found: $freerdp_version"
            requirements_met=false
        fi
    else
        log_warning "FreeRDP not found (will be installed)"
        requirements_met=false
    fi

    # KVM
    if [[ -e /dev/kvm ]]; then
        log_success "/dev/kvm found (KVM virtualization available)"
    else
        log_warning "/dev/kvm not found - KVM must be enabled in BIOS/UEFI"
        requirements_met=false
    fi

    # カーネルモジュール
    local modules_ok=true
    for module in iptable_nat; do
        if ! lsmod | grep -qw "^${module}"; then
            log_warning "Kernel module '$module' not loaded (will be loaded)"
            modules_ok=false
        fi
    done

    if [[ "$modules_ok" == "true" ]]; then
        log_success "Required kernel modules loaded"
    fi

    # /varの空き容量チェック
    local var_space_gb
    var_space_gb=$(df -BG /var 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')

    if [[ -n "$var_space_gb" ]] && [[ "$var_space_gb" -ge 32 ]]; then
        log_success "Sufficient disk space in /var: ${var_space_gb}GB"
    else
        log_warning "Insufficient disk space in /var: ${var_space_gb:-unknown}GB (32GB+ recommended)"
        requirements_met=false
    fi

    if [[ "$requirements_met" == "false" ]]; then
        log_error "Some system requirements are not met"
        return 1
    fi

    log_success "All system requirements satisfied"
    return 0
}

# =============================================================================
# メイン処理関数
# =============================================================================

install_winboat() {
    log_info "Installing WinBoat..."

    # Linuxチェック
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_error "WinBoat is only supported on Linux"
        return 1
    fi

    # 初回チェック
    if ! check_winboat_requirements; then
        log_info "Attempting to install missing dependencies..."

        # 依存関係の自動インストール
        install_winboat_dependencies

        # 再チェック
        log_info ""
        log_info "Re-checking system requirements after dependency installation..."
        if ! check_winboat_requirements; then
            log_error "System requirements check failed"
            log_info "Please manually install missing dependencies:"
            log_info "  - Docker: https://docs.docker.com/engine/install/"
            log_info "  - FreeRDP 3.x: pacman -S freerdp (Arch) or apt install freerdp2-x11 (Debian/Ubuntu)"
            log_info "  - Enable KVM in BIOS/UEFI settings"
            return 1
        fi
    fi

    # AppImage共通インストール処理
    local version="${WINBOAT_VERSION:-latest}"
    appimage_install "$WINBOAT_REPO" "$WINBOAT_APP_NAME" "$version" "$WINBOAT_FILENAME_PATTERN"
}

update_winboat() {
    log_info "Updating WinBoat..."
    appimage_update "$WINBOAT_REPO" "$WINBOAT_APP_NAME" "$WINBOAT_FILENAME_PATTERN"
}

uninstall_winboat() {
    log_info "Uninstalling WinBoat..."
    appimage_uninstall "$WINBOAT_APP_NAME"

    log_info ""
    log_info "Note: This script does not remove Docker, FreeRDP, or other system dependencies"
    log_info "To fully remove WinBoat-related containers, run: docker container prune"
    log_info "To remove WinBoat Docker images, run: docker image prune -a"
}

show_status() {
    appimage_status "$WINBOAT_REPO" "$WINBOAT_APP_NAME"

    log_info ""
    log_info "System Requirements:"
    check_winboat_requirements || true
}

# =============================================================================
# メイン関数
# =============================================================================

main() {
    local command="${1:-install}"
    shift || true

    case "$command" in
        install)
            log_info "WinBoat (Windows for Penguins) Installation"
            log_info "==========================================="
            log_info ""

            if install_winboat "$@"; then
                log_success "WinBoat setup completed!"
                log_info ""
                log_info "Usage:"
                log_info "  ${WINBOAT_APP_NAME}              # Launch WinBoat"
                log_info ""
                log_info "Management commands:"
                log_info "  $0 update           # Update to latest version"
                log_info "  $0 uninstall        # Uninstall WinBoat"
                log_info "  $0 status           # Show installation status"
                log_info ""
                log_info "Documentation: https://winboat.app"
                log_info "Discord: https://discord.gg/MEwmpWm4tN"
            fi
            ;;

        update)
            update_winboat "$@"
            ;;

        uninstall)
            uninstall_winboat "$@"
            ;;

        status)
            show_status "$@"
            ;;

        *)
            log_error "Unknown command: $command"
            log_info ""
            log_info "Usage: $0 {install|update|uninstall|status}"
            log_info ""
            log_info "Commands:"
            log_info "  install     Install WinBoat AppImage"
            log_info "  update      Update to latest version"
            log_info "  uninstall   Uninstall WinBoat"
            log_info "  status      Show installation status and system requirements"
            exit 1
            ;;
    esac
}

# メイン関数を実行
main "$@"
