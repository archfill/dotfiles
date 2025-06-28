#!/usr/bin/env bash

# install_checker.sh - 共通インストール済みチェック関数ライブラリ
# 全アプリケーションスクリプトで使用する統一的なチェック機能を提供

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# コマンド存在チェック関数
# =============================================================================

# コマンドが利用可能かチェック
is_command_available() {
    local command_name="$1"
    local version_flag="${2:---version}"
    
    if command -v "$command_name" >/dev/null 2>&1; then
        local version_output
        version_output=$($command_name $version_flag 2>/dev/null | head -1 || echo "unknown")
        log_info "$command_name is available: $version_output"
        return 0
    else
        log_info "$command_name is not available"
        return 1
    fi
}

# 複数コマンドの存在チェック
are_commands_available() {
    local commands=("$@")
    local all_available=true
    
    for cmd in "${commands[@]}"; do
        if ! is_command_available "$cmd"; then
            all_available=false
        fi
    done
    
    if [[ "$all_available" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# バージョンチェック関数
# =============================================================================

# バージョン文字列を比較（semver形式対応）
compare_versions() {
    local version1="$1"
    local version2="$2"
    
    # バージョン文字列から数字のみ抽出
    local v1=$(echo "$version1" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    local v2=$(echo "$version2" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    
    if [[ -z "$v1" || -z "$v2" ]]; then
        return 2  # バージョン比較不可
    fi
    
    # バージョンを配列に分割
    IFS='.' read -ra V1 <<< "$v1"
    IFS='.' read -ra V2 <<< "$v2"
    
    # 各部分を比較
    for i in {0..2}; do
        local part1=${V1[i]:-0}
        local part2=${V2[i]:-0}
        
        if (( part1 > part2 )); then
            return 0  # v1 > v2
        elif (( part1 < part2 )); then
            return 1  # v1 < v2
        fi
    done
    
    return 2  # v1 == v2
}

# 指定バージョン要件を満たしているかチェック
is_version_satisfied() {
    local command_name="$1"
    local required_version="$2"
    local version_flag="${3:---version}"
    
    if ! is_command_available "$command_name" "$version_flag"; then
        return 1
    fi
    
    local current_version
    current_version=$($command_name $version_flag 2>/dev/null | head -1 || echo "")
    
    if [[ -z "$current_version" ]]; then
        log_warning "Could not determine version for $command_name"
        return 1
    fi
    
    compare_versions "$current_version" "$required_version"
    local result=$?
    
    case $result in
        0|2)  # current >= required
            log_info "$command_name version satisfied: $current_version >= $required_version"
            return 0
            ;;
        1)    # current < required
            log_info "$command_name version insufficient: $current_version < $required_version"
            return 1
            ;;
        *)
            log_warning "Version comparison failed for $command_name"
            return 1
            ;;
    esac
}

# =============================================================================
# 設定ファイルチェック関数
# =============================================================================

# 設定ファイルが最新かチェック（タイムスタンプベース）
is_config_up_to_date() {
    local source_config="$1"
    local target_config="$2"
    local max_age_hours="${3:-24}"
    
    if [[ ! -f "$source_config" ]]; then
        log_warning "Source config not found: $source_config"
        return 1
    fi
    
    if [[ ! -f "$target_config" ]]; then
        log_info "Target config not found: $target_config"
        return 1
    fi
    
    # ファイルの最終更新時間を比較
    local source_time=$(stat -c %Y "$source_config" 2>/dev/null || echo 0)
    local target_time=$(stat -c %Y "$target_config" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    
    # ソースファイルがターゲットより新しい場合は更新が必要
    if (( source_time > target_time )); then
        log_info "Config update needed: source is newer than target"
        return 1
    fi
    
    # ターゲットファイルが古すぎる場合は更新が必要
    local age_seconds=$(( current_time - target_time ))
    local max_age_seconds=$(( max_age_hours * 3600 ))
    
    if (( age_seconds > max_age_seconds )); then
        log_info "Config update needed: target is older than ${max_age_hours} hours"
        return 1
    fi
    
    log_info "Config is up to date: $target_config"
    return 0
}

# 設定ファイルのハッシュ比較
is_config_hash_unchanged() {
    local source_config="$1"
    local target_config="$2"
    local hash_file="${target_config}.hash"
    
    if [[ ! -f "$source_config" || ! -f "$target_config" ]]; then
        return 1
    fi
    
    local source_hash=$(sha256sum "$source_config" | cut -d' ' -f1)
    local target_hash=$(sha256sum "$target_config" | cut -d' ' -f1)
    
    if [[ "$source_hash" == "$target_hash" ]]; then
        # ハッシュファイルに記録
        echo "$source_hash" > "$hash_file"
        log_info "Config files are identical (hash: ${source_hash:0:8}...)"
        return 0
    else
        log_info "Config files differ (source: ${source_hash:0:8}..., target: ${target_hash:0:8}...)"
        return 1
    fi
}

# =============================================================================
# パッケージマネージャー別チェック関数
# =============================================================================

# Homebrew パッケージの存在チェック
is_brew_package_installed() {
    local package_name="$1"
    
    if ! command -v brew >/dev/null 2>&1; then
        return 1
    fi
    
    if brew list "$package_name" >/dev/null 2>&1; then
        local version=$(brew list --versions "$package_name" | head -1)
        log_info "Homebrew package installed: $version"
        return 0
    else
        log_info "Homebrew package not installed: $package_name"
        return 1
    fi
}

# APT パッケージの存在チェック
is_apt_package_installed() {
    local package_name="$1"
    
    if ! command -v dpkg >/dev/null 2>&1; then
        return 1
    fi
    
    if dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"; then
        local version=$(dpkg -l "$package_name" 2>/dev/null | grep "^ii" | awk '{print $3}')
        log_info "APT package installed: $package_name $version"
        return 0
    else
        log_info "APT package not installed: $package_name"
        return 1
    fi
}

# Pacman パッケージの存在チェック
is_pacman_package_installed() {
    local package_name="$1"
    
    if ! command -v pacman >/dev/null 2>&1; then
        return 1
    fi
    
    if pacman -Q "$package_name" >/dev/null 2>&1; then
        local version=$(pacman -Q "$package_name" | awk '{print $2}')
        log_info "Pacman package installed: $package_name $version"
        return 0
    else
        log_info "Pacman package not installed: $package_name"
        return 1
    fi
}

# プラットフォーム別パッケージチェック
is_system_package_installed() {
    local package_name="$1"
    local platform="${2:-$(detect_platform)}"
    
    case "$platform" in
        macos)
            is_brew_package_installed "$package_name"
            ;;
        linux)
            local distro=$(get_os_distribution 2>/dev/null || echo "unknown")
            case "$distro" in
                debian|ubuntu)
                    is_apt_package_installed "$package_name"
                    ;;
                arch)
                    is_pacman_package_installed "$package_name"
                    ;;
                *)
                    log_warning "Unsupported distribution for package check: $distro"
                    return 1
                    ;;
            esac
            ;;
        *)
            log_warning "Unsupported platform for package check: $platform"
            return 1
            ;;
    esac
}

# =============================================================================
# 総合判定関数
# =============================================================================

# インストールをスキップすべきかの総合判定
should_skip_installation() {
    local component_name="$1"
    local required_commands=("${@:2}")
    
    log_info "Checking if $component_name installation should be skipped..."
    
    # 基本的なコマンド存在チェック
    if are_commands_available "${required_commands[@]}"; then
        log_skip_reason "$component_name" "All required commands are available"
        return 0
    fi
    
    return 1
}

# 高度なスキップ判定（バージョン要件付き）
should_skip_installation_advanced() {
    local component_name="$1"
    local command_name="$2"
    local required_version="$3"
    local version_flag="${4:---version}"
    
    log_info "Checking advanced skip conditions for $component_name..."
    
    # コマンド存在チェック
    if ! is_command_available "$command_name" "$version_flag"; then
        log_info "$component_name: Command not available, installation needed"
        return 1
    fi
    
    # バージョン要件チェック
    if [[ -n "$required_version" ]]; then
        if ! is_version_satisfied "$command_name" "$required_version" "$version_flag"; then
            log_info "$component_name: Version requirement not met, update needed"
            return 1
        fi
    fi
    
    log_skip_reason "$component_name" "Command available and version satisfied"
    return 0
}

# =============================================================================
# ログ関数
# =============================================================================

# スキップ理由のログ
log_skip_reason() {
    local component="$1"
    local reason="$2"
    
    log_success "SKIP: $component - $reason"
}

# インストール結果サマリ
log_install_summary() {
    local installed_count="$1"
    local skipped_count="$2"
    local failed_count="$3"
    
    log_info ""
    log_info "Installation Summary:"
    log_info "  Installed: $installed_count"
    log_info "  Skipped:   $skipped_count"
    log_info "  Failed:    $failed_count"
    log_info ""
}

# 時間節約の表示
log_time_saved() {
    local estimated_time="$1"
    local actual_time="$2"
    
    if [[ -n "$estimated_time" && -n "$actual_time" ]]; then
        local saved_time=$((estimated_time - actual_time))
        if (( saved_time > 0 )); then
            log_success "Time saved: ${saved_time}s (${actual_time}s instead of ${estimated_time}s)"
        fi
    fi
}

# =============================================================================
# オプション解析関数
# =============================================================================

# 共通オプションの解析
parse_install_options() {
    FORCE_INSTALL=false
    QUICK_CHECK=false
    SKIP_DEPS=false
    DRY_RUN=false
    VERBOSE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --quick)
                QUICK_CHECK=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            *)
                # 未知のオプションは無視
                shift
                ;;
        esac
    done
    
    if [[ "$VERBOSE" == "true" ]]; then
        log_info "Options: FORCE=$FORCE_INSTALL, QUICK=$QUICK_CHECK, SKIP_DEPS=$SKIP_DEPS, DRY_RUN=$DRY_RUN"
    fi
}

# DRY_RUN モードでの実行
execute_if_not_dry_run() {
    local description="$1"
    shift
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would execute: $description"
        return 0
    else
        log_info "Executing: $description"
        "$@"
    fi
}