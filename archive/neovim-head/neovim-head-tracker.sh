#!/usr/bin/env bash
# neovim-head-tracker.sh
# Neovim HEAD自動追跡・ビルドシステム（Nix overlay方式参考）
# yutkat dotfiles方式に対応した完全自動ビルド

set -euo pipefail

# ===== 設定 =====
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BASE_DIR="$HOME/.local/neovim-head"
readonly BUILD_DIR="$BASE_DIR/build"
readonly SOURCE_DIR="$BASE_DIR/neovim"
readonly DEPS_DIR="$BASE_DIR/.deps"
readonly INSTALL_DIR="$HOME/.local"
readonly LOG_FILE="$BASE_DIR/build.log"

# ビルド設定
readonly BUILD_TYPE="${BUILD_TYPE:-RelWithDebInfo}"
readonly CMAKE_OPTS="${CMAKE_OPTS:-}"
readonly PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"

# カラー出力
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ===== ロギング関数 =====
init_log_file() {
    mkdir -p "$(dirname "$LOG_FILE")"
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "=== Neovim HEAD Tracker Log ===" > "$LOG_FILE"
        echo "Started at: $(date)" >> "$LOG_FILE"
    fi
}

log_info() {
    init_log_file
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    init_log_file
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    init_log_file
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    init_log_file
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

# ===== 環境チェック =====
check_dependencies() {
    local missing_deps=()
    
    # プラットフォーム検出
    local platform
    case "$(uname -s)" in
        Darwin*) platform="macos" ;;
        Linux*)  platform="linux" ;;
        *)       platform="unknown" ;;
    esac
    
    # プラットフォーム別の必須依存関係チェック
    if [[ "$platform" == "macos" ]]; then
        # macOS用の依存関係チェック
        for dep in git cmake make ninja pkg-config; do
            if ! command -v "$dep" &> /dev/null; then
                missing_deps+=("$dep")
            fi
        done
        
        # Xcodeコマンドラインツールのチェック
        if ! xcode-select -p &>/dev/null; then
            log_error "Xcode command line tools not installed"
            log_info "Install with: xcode-select --install"
            exit 1
        fi
    else
        # Linux用の依存関係チェック
        for dep in git cmake make ninja gcc g++ pkg-config; do
            if ! command -v "$dep" &> /dev/null; then
                missing_deps+=("$dep")
            fi
        done
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        if [[ "$platform" == "macos" ]]; then
            log_info "Install with: brew install ${missing_deps[*]}"
        else
            log_info "Install with: sudo apt install ${missing_deps[*]}"
        fi
        exit 1
    fi
    
    log_success "All dependencies satisfied"
}

# ===== Nixスタイル deps.txt パーサー =====
parse_deps_txt() {
    local deps_file="$SOURCE_DIR/cmake.deps/deps.txt"
    local output_file="$BASE_DIR/parsed_deps.json"
    
    if [[ ! -f "$deps_file" ]]; then
        log_error "deps.txt not found: $deps_file"
        return 1
    fi
    
    log_info "Parsing deps.txt..."
    
    # JSONフォーマットで依存関係情報を生成
    echo "{" > "$output_file"
    
    local current_dep=""
    local url=""
    local sha256=""
    local first_entry=true
    
    while IFS= read -r line; do
        if [[ $line =~ ^([A-Z0-9_]+)_URL[[:space:]]+(.+)$ ]]; then
            # 前の依存関係を出力
            if [[ -n "$current_dep" && -n "$url" && -n "$sha256" ]]; then
                if [[ "$first_entry" != true ]]; then
                    echo "," >> "$output_file"
                fi
                echo "  \"$current_dep\": {" >> "$output_file"
                echo "    \"url\": \"$url\"," >> "$output_file"
                echo "    \"sha256\": \"$sha256\"" >> "$output_file"
                echo -n "  }" >> "$output_file"
                first_entry=false
            fi
            
            current_dep="${BASH_REMATCH[1]}"
            url="${BASH_REMATCH[2]}"
            sha256=""
        elif [[ $line =~ ^([A-Z0-9_]+)_SHA256[[:space:]]+(.+)$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == "$current_dep" ]]; then
                sha256="${BASH_REMATCH[2]}"
            fi
        fi
    done < "$deps_file"
    
    # 最後の依存関係を出力
    if [[ -n "$current_dep" && -n "$url" && -n "$sha256" ]]; then
        if [[ "$first_entry" != true ]]; then
            echo "," >> "$output_file"
        fi
        echo "  \"$current_dep\": {" >> "$output_file"
        echo "    \"url\": \"$url\"," >> "$output_file"
        echo "    \"sha256\": \"$sha256\"" >> "$output_file"
        echo -n "  }" >> "$output_file"
    fi
    
    echo "" >> "$output_file"
    echo "}" >> "$output_file"
    
    log_success "Parsed deps.txt to $output_file"
}

# ===== Git操作 =====
update_source() {
    log_info "Updating Neovim source..."
    
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_info "Cloning Neovim repository..."
        git clone --depth 1 https://github.com/neovim/neovim.git "$SOURCE_DIR"
    else
        log_info "Updating existing repository..."
        cd "$SOURCE_DIR"
        git fetch origin
        git reset --hard origin/master
    fi
    
    cd "$SOURCE_DIR"
    local current_commit=$(git rev-parse HEAD)
    local short_commit=$(git rev-parse --short HEAD)
    
    log_success "Updated to commit: $current_commit"
    echo "$current_commit" > "$BASE_DIR/current_commit"
    echo "$short_commit" > "$BASE_DIR/current_commit_short"
    
    # deps.txtを解析
    parse_deps_txt
}

# ===== バージョン情報生成 =====
generate_version_info() {
    local short_commit=$(cat "$BASE_DIR/current_commit_short" 2>/dev/null || echo "unknown")
    local version_string="v0.12.0-dev-nightly+g$short_commit"
    
    echo "$version_string" > "$BASE_DIR/version"
    log_info "Generated version: $version_string"
}

# ===== Nixスタイル Tree-sitter bundled設定 =====
configure_treesitter() {
    log_info "Configuring bundled Tree-sitter..."
    
    # deps.txtからTree-sitter情報を取得
    if [[ -f "$BASE_DIR/parsed_deps.json" ]]; then
        local treesitter_url=$(grep -A2 '"TREESITTER"' "$BASE_DIR/parsed_deps.json" | grep '"url"' | cut -d'"' -f4)
        local treesitter_sha=$(grep -A2 '"TREESITTER"' "$BASE_DIR/parsed_deps.json" | grep '"sha256"' | cut -d'"' -f4)
        
        log_info "Tree-sitter URL: $treesitter_url"
        log_info "Tree-sitter SHA256: $treesitter_sha"
        
        # Tree-sitterバージョン情報を保存
        echo "$treesitter_url" > "$BASE_DIR/treesitter_url"
        echo "$treesitter_sha" > "$BASE_DIR/treesitter_sha"
    fi
}

# ===== ビルド処理 =====
build_dependencies() {
    log_info "Building dependencies..."
    
    cd "$SOURCE_DIR"
    
    # 依存関係ビルド（Nixスタイル）
    if [[ -d "$DEPS_DIR" ]]; then
        log_info "Cleaning existing dependencies..."
        rm -rf "$DEPS_DIR"
    fi
    
    # USE_BUNDLED=1でbundled dependenciesを使用
    cmake -S cmake.deps -B "$DEPS_DIR" \
        -G Ninja \
        -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -D USE_BUNDLED=1 \
        $CMAKE_OPTS
    
    cmake --build "$DEPS_DIR" --config "$BUILD_TYPE" --parallel "$PARALLEL_JOBS"
    
    log_success "Dependencies built successfully"
}

build_neovim() {
    log_info "Building Neovim..."
    
    cd "$SOURCE_DIR"
    
    # ビルドディレクトリをクリーン
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi
    
    # PKG_CONFIG_PATHを設定してbundled依存関係を確実に検出
    export PKG_CONFIG_PATH="$DEPS_DIR/usr/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="$DEPS_DIR/usr:${CMAKE_PREFIX_PATH:-}"
    
    # Neovim本体ビルド（bundled依存関係を明示的に指定）
    cmake -B "$BUILD_DIR" \
        -G Ninja \
        -D CMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -D CMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -D USE_BUNDLED=1 \
        -D CMAKE_PREFIX_PATH="$DEPS_DIR/usr" \
        -D DEPS_PREFIX="$DEPS_DIR/usr" \
        -D LUV_LIBRARY="$DEPS_DIR/usr/lib/libluv.a" \
        -D LUV_INCLUDE_DIR="$DEPS_DIR/usr/include" \
        $CMAKE_OPTS
    
    cmake --build "$BUILD_DIR" --config "$BUILD_TYPE" --parallel "$PARALLEL_JOBS"
    
    log_success "Neovim built successfully"
}

install_neovim() {
    log_info "Installing Neovim..."
    
    cd "$SOURCE_DIR"
    cmake --install "$BUILD_DIR" --config "$BUILD_TYPE"
    
    # バージョン情報を確認
    if [[ -x "$INSTALL_DIR/bin/nvim" ]]; then
        local installed_version=$("$INSTALL_DIR/bin/nvim" --version | head -1)
        log_success "Installed: $installed_version"
        echo "$installed_version" > "$BASE_DIR/installed_version"
        
        # 統合管理システム用の状態更新
        local unified_state_file="$HOME/.neovim_unified_state"
        echo "head" > "$unified_state_file"
        log_info "Updated unified manager state to HEAD"
    else
        log_error "Installation failed: nvim executable not found"
        return 1
    fi
}

# ===== 更新チェック =====
check_for_updates() {
    log_info "Checking for updates..."
    
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_info "No local repository found, will clone"
        return 0
    fi
    
    cd "$SOURCE_DIR"
    git fetch origin
    
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/master)
    
    if [[ "$local_commit" != "$remote_commit" ]]; then
        log_info "Updates available: $local_commit -> $remote_commit"
        return 0
    else
        log_info "Already up to date"
        return 1
    fi
}

# ===== ステータス表示 =====
show_status() {
    echo -e "${BLUE}=== Neovim HEAD Tracker Status ===${NC}"
    
    if [[ -f "$BASE_DIR/version" ]]; then
        echo "Version: $(cat "$BASE_DIR/version")"
    fi
    
    if [[ -f "$BASE_DIR/current_commit" ]]; then
        echo "Commit: $(cat "$BASE_DIR/current_commit")"
    fi
    
    if [[ -f "$BASE_DIR/installed_version" ]]; then
        echo "Installed: $(cat "$BASE_DIR/installed_version")"
    fi
    
    if [[ -x "$INSTALL_DIR/bin/nvim" ]]; then
        echo -e "${GREEN}Neovim is installed and ready${NC}"
    else
        echo -e "${YELLOW}Neovim not installed${NC}"
    fi
}

# ===== 初期化 =====
init_environment() {
    log_info "Initializing environment..."
    
    # ディレクトリ作成
    mkdir -p "$BASE_DIR" "$BUILD_DIR" "$DEPS_DIR"
    
    # ログファイルは init_log_file() で初期化済み
}

# ===== メイン処理 =====
main() {
    local command="${1:-build}"
    
    case "$command" in
        "check")
            check_dependencies
            ;;
        "status")
            show_status
            ;;
        "update")
            init_environment
            check_dependencies
            if check_for_updates; then
                update_source
                generate_version_info
                configure_treesitter
                build_dependencies
                build_neovim
                install_neovim
            fi
            ;;
        "build"|"")
            init_environment
            check_dependencies
            update_source
            generate_version_info
            configure_treesitter
            build_dependencies
            build_neovim
            install_neovim
            ;;
        "clean")
            log_info "Cleaning build artifacts..."
            rm -rf "$BUILD_DIR" "$DEPS_DIR"
            log_success "Cleaned"
            ;;
        "clean-all")
            log_info "Cleaning all data..."
            rm -rf "$BASE_DIR"
            log_success "All data cleaned"
            ;;
        *)
            echo "Usage: $0 {build|update|status|check|clean|clean-all}"
            echo ""
            echo "Commands:"
            echo "  build     - Full build (default)"
            echo "  update    - Update only if changes available"
            echo "  status    - Show current status"
            echo "  check     - Check dependencies"
            echo "  clean     - Clean build artifacts"
            echo "  clean-all - Clean all data"
            exit 1
            ;;
    esac
}

# ===== 実行 =====
main "$@"