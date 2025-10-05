#!/usr/bin/env bash

# appimage_manager.sh - AppImage共通管理ライブラリ
# 全AppImageアプリケーションで使用する統一的な管理機能を提供

# 共通ライブラリをインポート
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

source "${DOTFILES_DIR}/bin/lib/common.sh"
source "${DOTFILES_DIR}/bin/lib/install_checker.sh"

# =============================================================================
# AppImage管理用の設定
# =============================================================================

# デフォルト設定（config/versions.confで上書き可能）
APPIMAGE_INSTALL_DIR="${APPIMAGE_INSTALL_DIR:-${HOME}/.local/share/appimages}"
APPIMAGE_BIN_DIR="${APPIMAGE_BIN_DIR:-${HOME}/.local/bin}"
APPIMAGE_KEEP_OLD_VERSIONS="${APPIMAGE_KEEP_OLD_VERSIONS:-1}"

# =============================================================================
# メタデータ管理関数
# =============================================================================

# メタデータを保存
# 引数: app_name, version, download_url, appimage_filename
appimage_save_metadata() {
    local app_name="$1"
    local version="$2"
    local download_url="$3"
    local appimage_filename="$4"

    local metadata_dir="${APPIMAGE_INSTALL_DIR}/${app_name}"
    local metadata_file="${metadata_dir}/metadata.json"

    mkdir -p "$metadata_dir"

    # JSON形式でメタデータを保存
    cat > "$metadata_file" <<EOF
{
  "app_name": "${app_name}",
  "version": "${version}",
  "download_url": "${download_url}",
  "appimage_filename": "${appimage_filename}",
  "install_date": "$(date -Iseconds)",
  "architecture": "$(uname -m)",
  "platform": "$(uname -s)"
}
EOF

    log_info "Metadata saved: $metadata_file"
}

# メタデータを読み込み
# 引数: app_name, key
# 出力: 指定されたキーの値
appimage_load_metadata() {
    local app_name="$1"
    local key="$2"

    local metadata_file="${APPIMAGE_INSTALL_DIR}/${app_name}/metadata.json"

    if [[ ! -f "$metadata_file" ]]; then
        return 1
    fi

    # JSONから値を抽出（jqがない環境でも動作するようにgrepとsedを使用）
    grep "\"${key}\"" "$metadata_file" | sed -E 's/.*"([^"]+)"[^"]*$/\1/' | tr -d ','
}

# インストール済みバージョンを取得
# 引数: app_name
# 出力: バージョン文字列（インストールされていない場合は空文字列）
appimage_get_installed_version() {
    local app_name="$1"
    appimage_load_metadata "$app_name" "version" || echo ""
}

# =============================================================================
# GitHub Releases API関連関数
# =============================================================================

# GitHub Releasesから最新バージョンを取得
# 引数: repo (例: "TibixDev/winboat"), [quiet]
# 出力: 最新バージョン（vプレフィックスなし）
appimage_get_latest_version() {
    local repo="$1"
    local quiet="${2:-false}"

    if [[ "$quiet" != "true" ]]; then
        log_info "Fetching latest version from GitHub: $repo"
    fi

    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local response
    response=$(curl -s "$api_url")

    if [[ $? -ne 0 ]] || [[ -z "$response" ]]; then
        if [[ "$quiet" != "true" ]]; then
            log_error "Failed to fetch release information from GitHub"
        fi
        return 1
    fi

    local tag_name
    tag_name=$(echo "$response" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | head -1)

    if [[ -z "$tag_name" ]]; then
        if [[ "$quiet" != "true" ]]; then
            log_error "Could not parse version from GitHub API response"
        fi
        return 1
    fi

    # 'v'プレフィックスを削除
    echo "${tag_name#v}"
}

# GitHub ReleasesからダウンロードURLを取得
# 引数: repo, version, filename_pattern (例: "winboat-*-x86_64.AppImage")
# 出力: ダウンロードURL
appimage_get_download_url() {
    local repo="$1"
    local version="$2"
    local filename_pattern="$3"

    local api_url="https://api.github.com/repos/${repo}/releases/tags/v${version}"
    local response
    response=$(curl -s "$api_url")

    if [[ $? -ne 0 ]] || [[ -z "$response" ]]; then
        log_error "Failed to fetch release information"
        return 1
    fi

    # filename_patternに一致するダウンロードURLを抽出
    # ワイルドカードを正規表現に変換
    local pattern_regex="${filename_pattern//\*/.*}"

    local download_url
    download_url=$(echo "$response" | grep '"browser_download_url"' | grep -E "\".*${pattern_regex}\"" | sed -E 's/.*"([^"]+)".*/\1/' | head -1)

    if [[ -z "$download_url" ]]; then
        log_error "Could not find download URL matching pattern: $filename_pattern"
        return 1
    fi

    echo "$download_url"
}

# =============================================================================
# AppImageダウンロード・インストール関数
# =============================================================================

# AppImageをダウンロード
# 引数: download_url, dest_path
appimage_download() {
    local download_url="$1"
    local dest_path="$2"

    log_info "Downloading from: $download_url"
    log_info "Destination: $dest_path"

    # ディレクトリ作成
    mkdir -p "$(dirname "$dest_path")"

    # ダウンロード
    if curl -L "$download_url" -o "$dest_path"; then
        chmod +x "$dest_path"
        log_success "Downloaded and made executable: $dest_path"
        return 0
    else
        log_error "Failed to download AppImage"
        return 1
    fi
}

# シンボリックリンクを作成
# 引数: appimage_path, symlink_name
appimage_create_symlink() {
    local appimage_path="$1"
    local symlink_name="$2"

    local symlink_path="${APPIMAGE_BIN_DIR}/${symlink_name}"

    # ディレクトリ作成
    mkdir -p "$APPIMAGE_BIN_DIR"

    # 既存のシンボリックリンクを削除
    if [[ -L "$symlink_path" ]]; then
        rm -f "$symlink_path"
    elif [[ -e "$symlink_path" ]]; then
        log_warning "File exists and is not a symlink: $symlink_path"
        log_warning "Skipping symlink creation"
        return 1
    fi

    # 相対パスでシンボリックリンクを作成
    local relative_path
    relative_path=$(realpath --relative-to="$APPIMAGE_BIN_DIR" "$appimage_path")

    ln -s "$relative_path" "$symlink_path"
    log_success "Created symlink: $symlink_path -> $relative_path"
}

# 古いバージョンをクリーンアップ
# 引数: app_name, current_filename, keep_count
appimage_cleanup_old_versions() {
    local app_name="$1"
    local current_filename="$2"
    local keep_count="${3:-${APPIMAGE_KEEP_OLD_VERSIONS}}"

    local app_dir="${APPIMAGE_INSTALL_DIR}/${app_name}"

    if [[ ! -d "$app_dir" ]]; then
        return 0
    fi

    log_info "Cleaning up old versions (keeping ${keep_count} old version(s))"

    # AppImageファイルをリストアップ（最新のものを除く）
    local appimages=()
    while IFS= read -r -d '' file; do
        local filename
        filename=$(basename "$file")
        # 現在のファイルは除外
        if [[ "$filename" != "$current_filename" ]] && [[ "$filename" == *.AppImage || "$filename" == *.appimage ]]; then
            appimages+=("$file")
        fi
    done < <(find "$app_dir" -maxdepth 1 -type f \( -name "*.AppImage" -o -name "*.appimage" \) -print0 | sort -z -r)

    # 保持する数を超えたファイルを削除
    local count=0
    for file in "${appimages[@]}"; do
        if [[ $count -ge $keep_count ]]; then
            log_info "Removing old version: $(basename "$file")"
            rm -f "$file"
        fi
        ((count++))
    done
}

# AppImageをインストール
# 引数: repo, app_name, version, filename_pattern, [symlink_name]
appimage_install() {
    local repo="$1"
    local app_name="$2"
    local version="$3"
    local filename_pattern="$4"
    local symlink_name="${5:-$app_name}"

    log_info "Installing AppImage: $app_name"

    # バージョンが"latest"の場合、最新版を取得
    if [[ "$version" == "latest" ]]; then
        version=$(appimage_get_latest_version "$repo" true)
        if [[ $? -ne 0 ]] || [[ -z "$version" ]]; then
            log_error "Failed to determine latest version"
            return 1
        fi
        log_info "Latest version: v${version}"
    fi

    # ダウンロードURLを取得
    local download_url
    download_url=$(appimage_get_download_url "$repo" "$version" "$filename_pattern")
    if [[ $? -ne 0 ]] || [[ -z "$download_url" ]]; then
        return 1
    fi

    # ファイル名を抽出
    local appimage_filename
    appimage_filename=$(basename "$download_url")

    # インストール先パス
    local install_dir="${APPIMAGE_INSTALL_DIR}/${app_name}"
    local install_path="${install_dir}/${appimage_filename}"

    # ダウンロード
    if ! appimage_download "$download_url" "$install_path"; then
        return 1
    fi

    # シンボリックリンク作成
    if ! appimage_create_symlink "$install_path" "$symlink_name"; then
        log_warning "Failed to create symlink, but AppImage was installed"
    fi

    # メタデータ保存
    appimage_save_metadata "$app_name" "$version" "$download_url" "$appimage_filename"

    # 古いバージョンをクリーンアップ
    appimage_cleanup_old_versions "$app_name" "$appimage_filename"

    log_success "AppImage installed successfully: $app_name v${version}"
    log_info "Location: $install_path"
    log_info "Command: $symlink_name"

    return 0
}

# =============================================================================
# AppImage更新関数
# =============================================================================

# AppImageを更新
# 引数: repo, app_name, filename_pattern, [symlink_name]
appimage_update() {
    local repo="$1"
    local app_name="$2"
    local filename_pattern="$3"
    local symlink_name="${4:-$app_name}"

    log_info "Checking for updates: $app_name"

    # 現在のバージョンを取得
    local current_version
    current_version=$(appimage_get_installed_version "$app_name")

    if [[ -z "$current_version" ]]; then
        log_warning "AppImage not currently installed: $app_name"
        log_info "Running installation instead..."
        appimage_install "$repo" "$app_name" "latest" "$filename_pattern" "$symlink_name"
        return $?
    fi

    log_info "Current version: v${current_version}"

    # 最新バージョンを取得
    local latest_version
    latest_version=$(appimage_get_latest_version "$repo" true)

    if [[ $? -ne 0 ]] || [[ -z "$latest_version" ]]; then
        log_error "Failed to check for updates"
        return 1
    fi

    log_info "Latest version: v${latest_version}"

    # バージョン比較
    compare_versions "$current_version" "$latest_version"
    local result=$?

    case $result in
        0|2)  # Same version
            log_success "Already at latest version (v${current_version})"
            return 0
            ;;
        1)    # Current < Latest - update needed
            log_info "Update available: v${current_version} -> v${latest_version}"
            appimage_install "$repo" "$app_name" "$latest_version" "$filename_pattern" "$symlink_name"
            return $?
            ;;
        *)
            log_error "Version comparison failed"
            return 1
            ;;
    esac
}

# =============================================================================
# AppImageアンインストール関数
# =============================================================================

# AppImageをアンインストール
# 引数: app_name, [symlink_name]
appimage_uninstall() {
    local app_name="$1"
    local symlink_name="${2:-$app_name}"

    log_info "Uninstalling AppImage: $app_name"

    local app_dir="${APPIMAGE_INSTALL_DIR}/${app_name}"
    local symlink_path="${APPIMAGE_BIN_DIR}/${symlink_name}"

    local removed_count=0

    # シンボリックリンク削除
    if [[ -L "$symlink_path" ]]; then
        rm -f "$symlink_path"
        log_info "Removed symlink: $symlink_path"
        ((removed_count++))
    fi

    # AppImageディレクトリ削除
    if [[ -d "$app_dir" ]]; then
        rm -rf "$app_dir"
        log_info "Removed directory: $app_dir"
        ((removed_count++))
    fi

    if [[ $removed_count -gt 0 ]]; then
        log_success "AppImage uninstalled successfully: $app_name"
        return 0
    else
        log_warning "AppImage was not installed: $app_name"
        return 0
    fi
}

# =============================================================================
# ユーティリティ関数
# =============================================================================

# インストール済みAppImageの一覧表示
appimage_list_installed() {
    log_info "Installed AppImages:"
    log_info ""

    if [[ ! -d "$APPIMAGE_INSTALL_DIR" ]]; then
        log_info "No AppImages installed"
        return 0
    fi

    local found_any=false

    for app_dir in "$APPIMAGE_INSTALL_DIR"/*; do
        if [[ ! -d "$app_dir" ]]; then
            continue
        fi

        local app_name
        app_name=$(basename "$app_dir")

        local version
        version=$(appimage_get_installed_version "$app_name")

        local metadata_file="${app_dir}/metadata.json"
        local install_date=""
        if [[ -f "$metadata_file" ]]; then
            install_date=$(appimage_load_metadata "$app_name" "install_date" || echo "")
        fi

        log_info "  ${app_name}"
        log_info "    Version: ${version:-unknown}"
        log_info "    Installed: ${install_date:-unknown}"
        log_info ""

        found_any=true
    done

    if [[ "$found_any" == "false" ]]; then
        log_info "No AppImages installed"
    fi

    return 0
}

# AppImage実行環境のチェック
appimage_check_requirements() {
    log_info "Checking AppImage requirements..."

    local requirements_met=true

    # FUSE チェック（Linux）
    if [[ "$(uname -s)" == "Linux" ]]; then
        if [[ ! -e /dev/fuse ]]; then
            log_warning "/dev/fuse not found - FUSE may not be available"
            log_info "Install FUSE: sudo apt install fuse (Debian/Ubuntu) or sudo pacman -S fuse2 (Arch)"
            requirements_met=false
        else
            log_success "FUSE available"
        fi
    fi

    # curlチェック
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl not found (required for downloading AppImages)"
        requirements_met=false
    else
        log_success "curl available"
    fi

    # ディレクトリチェック
    if [[ -d "$APPIMAGE_INSTALL_DIR" ]]; then
        log_success "AppImage directory exists: $APPIMAGE_INSTALL_DIR"
    else
        log_info "AppImage directory will be created: $APPIMAGE_INSTALL_DIR"
    fi

    if [[ "$requirements_met" == "false" ]]; then
        log_error "Some requirements are not met"
        return 1
    fi

    log_success "All requirements satisfied"
    return 0
}

# AppImageのステータス表示
# 引数: repo, app_name
appimage_status() {
    local repo="$1"
    local app_name="$2"

    log_info "${app_name} Status"
    log_info "$(printf '=%.0s' {1..50})"
    log_info ""

    # インストール確認
    local current_version
    current_version=$(appimage_get_installed_version "$app_name")

    if [[ -n "$current_version" ]]; then
        log_info "Installed: Yes"
        log_info "Version: v${current_version}"

        local metadata_file="${APPIMAGE_INSTALL_DIR}/${app_name}/metadata.json"
        if [[ -f "$metadata_file" ]]; then
            local install_date
            install_date=$(appimage_load_metadata "$app_name" "install_date")
            log_info "Installed: ${install_date:-unknown}"

            local appimage_filename
            appimage_filename=$(appimage_load_metadata "$app_name" "appimage_filename")
            log_info "File: ${appimage_filename:-unknown}"
        fi

        local symlink_path="${APPIMAGE_BIN_DIR}/${app_name}"
        if [[ -L "$symlink_path" ]]; then
            log_info "Command: $app_name"
        fi

        # 更新チェック
        local latest_version
        latest_version=$(appimage_get_latest_version "$repo" true)

        if [[ -n "$latest_version" ]]; then
            log_info ""
            log_info "Latest version: v${latest_version}"

            compare_versions "$current_version" "$latest_version"
            case $? in
                0|2)
                    log_success "Status: Up to date"
                    ;;
                1)
                    log_warning "Status: Update available (v${current_version} -> v${latest_version})"
                    ;;
            esac
        fi
    else
        log_info "Installed: No"
    fi
}
