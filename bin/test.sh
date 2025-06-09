#!/usr/bin/env bash

# dotfiles テストスクリプト
# 主要な機能の動作確認を行います

# 共通ライブラリをインポート
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config_loader.sh"

# エラーハンドリング設定
setup_error_handling

# テスト結果を記録
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo "------------------------------------------------------------"
    echo "Test: $test_name"
    echo "------------------------------------------------------------"
    
    if eval "$test_command"; then
        log_success "✓ PASSED: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "✗ FAILED: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# 個別テスト関数
test_platform_detection() {
    local platform
    platform="$(detect_platform)"
    
    if [[ -n "$platform" ]] && [[ "$platform" != "unknown" ]]; then
        echo "Platform detected: $platform"
        return 0
    else
        echo "Failed to detect platform"
        return 1
    fi
}

test_architecture_detection() {
    local arch
    arch="$(detect_architecture)"
    
    if [[ -n "$arch" ]]; then
        echo "Architecture detected: $arch"
        return 0
    else
        echo "Failed to detect architecture"
        return 1
    fi
}

test_os_info_compatibility() {
    local os_info
    os_info="$(get_os_info)"
    
    if [[ -n "$os_info" ]]; then
        echo "OS info: $os_info"
        return 0
    else
        echo "Failed to get OS info"
        return 1
    fi
}

test_package_manager_detection() {
    local pkg_manager
    pkg_manager="$(detect_package_manager)"
    
    if [[ -n "$pkg_manager" ]]; then
        echo "Package manager detected: $pkg_manager"
        return 0
    else
        echo "No package manager detected (this may be normal)"
        return 0  # Not finding a package manager is not necessarily an error
    fi
}

test_config_loading() {
    load_config
    
    # 基本的な設定値が存在するかチェック
    if [[ -n "${DOTFILES_DIR:-}" ]] && [[ -n "${NVM_VERSION:-}" ]]; then
        echo "Configuration loaded successfully"
        echo "DOTFILES_DIR: ${DOTFILES_DIR}"
        echo "NVM_VERSION: ${NVM_VERSION}"
        return 0
    else
        echo "Failed to load configuration"
        return 1
    fi
}

test_command_checks() {
    # 基本的なコマンドの存在確認
    local commands=("git" "curl" "bash")
    local failed=0
    
    for cmd in "${commands[@]}"; do
        if check_command_exists "$cmd"; then
            echo "✓ $cmd is available"
        else
            echo "✗ $cmd is not available"
            failed=1
        fi
    done
    
    return $failed
}

test_file_operations() {
    local test_dir="/tmp/dotfiles_test_$$"
    local test_file="$test_dir/test_file"
    
    # テスト用ディレクトリとファイルを作成
    mkdir -p "$test_dir"
    echo "test content" > "$test_file"
    
    # ファイル存在チェック
    if check_file_exists "$test_file" && check_dir_exists "$test_dir"; then
        echo "File and directory checks passed"
        rm -rf "$test_dir"
        return 0
    else
        echo "File and directory checks failed"
        rm -rf "$test_dir"
        return 1
    fi
}

test_log_functions() {
    echo "Testing log functions:"
    log_info "This is an info message"
    log_success "This is a success message"
    log_warning "This is a warning message"
    log_error "This is an error message" 2>/dev/null || true
    
    echo "Log function test completed"
    return 0
}

# メイン実行
main() {
    echo "============================================================"
    echo "Dotfiles Test Suite"
    echo "============================================================"
    echo ""
    
    # テスト実行
    run_test "Platform Detection" "test_platform_detection"
    run_test "Architecture Detection" "test_architecture_detection"
    run_test "OS Info Compatibility" "test_os_info_compatibility"
    run_test "Package Manager Detection" "test_package_manager_detection"
    run_test "Configuration Loading" "test_config_loading"
    run_test "Command Existence Checks" "test_command_checks"
    run_test "File Operations" "test_file_operations"
    run_test "Log Functions" "test_log_functions"
    
    # 結果表示
    echo ""
    echo "============================================================"
    echo "Test Results"
    echo "============================================================"
    echo "Total tests: $TESTS_TOTAL"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "All tests passed! ✨"
        return 0
    else
        log_error "Some tests failed. Please check the output above."
        return 1
    fi
}

# スクリプトが直接実行された場合のみメイン関数を実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi