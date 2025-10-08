#!/usr/bin/env bash

# appimage-manager.sh
# AppImage一括管理スクリプト
# bin/appimages/配下の全AppImageを管理

# 共有ライブラリの読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/config_loader.sh"
source "$DOTFILES_DIR/bin/lib/appimage_manager.sh"

# エラーハンドリングの設定
setup_error_handling

# 設定の読み込み
load_config

# =============================================================================
# AppImageスクリプト検出
# =============================================================================

# 利用可能なAppImageスクリプトを取得
get_available_apps() {
    local apps=()
    for script in "$DOTFILES_DIR/bin/install-methods/appimage"/*.sh; do
        if [[ -f "$script" ]]; then
            local app_name
            app_name=$(basename "$script" .sh)
            apps+=("$app_name")
        fi
    done
    echo "${apps[@]}"
}

# AppImageスクリプトのパスを取得
get_app_script() {
    local app_name="$1"
    echo "$DOTFILES_DIR/bin/install-methods/appimage/${app_name}.sh"
}

# =============================================================================
# 一括操作
# =============================================================================

# 全AppImageのステータス表示
list_all() {
    log_info "Available AppImage Applications:"
    log_info "$(printf '=%.0s' {1..50})"
    log_info ""

    local apps
    apps=($(get_available_apps))

    if [[ ${#apps[@]} -eq 0 ]]; then
        log_info "No AppImage scripts found in bin/install-methods/appimage/"
        return 0
    fi

    for app in "${apps[@]}"; do
        local script
        script=$(get_app_script "$app")

        if [[ -x "$script" ]]; then
            log_info "📦 $app"
            log_info "   Script: bin/install-methods/appimage/${app}.sh"

            # ステータス取得（エラーは無視）
            if "$script" status >/dev/null 2>&1; then
                log_success "   Status: Available"
            else
                log_info "   Status: Not installed"
            fi
            log_info ""
        fi
    done
}

# インストール済みAppImageの一覧
list_installed() {
    log_info "Installed AppImages:"
    log_info "$(printf '=%.0s' {1..50})"
    log_info ""

    appimage_list_installed
}

# 全AppImageをインストール
install_all() {
    log_info "Installing all available AppImages..."
    log_info ""

    local apps
    apps=($(get_available_apps))

    if [[ ${#apps[@]} -eq 0 ]]; then
        log_warning "No AppImage scripts found"
        return 0
    fi

    local installed_count=0
    local failed_count=0
    local skipped_count=0

    # 一時的にエラー時の自動終了を無効化
    set +e

    for app in "${apps[@]}"; do
        local script
        script=$(get_app_script "$app")

        if [[ ! -x "$script" ]]; then
            log_warning "Script not executable: $script"
            continue
        fi

        log_info "Installing $app..."

        # installコマンドを実行
        if "$script" install; then
            ((installed_count++))
            log_success "$app: Installation completed"
        else
            ((failed_count++))
            log_warning "$app: Installation failed"
        fi

        log_info ""
    done

    # エラー時の自動終了を再有効化
    set -e

    log_info "Installation summary:"
    log_info "  Total: ${#apps[@]} app(s)"
    log_success "  Installed: $installed_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "  Failed: $failed_count"
    fi

    return 0
}

# 全AppImageを更新
update_all() {
    log_info "Updating all installed AppImages..."
    log_info ""

    local apps
    apps=($(get_available_apps))

    if [[ ${#apps[@]} -eq 0 ]]; then
        log_warning "No AppImage scripts found"
        return 0
    fi

    local updated_count=0
    local failed_count=0

    # 一時的にエラー時の自動終了を無効化
    set +e

    for app in "${apps[@]}"; do
        local script
        script=$(get_app_script "$app")

        if [[ ! -x "$script" ]]; then
            log_warning "Script not executable: $script"
            continue
        fi

        log_info "Checking $app..."

        # updateコマンドを実行（エラーチェック付き）
        if "$script" update; then
            ((updated_count++))
            log_success "$app: Update completed"
        else
            ((failed_count++))
            log_warning "$app: Update failed or not installed"
        fi

        log_info ""
    done

    # エラー時の自動終了を再有効化
    set -e

    log_info "Update summary:"
    log_info "  Checked: ${#apps[@]} app(s)"
    log_success "  Updated: $updated_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "  Failed/Skipped: $failed_count"
    fi

    return 0
}

# 全AppImageをアンインストール
uninstall_all() {
    log_info "Uninstalling all AppImages..."
    log_warning "This will remove ALL installed AppImages!"
    log_info ""

    local apps
    apps=($(get_available_apps))

    if [[ ${#apps[@]} -eq 0 ]]; then
        log_warning "No AppImage scripts found"
        return 0
    fi

    local uninstalled_count=0
    local failed_count=0

    # 一時的にエラー時の自動終了を無効化
    set +e

    for app in "${apps[@]}"; do
        local script
        script=$(get_app_script "$app")

        if [[ ! -x "$script" ]]; then
            log_warning "Script not executable: $script"
            continue
        fi

        log_info "Uninstalling $app..."

        # uninstallコマンドを実行
        if "$script" uninstall; then
            ((uninstalled_count++))
            log_success "$app: Uninstallation completed"
        else
            ((failed_count++))
            log_warning "$app: Uninstallation failed or not installed"
        fi

        log_info ""
    done

    # エラー時の自動終了を再有効化
    set -e

    log_info "Uninstallation summary:"
    log_info "  Total: ${#apps[@]} app(s)"
    log_success "  Uninstalled: $uninstalled_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "  Failed/Skipped: $failed_count"
    fi

    return 0
}

# 特定のAppImageを操作
manage_app() {
    local command="$1"
    local app_name="$2"

    if [[ -z "$app_name" ]]; then
        log_error "App name required"
        show_usage
        return 1
    fi

    local script
    script=$(get_app_script "$app_name")

    if [[ ! -f "$script" ]]; then
        log_error "AppImage script not found: $app_name"
        log_info "Available apps: $(get_available_apps)"
        return 1
    fi

    if [[ ! -x "$script" ]]; then
        log_error "Script not executable: $script"
        return 1
    fi

    # スクリプトを実行
    "$script" "$command"
}

# =============================================================================
# ヘルプ表示
# =============================================================================

show_usage() {
    cat << 'EOF'
AppImage Manager - Unified AppImage management tool

Usage: appimage-manager.sh <command> [app-name]

Batch Commands:
  list                List all available AppImage scripts
  list-installed      List installed AppImages with details
  install-all         Install all available AppImages
  update-all          Update all installed AppImages
  uninstall-all       Uninstall all AppImages

Individual Commands:
  install <app>       Install specific AppImage
  update <app>        Update specific AppImage
  uninstall <app>     Uninstall specific AppImage
  status <app>        Show status of specific AppImage

Examples:
  appimage-manager.sh list
  appimage-manager.sh list-installed
  appimage-manager.sh install-all
  appimage-manager.sh update-all
  appimage-manager.sh uninstall-all
  appimage-manager.sh install winboat
  appimage-manager.sh update neovim
  appimage-manager.sh status winboat
  appimage-manager.sh uninstall winboat

Makefile Usage:
  make appimage-list           # List available apps
  make appimage-list-installed # List installed apps
  make appimage-install-all    # Install all apps
  make appimage-update-all     # Update all apps
  make appimage-uninstall-all  # Uninstall all apps
  make appimage-install APP=winboat   # Install specific app
  make appimage-update APP=winboat    # Update specific app
  make appimage-status APP=winboat    # Show status
  make appimage-uninstall APP=winboat # Uninstall specific app

Available AppImages:
EOF
    local apps
    apps=($(get_available_apps))
    for app in "${apps[@]}"; do
        echo "  • $app"
    done
}

# =============================================================================
# メイン処理
# =============================================================================

main() {
    local command="${1:-list}"
    local app_name="${2:-}"

    # Linuxチェック
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_warning "AppImage management is primarily for Linux"
        log_info "Current platform: $(uname -s)"
    fi

    case "$command" in
        list)
            list_all
            ;;
        list-installed)
            list_installed
            ;;
        install-all)
            install_all
            ;;
        update-all)
            update_all
            ;;
        uninstall-all)
            uninstall_all
            ;;
        install|update|uninstall|status)
            manage_app "$command" "$app_name"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# メイン処理実行
main "$@"
