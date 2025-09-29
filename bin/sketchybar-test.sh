#!/usr/bin/env bash

# SketchyBar Test and Verification Script
# Tests both shell and Lua configurations

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"

setup_error_handling

log_info "Testing SketchyBar configurations..."

# Configuration paths
CONFIG_DIR="$HOME/.config/sketchybar"
SHELL_CONFIG="$CONFIG_DIR/sketchybarrc"
LUA_CONFIG="$CONFIG_DIR/sketchybarrc.lua"
PLUGINS_DIR="$CONFIG_DIR/plugins"

# Test functions
test_sketchybar_installed() {
    log_info "Testing SketchyBar installation..."

    if command -v sketchybar >/dev/null 2>&1; then
        local version=$(sketchybar --version 2>/dev/null || echo "unknown")
        log_info "✅ SketchyBar is installed (version: $version)"
        return 0
    else
        log_error "❌ SketchyBar is not installed"
        return 1
    fi
}

test_sbarlua_installed() {
    log_info "Testing SbarLua installation..."

    local sbarlua_path="$HOME/.local/share/sketchybar_lua/sketchybar.so"
    if [[ -f "$sbarlua_path" ]]; then
        log_info "✅ SbarLua is installed at: $sbarlua_path"

        # Test with proper package path
        if lua -e 'package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"; require("sketchybar")' >/dev/null 2>&1; then
            log_info "✅ SbarLua module loads successfully"
            return 0
        else
            log_warning "⚠️ SbarLua installed but module fails to load"
            return 1
        fi
    else
        log_error "❌ SbarLua is not installed"
        return 1
    fi
}


test_lua_config() {
    log_info "Testing Lua configuration..."

    if [[ -f "$LUA_CONFIG" ]]; then
        log_info "✅ Lua configuration exists: $LUA_CONFIG"

        # Basic syntax check
        if lua -e "dofile('$LUA_CONFIG')" >/dev/null 2>&1; then
            log_info "✅ Lua configuration syntax is valid"
        else
            log_warning "⚠️ Lua configuration has syntax issues"
        fi
        return 0
    else
        log_warning "⚠️ Lua configuration not found: $LUA_CONFIG"
        log_info "💡 Create Lua configuration manually in $LUA_CONFIG"
        return 1
    fi
}

test_plugins() {
    log_info "Testing plugin files..."

    local required_plugins=(
        "aerospace.sh"
        "front_app.sh"
        "clock.sh"
        "volume.sh"
        "battery.sh"
        "amphetamine.sh"
        "ime_indicator.sh"
    )

    local missing_plugins=()
    local working_plugins=()

    for plugin in "${required_plugins[@]}"; do
        local plugin_path="$PLUGINS_DIR/$plugin"
        if [[ -f "$plugin_path" ]]; then
            if [[ -x "$plugin_path" ]]; then
                working_plugins+=("$plugin")
            else
                log_warning "⚠️ Plugin not executable: $plugin"
            fi
        else
            missing_plugins+=("$plugin")
        fi
    done

    log_info "✅ Working plugins: ${#working_plugins[@]}/${#required_plugins[@]}"

    if [[ ${#missing_plugins[@]} -gt 0 ]]; then
        log_warning "Missing plugins:"
        for plugin in "${missing_plugins[@]}"; do
            log_warning "  - $plugin"
        done
        return 1
    else
        log_info "✅ All required plugins are present and executable"
        return 0
    fi
}

test_dependencies() {
    log_info "Testing external dependencies..."

    local deps_ok=true

    # Check aerospace
    if command -v aerospace >/dev/null 2>&1; then
        log_info "✅ Aerospace is available"
    else
        log_warning "⚠️ Aerospace not found (workspace switching may not work)"
        deps_ok=false
    fi

    # Check amphetamine (if process is running)
    if pgrep -x "Amphetamine" >/dev/null 2>&1; then
        log_info "✅ Amphetamine is running"
    else
        log_info "ℹ️ Amphetamine is not currently running"
    fi

    # Check sketchybar service
    if brew services list | grep -q "sketchybar.*started"; then
        log_info "✅ SketchyBar service is running"
    else
        log_info "ℹ️ SketchyBar service is not running"
        log_info "💡 Start with: brew services start sketchybar"
    fi

    return 0
}

show_usage_examples() {
    log_info "Usage examples:"
    echo
    echo "🚀 Setup commands:"
    echo "  make sketchybar-install   # Install SketchyBar + SbarLua"
    echo "  make sketchybar-test      # Test Lua configuration"
    echo
    echo "🔧 Service management:"
    echo "  brew services start sketchybar     # Start SketchyBar service"
    echo "  brew services stop sketchybar      # Stop SketchyBar service"
    echo "  brew services restart sketchybar   # Restart SketchyBar service"
    echo
    echo "📁 Configuration files:"
    echo "  Lua config: $LUA_CONFIG"
    echo "  Plugins:    $PLUGINS_DIR/"
}

# Test Lua configuration syntax and validity
test_lua_syntax() {
    log_info "Testing Lua configuration syntax..."

    if [[ ! -f "$LUA_CONFIG" ]]; then
        log_error "❌ Lua configuration not found: $LUA_CONFIG"
        log_info "💡 Create Lua configuration manually in $LUA_CONFIG"
        return 1
    fi

    if lua -e "dofile('$LUA_CONFIG')" >/dev/null 2>&1; then
        log_info "✅ Lua configuration syntax is valid"
        return 0
    else
        log_error "❌ Lua configuration has syntax errors"
        return 1
    fi
}

# Test performance and responsiveness
test_performance() {
    log_info "Testing SketchyBar performance..."

    if ! pgrep -f sketchybar >/dev/null; then
        log_warning "⚠️ SketchyBar is not running, skipping performance test"
        return 0
    fi

    # Check CPU usage
    local cpu_usage=$(ps -p $(pgrep sketchybar) -o %cpu --no-headers | tr -d ' ')
    if [[ -n "$cpu_usage" ]] && (( $(echo "$cpu_usage > 5.0" | bc -l) )); then
        log_warning "⚠️ SketchyBar CPU usage is high: ${cpu_usage}%"
    else
        log_info "✅ SketchyBar CPU usage is normal: ${cpu_usage:-unknown}%"
    fi

    # Check memory usage
    local mem_usage=$(ps -p $(pgrep sketchybar) -o rss --no-headers | tr -d ' ')
    if [[ -n "$mem_usage" ]] && (( mem_usage > 50000 )); then
        log_warning "⚠️ SketchyBar memory usage is high: $((mem_usage/1024))MB"
    else
        log_info "✅ SketchyBar memory usage is normal: $((${mem_usage:-0}/1024))MB"
    fi

    return 0
}

# Test Lua configuration completeness
test_lua_completeness() {
    log_info "Checking Lua configuration completeness..."

    if [[ ! -f "$LUA_CONFIG" ]]; then
        log_warning "⚠️ Lua configuration not found"
        return 1
    fi

    local lua_lines=$(wc -l < "$LUA_CONFIG")
    log_info "Lua config: $lua_lines lines"

    # Check for essential components
    local essential_items=("sbar.bar" "sbar.default" "workspace" "plugins")
    local missing_items=()

    for item in "${essential_items[@]}"; do
        if ! grep -q "$item" "$LUA_CONFIG"; then
            missing_items+=("$item")
        fi
    done

    if [[ ${#missing_items[@]} -eq 0 ]]; then
        log_info "✅ Lua configuration appears complete"
        return 0
    else
        log_warning "⚠️ Missing components in Lua config:"
        for item in "${missing_items[@]}"; do
            log_warning "  - $item"
        done
        return 1
    fi
}

# Main function
main() {
    local mode="${1:-full}"

    log_info "=== SketchyBar Lua Configuration Test ==="
    echo

    # Check if running on macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_error "This script is only for macOS"
        exit 1
    fi

    local overall_status=0

    case "$mode" in
        "full"|"")
            # Run all tests
            test_sketchybar_installed || overall_status=1
            echo

            test_sbarlua_installed || overall_status=1
            echo

            test_lua_config || overall_status=1
            echo

            test_plugins || overall_status=1
            echo

            test_lua_syntax || overall_status=1
            echo

            test_lua_completeness || overall_status=1
            echo

            test_dependencies
            echo

            test_performance
            echo
            ;;
        "syntax")
            test_lua_syntax || overall_status=1
            ;;
        "performance")
            test_performance || overall_status=1
            ;;
        "quick")
            test_sketchybar_installed || overall_status=1
            test_sbarlua_installed || overall_status=1
            test_dependencies || overall_status=1
            ;;
        *)
            echo "Usage: $0 [full|syntax|performance|quick]"
            echo "  full        - Run all tests (default)"
            echo "  syntax      - Test Lua syntax only"
            echo "  performance - Test performance only"
            echo "  quick       - Quick dependency check"
            exit 1
            ;;
    esac

    # Show summary
    if [[ $overall_status -eq 0 ]]; then
        log_info "🎉 All tests passed! SketchyBar Lua configuration is ready."
    else
        log_warning "⚠️ Some tests failed. Please check the issues above."
    fi

    if [[ "$mode" == "full" || "$mode" == "" ]]; then
        echo
        show_usage_examples
    fi
}

# Run main function
main "$@"