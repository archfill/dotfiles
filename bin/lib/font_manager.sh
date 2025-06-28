#!/usr/bin/env bash

# モダンフォント管理ライブラリ
# 複数プラットフォーム対応の統一フォントインストール・管理システム

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/config_loader.sh"
source "${SCRIPT_DIR}/install_checker.sh"

# アーカイブ展開の共通関数（unzip代替対応）
extract_archive() {
    local archive_file="$1"
    local extract_dir="$2"
    
    # unzipが利用可能な場合
    if command -v unzip >/dev/null 2>&1; then
        log_info "Extracting with unzip: $archive_file"
        unzip -q "$archive_file" -d "$extract_dir"
        return $?
    fi
    
    # 7zipが利用可能な場合
    if command -v 7z >/dev/null 2>&1; then
        log_info "Extracting with 7z: $archive_file"
        7z x "$archive_file" -o"$extract_dir" -y >/dev/null
        return $?
    fi
    
    # p7zipのコマンドが利用可能な場合
    if command -v 7za >/dev/null 2>&1; then
        log_info "Extracting with 7za: $archive_file"
        7za x "$archive_file" -o"$extract_dir" -y >/dev/null
        return $?
    fi
    
    log_error "No suitable archive extraction tool found (unzip, 7z, 7za)"
    log_error "Please install unzip or p7zip package"
    return 1
}

# フォント設定の構造体風定義
declare -A FONT_CONFIGS

# FONT_CONFIGSの初期化状態を管理
FONT_CONFIGS_INITIALIZED="false"

# =============================================================================
# フォント統一スキップロジック関数
# =============================================================================

# フォントインストールをスキップすべきか判定
should_skip_font_install() {
    # SKIP_FONT_INSTALL環境変数のチェック
    if [[ "${SKIP_FONT_INSTALL:-0}" == "1" ]]; then
        log_info "Skipping font installation (SKIP_FONT_INSTALL=1)"
        return 0
    fi
    
    # 既存のSKIP_PACKAGE_INSTALLパターンとの互換性
    if [[ "${SKIP_PACKAGE_INSTALL:-0}" == "1" ]]; then
        log_info "Skipping font installation (SKIP_PACKAGE_INSTALL=1)"
        return 0
    fi
    
    # CI環境の自動検出
    if [[ "${CI:-}" == "true" ]] || [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
        log_info "Skipping font installation (CI environment detected)"
        return 0
    fi
    
    # QUICK_CHECKモードのチェック
    if [[ "${QUICK_CHECK:-}" == "true" ]]; then
        log_info "QUICK: Would install fonts"
        return 0
    fi
    
    return 1
}

# 特定フォントのインストール状態をチェック
check_font_installed() {
    local font_key="$1"
    
    # フォント設定の初期化
    init_font_configs
    
    # フォント設定の検証
    if [[ -z "${FONT_CONFIGS[$font_key]:-}" ]]; then
        log_warning "Unknown font key: $font_key"
        return 1
    fi
    
    local font_info="${FONT_CONFIGS[$font_key]}"
    local font_name=$(echo "$font_info" | cut -d'|' -f1)
    
    # プラットフォーム別フォントチェック
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            # macOS: システムフォントディレクトリでチェック
            local font_dirs=(
                "$HOME/Library/Fonts"
                "/Library/Fonts"
                "/System/Library/Fonts"
            )
            for font_dir in "${font_dirs[@]}"; do
                if [[ -d "$font_dir" ]] && find "$font_dir" -name "*${font_name%% *}*" -type f >/dev/null 2>&1; then
                    return 0
                fi
            done
            ;;
        "linux")
            # Linux: fontconfigでチェック
            if command -v fc-list >/dev/null 2>&1; then
                if fc-list | grep -qi "${font_name%% *}"; then
                    return 0
                fi
            fi
            # フォールバック: フォントディレクトリでチェック
            local font_dirs=(
                "$HOME/.fonts"
                "$HOME/.local/share/fonts"
                "/usr/share/fonts"
                "/usr/local/share/fonts"
            )
            for font_dir in "${font_dirs[@]}"; do
                if [[ -d "$font_dir" ]] && find "$font_dir" -name "*${font_name%% *}*" -type f >/dev/null 2>&1; then
                    return 0
                fi
            done
            ;;
    esac
    
    return 1
}

# フォント環境の包括的チェック
check_font_environment() {
    log_info "Checking font environment..."
    
    local platform
    platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            # macOSフォントディレクトリの確認
            local font_dirs=("$HOME/Library/Fonts" "/Library/Fonts")
            for font_dir in "${font_dirs[@]}"; do
                if [[ -d "$font_dir" ]]; then
                    local font_count
                    font_count=$(find "$font_dir" -name "*.ttf" -o -name "*.otf" | wc -l)
                    log_info "$font_dir: $font_count fonts"
                fi
            done
            ;;
        "linux")
            # Linux fontconfigステータス
            if command -v fc-list >/dev/null 2>&1; then
                local font_count
                font_count=$(fc-list | wc -l)
                log_info "System fonts (fontconfig): $font_count"
            fi
            
            # ユーザーフォントディレクトリ
            local user_font_dirs=("$HOME/.fonts" "$HOME/.local/share/fonts")
            for font_dir in "${user_font_dirs[@]}"; do
                if [[ -d "$font_dir" ]]; then
                    local font_count
                    font_count=$(find "$font_dir" -name "*.ttf" -o -name "*.otf" 2>/dev/null | wc -l)
                    log_info "$font_dir: $font_count fonts"
                fi
            done
            ;;
    esac
    
    log_success "Font environment check completed"
    return 0
}

# =============================================================================
# モダンな開発フォント定義
# =============================================================================

init_font_configs() {
    # Nerd Fonts系 - モダンで高機能
    FONT_CONFIGS["jetbrains-mono-nf"]="JetBrainsMono Nerd Font|yuru7/PlemolJP|font-jetbrains-mono-nerd-font|PlemolJP"
    FONT_CONFIGS["hackgen-nf"]="HackGen Nerd Font|yuru7/HackGen|font-hackgen-nerd|HackGen"
    FONT_CONFIGS["fira-code-nf"]="FiraCode Nerd Font|ryanoasis/nerd-fonts|font-fira-code-nerd-font|FiraCodeNerdFont"
    
    # 日本語対応高品質フォント
    FONT_CONFIGS["plemoljp"]="PlemolJP|yuru7/PlemolJP|font-plemoljp|PlemolJP"
    FONT_CONFIGS["udev-gothic"]="UDEV Gothic|yuru7/udev-gothic|font-udev-gothic|UDEVGothic"
    FONT_CONFIGS["cica"]="Cica|miiton/Cica|font-cica|Cica"
    
    # クラシック（後方互換性用）
    FONT_CONFIGS["source-code-pro"]="Source Code Pro|adobe-fonts/source-code-pro|font-source-code-pro|SourceCodePro"
    FONT_CONFIGS["fira-code"]="Fira Code|tonsky/FiraCode|font-fira-code|FiraCode"
    
    # 初期化完了フラグを設定
    FONT_CONFIGS_INITIALIZED="true"
}

# フォント情報の解析
parse_font_config() {
    local font_key="$1"
    local config="${FONT_CONFIGS[$font_key]}"
    
    if [[ -z "$config" ]]; then
        log_error "Unknown font: $font_key"
        return 1
    fi
    
    IFS='|' read -ra PARTS <<< "$config"
    echo "FONT_NAME=\"${PARTS[0]}\""
    echo "GITHUB_REPO=\"${PARTS[1]}\""
    echo "BREW_CASK=\"${PARTS[2]}\""
    echo "INSTALL_NAME=\"${PARTS[3]}\""
}

# プラットフォーム固有のフォントディレクトリ取得
get_font_directory() {
    local platform
    platform="$(detect_platform)"
    
    case "$platform" in
        "macos")
            echo "$HOME/Library/Fonts"
            ;;
        "linux")
            echo "$HOME/.local/share/fonts"
            ;;
        "cygwin")
            echo "$HOME/.fonts"
            ;;
        *)
            log_error "Unsupported platform for font installation: $platform"
            return 1
            ;;
    esac
}

# フォントがインストール済みかチェック
is_font_installed() {
    local font_name="$1"
    local platform
    platform="$(detect_platform)"
    
    case "$platform" in
        "macos")
            # macOSではsystem_profilerで確認
            system_profiler SPFontsDataType 2>/dev/null | grep -qi "$font_name"
            ;;
        "linux")
            # Linuxではfc-listで確認
            if command -v fc-list >/dev/null 2>&1; then
                fc-list | grep -qi "$font_name"
            else
                # fc-listがない場合はファイル存在で判定
                local font_dir
                font_dir="$(get_font_directory)"
                find "$font_dir" -name "*${font_name}*" -type f 2>/dev/null | grep -q .
            fi
            ;;
        *)
            log_warning "Font check not supported on this platform"
            return 1
            ;;
    esac
}

# GitHub Releasesから最新バージョンを取得（最適化版）
get_latest_font_version() {
    local github_repo="$1"
    
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required for fetching font versions"
        return 1
    fi
    
    local api_url="https://api.github.com/repos/${github_repo}/releases/latest"
    local api_response
    local version
    
    # API応答をキャッシュして複数回のcurl呼び出しを回避
    api_response=$(curl -s "$api_url" 2>/dev/null)
    if [[ $? -ne 0 || -z "$api_response" ]]; then
        log_error "Failed to fetch version information from GitHub API"
        return 1
    fi
    
    # GitHub API制限対策：jqがあれば使用、なければgrepで抽出
    if command -v jq >/dev/null 2>&1; then
        version=$(echo "$api_response" | jq -r '.tag_name' 2>/dev/null)
    else
        version=$(echo "$api_response" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
    fi
    
    if [[ -n "$version" && "$version" != "null" ]]; then
        echo "$version"
        return 0
    else
        log_warning "Could not fetch latest version for $github_repo"
        return 1
    fi
}

# macOS用フォントインストール（Homebrew優先）
install_font_macos() {
    local font_key="$1"
    local force_github="${2:-false}"
    
    eval "$(parse_font_config "$font_key")"
    
    if [[ "$force_github" == "false" ]] && command -v brew >/dev/null 2>&1; then
        log_info "Installing $FONT_NAME via Homebrew..."
        
        # Homebrew cask-fonts tapの追加
        if ! brew tap | grep -q "homebrew/cask-fonts"; then
            log_info "Adding homebrew/cask-fonts tap..."
            brew tap homebrew/cask-fonts
        fi
        
        # フォントインストール
        if brew install --cask "$BREW_CASK" 2>/dev/null; then
            log_success "$FONT_NAME installed via Homebrew"
            return 0
        else
            log_warning "Homebrew installation failed, trying GitHub releases..."
        fi
    fi
    
    # GitHub releasesからダウンロード
    install_font_from_github "$font_key"
}

# Linux用フォントインストール
install_font_linux() {
    local font_key="$1"
    
    eval "$(parse_font_config "$font_key")"
    
    # パッケージマネージャーでの検索を試行
    local package_manager
    package_manager="$(detect_package_manager)"
    
    case "$package_manager" in
        "apt")
            # Ubuntu/Debianでパッケージが利用可能かチェック
            local package_name
            package_name=$(echo "$INSTALL_NAME" | tr '[:upper:]' '[:lower:]')
            if apt-cache search "fonts-${package_name}" 2>/dev/null | grep -q .; then
                log_info "Installing $FONT_NAME via apt..."
                sudo apt update && sudo apt install -y "fonts-${package_name}"
                return $?
            fi
            ;;
        "pacman")
            # Arch Linuxでパッケージが利用可能かチェック
            if pacman -Ss "ttf-${INSTALL_NAME,,}" 2>/dev/null | grep -q .; then
                log_info "Installing $FONT_NAME via pacman..."
                sudo pacman -S --noconfirm "ttf-${INSTALL_NAME,,}"
                return $?
            fi
            ;;
    esac
    
    # パッケージマネージャーで見つからない場合はGitHubから
    log_info "Package manager installation not available, using GitHub releases..."
    install_font_from_github "$font_key"
}

# GitHub Releasesからフォントをダウンロード・インストール
install_font_from_github() {
    local font_key="$1"
    
    eval "$(parse_font_config "$font_key")"
    
    log_info "Installing $FONT_NAME from GitHub releases..."
    
    # 作業ディレクトリの準備
    local temp_dir
    temp_dir="$(mktemp -d)"
    local font_dir
    font_dir="$(get_font_directory)"
    
    # フォントディレクトリの作成
    mkdir -p "$font_dir"
    
    # 最新バージョンの取得
    local version
    version="$(get_latest_font_version "$GITHUB_REPO")"
    if [[ -z "$version" ]]; then
        log_error "Could not determine latest version for $FONT_NAME"
        rm -rf "$temp_dir"
        return 1
    fi
    
    log_info "Latest version: $version"
    
    # フォント固有のダウンロード処理
    case "$font_key" in
        "hackgen-nf"|"hackgen")
            download_hackgen "$GITHUB_REPO" "$version" "$temp_dir" "$font_dir"
            ;;
        "plemoljp")
            download_plemoljp "$GITHUB_REPO" "$version" "$temp_dir" "$font_dir"
            ;;
        "udev-gothic")
            download_udev_gothic "$GITHUB_REPO" "$version" "$temp_dir" "$font_dir"
            ;;
        "cica")
            download_cica "$GITHUB_REPO" "$version" "$temp_dir" "$font_dir"
            ;;
        *)
            download_generic_font "$GITHUB_REPO" "$version" "$temp_dir" "$font_dir" "$INSTALL_NAME"
            ;;
    esac
    
    local result=$?
    
    # フォントキャッシュの更新
    if [[ $result -eq 0 ]]; then
        update_font_cache
        log_success "$FONT_NAME installation completed"
    else
        log_error "$FONT_NAME installation failed"
    fi
    
    # 一時ディレクトリの削除
    rm -rf "$temp_dir"
    return $result
}

# HackGen固有のダウンロード処理
download_hackgen() {
    local repo="$1" version="$2" temp_dir="$3" font_dir="$4"
    local zip_name="HackGen_NF_${version}.zip"
    local download_url="https://github.com/${repo}/releases/download/${version}/${zip_name}"
    
    log_info "Downloading HackGen from: $download_url"
    
    if curl -fL -o "${temp_dir}/${zip_name}" "$download_url" && \
       cd "$temp_dir" && \
       extract_archive "$zip_name" "." && \
       find . -name "HackGen*.ttf" -exec cp {} "$font_dir/" \;; then
        return 0
    else
        return 1
    fi
}

# PlemolJP固有のダウンロード処理  
download_plemoljp() {
    local repo="$1" version="$2" temp_dir="$3" font_dir="$4"
    local zip_name="PlemolJP_NF_${version}.zip"
    local download_url="https://github.com/${repo}/releases/download/${version}/${zip_name}"
    
    log_info "Downloading PlemolJP from: $download_url"
    
    if curl -fL -o "${temp_dir}/${zip_name}" "$download_url" && \
       cd "$temp_dir" && \
       extract_archive "$zip_name" "." && \
       find . -name "PlemolJP*.ttf" -exec cp {} "$font_dir/" \;; then
        return 0
    else
        return 1
    fi
}

# UDEV Gothic固有のダウンロード処理
download_udev_gothic() {
    local repo="$1" version="$2" temp_dir="$3" font_dir="$4"
    
    # UDEV Gothicは複数のZIPファイルがある場合があるため、NF版を優先
    local api_url="https://api.github.com/repos/${repo}/releases/tags/${version}"
    local download_urls
    
    if command -v jq >/dev/null 2>&1; then
        download_urls=$(curl -s "$api_url" | jq -r '.assets[] | select(.name | contains("NF")) | .browser_download_url' | head -1)
    else
        download_urls=$(curl -s "$api_url" | grep -o '"browser_download_url": *"[^"]*"' | grep NF | head -1 | cut -d'"' -f4)
    fi
    
    if [[ -n "$download_urls" ]]; then
        local zip_name="$(basename "$download_urls")"
        log_info "Downloading UDEV Gothic from: $download_urls"
        
        if curl -fL -o "${temp_dir}/${zip_name}" "$download_urls" && \
           cd "$temp_dir" && \
           extract_archive "$zip_name" "." && \
           find . -name "UDEV*.ttf" -exec cp {} "$font_dir/" \;; then
            return 0
        fi
    fi
    return 1
}

# Cica固有のダウンロード処理
download_cica() {
    local repo="$1" version="$2" temp_dir="$3" font_dir="$4"
    local zip_name="Cica_${version}_without_emoji.zip"
    local download_url="https://github.com/${repo}/releases/download/${version}/${zip_name}"
    
    log_info "Downloading Cica from: $download_url"
    
    if curl -fL -o "${temp_dir}/${zip_name}" "$download_url" && \
       cd "$temp_dir" && \
       extract_archive "$zip_name" "." && \
       find . -name "Cica*.ttf" -exec cp {} "$font_dir/" \;; then
        return 0
    else
        return 1
    fi
}

# 汎用フォントダウンロード処理
download_generic_font() {
    local repo="$1" version="$2" temp_dir="$3" font_dir="$4" install_name="$5"
    
    # 汎用的なZIPファイル名のパターンを試行
    local zip_patterns=(
        "${install_name}_${version}.zip"
        "${install_name}-${version}.zip"
        "${version}.zip"
    )
    
    for pattern in "${zip_patterns[@]}"; do
        local download_url="https://github.com/${repo}/releases/download/${version}/${pattern}"
        log_info "Trying download from: $download_url"
        
        if curl -fL -o "${temp_dir}/${pattern}" "$download_url" && \
           cd "$temp_dir" && \
           extract_archive "$pattern" "." && \
           find . -name "*.ttf" -o -name "*.otf" | head -10 | xargs -I {} cp {} "$font_dir/"; then
            return 0
        fi
    done
    
    log_error "Could not download font from any common patterns"
    return 1
}

# フォントキャッシュの更新
update_font_cache() {
    local platform
    platform="$(detect_platform)"
    
    case "$platform" in
        "macos")
            # macOSでは自動的にフォントキャッシュが更新される
            log_info "Font cache will be updated automatically on macOS"
            ;;
        "linux")
            if command -v fc-cache >/dev/null 2>&1; then
                log_info "Updating font cache..."
                # Suppress fontconfig memory errors in CI environments
                fc-cache -fv >/dev/null 2>&1 || {
                    log_warning "Font cache update failed, but fonts may still work"
                }
            else
                log_warning "fc-cache not available, font cache not updated"
            fi
            ;;
    esac
}

# 統一フォントインストール関数
install_font() {
    local font_key="$1"
    local force_reinstall="${2:-false}"
    
    if [[ -z "$font_key" ]]; then
        log_error "Font key is required"
        return 1
    fi
    
    # フォント設定の初期化
    init_font_configs
    
    # フォント設定の検証
    if [[ -z "${FONT_CONFIGS[$font_key]:-}" ]]; then
        log_error "Unknown font: $font_key"
        log_info "Available fonts: ${!FONT_CONFIGS[*]}"
        return 1
    fi
    
    eval "$(parse_font_config "$font_key")"
    
    # インストール済みチェック
    if [[ "$force_reinstall" != "true" ]] && is_font_installed "$FONT_NAME"; then
        log_info "$FONT_NAME is already installed"
        return 0
    fi
    
    # プラットフォーム別インストール
    local platform
    platform="$(detect_platform)"
    
    case "$platform" in
        "macos")
            install_font_macos "$font_key"
            ;;
        "linux")
            install_font_linux "$font_key"
            ;;
        *)
            log_error "Font installation not supported on platform: $platform"
            return 1
            ;;
    esac
}

# 推奨フォントセットのインストール
install_recommended_fonts() {
    local font_profile="${1:-developer}"
    
    log_info "Installing recommended fonts for profile: $font_profile"
    
    # フォント設定の初期化
    init_font_configs
    
    case "$font_profile" in
        "developer"|"dev")
            local fonts=("jetbrains-mono-nf" "hackgen-nf" "plemoljp")
            ;;
        "japanese"|"jp")
            local fonts=("udev-gothic" "plemoljp" "cica")
            ;;
        "minimal")
            local fonts=("fira-code-nf")
            ;;
        "all")
            local fonts=("jetbrains-mono-nf" "hackgen-nf" "plemoljp" "udev-gothic" "cica" "fira-code-nf")
            ;;
        *)
            log_error "Unknown font profile: $font_profile"
            log_info "Available profiles: developer, japanese, minimal, all"
            return 1
            ;;
    esac
    
    local failed_count=0
    local success_count=0
    local skipped_count=0
    
    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install ${#fonts[@]} fonts for profile: $font_profile"
        return 0
    fi
    
    for font in "${fonts[@]}"; do
        # Check if font is already installed (skip logic)
        if [[ "$FORCE_INSTALL" != "true" ]] && check_font_installed "$font"; then
            log_skip_reason "Font: $font" "Already installed"
            ((skipped_count++))
            continue
        fi
        
        if [[ "$DRY_RUN" != "true" ]]; then
            if install_font "$font"; then
                success_count=$((success_count + 1))
            else
                failed_count=$((failed_count + 1))
            fi
        else
            log_info "[DRY RUN] Would install font: $font"
            ((success_count++))
        fi
    done
    
    # Enhanced summary with install_checker.sh integration
    if [[ "$DRY_RUN" != "true" ]]; then
        log_install_summary "$success_count" "$skipped_count" "$failed_count"
    else
        log_info "[DRY RUN] Font summary: $success_count would be installed, $skipped_count skipped"
    fi
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "🎉 All recommended fonts processed successfully"
        return 0
    else
        log_warning "⚠️  Some fonts failed to install. This may be normal for system-specific fonts."
        return 1
    fi
}

# インストール済みフォントの一覧表示
list_installed_fonts() {
    log_info "Checking installed fonts..."
    
    init_font_configs
    
    for font_key in "${!FONT_CONFIGS[@]}"; do
        eval "$(parse_font_config "$font_key")"
        
        if is_font_installed "$FONT_NAME"; then
            log_success "✓ $FONT_NAME ($font_key)"
        else
            log_info "✗ $FONT_NAME ($font_key)"
        fi
    done
}

# メイン関数（CLI対応）
main() {
    local command="${1:-help}"
    
    case "$command" in
        "install")
            install_font "$2" "$3"
            ;;
        "install-recommended")
            install_recommended_fonts "$2"
            ;;
        "list"|"ls")
            list_installed_fonts
            ;;
        "help"|*)
            echo "Font Manager - Modern font installation and management"
            echo ""
            echo "Usage:"
            echo "  $0 install <font-key> [force]     Install specific font"
            echo "  $0 install-recommended [profile]  Install recommended font set"
            echo "  $0 list                           List font installation status"
            echo ""
            echo "Font profiles:"
            echo "  developer  - Modern development fonts (default)"
            echo "  japanese   - Japanese-focused fonts"
            echo "  minimal    - Essential fonts only"
            echo "  all        - All available fonts"
            echo ""
            echo "Available fonts:"
            init_font_configs
            for font_key in "${!FONT_CONFIGS[@]}"; do
                eval "$(parse_font_config "$font_key")"
                echo "  $font_key - $FONT_NAME"
            done
            ;;
    esac
}

# スクリプトが直接実行された場合
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi