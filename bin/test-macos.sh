#!/usr/bin/env bash
# macOS専用テストスクリプト

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# テスト対象プラットフォームチェック
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This test script is only for macOS"
    exit 1
fi

echo "🍎 Running macOS-specific tests..."

# 基本システム情報
echo "=== System Information ==="
echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
echo "Architecture: $(uname -m)"

# Apple Silicon vs Intel Mac判定
if [[ "$(uname -m)" == "arm64" ]]; then
    echo "Platform: Apple Silicon Mac"
    EXPECTED_BREW_PREFIX="/opt/homebrew"
else
    echo "Platform: Intel Mac"
    EXPECTED_BREW_PREFIX="/usr/local"
fi

# Xcode Command Line Tools チェック
echo ""
echo "=== Xcode Command Line Tools ==="
if xcode-select -p &>/dev/null; then
    echo "✅ Xcode Command Line Tools installed at: $(xcode-select -p)"
else
    echo "❌ Xcode Command Line Tools not installed"
fi

# Homebrew チェック
echo ""
echo "=== Homebrew ==="
if command -v brew &>/dev/null; then
    echo "✅ Homebrew installed at: $(command -v brew)"
    echo "Prefix: $(brew --prefix)"
    
    # 期待されるパスかチェック
    if [[ "$(brew --prefix)" == "$EXPECTED_BREW_PREFIX" ]]; then
        echo "✅ Homebrew prefix is correct for this platform"
    else
        echo "⚠️  Homebrew prefix mismatch. Expected: $EXPECTED_BREW_PREFIX, Got: $(brew --prefix)"
    fi
else
    echo "❌ Homebrew not installed"
fi

# 依存関係チェック
echo ""
echo "=== Build Dependencies ==="
deps=("git" "cmake" "make" "ninja" "pkg-config" "gettext" "libtool" "autoconf" "automake" "unzip" "curl")
missing_deps=()

for dep in "${deps[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo "✅ $dep: $(command -v "$dep")"
    else
        echo "❌ $dep: not found"
        missing_deps+=("$dep")
    fi
done

if [[ ${#missing_deps[@]} -eq 0 ]]; then
    echo "✅ All build dependencies are satisfied"
else
    echo "❌ Missing dependencies: ${missing_deps[*]}"
fi

# PATH チェック
echo ""
echo "=== PATH Configuration ==="
echo "Current PATH:"
echo "$PATH" | tr ':' '\n' | nl

if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo "✅ $HOME/.local/bin is in PATH"
else
    echo "⚠️  $HOME/.local/bin is not in PATH"
fi

if command -v brew &>/dev/null; then
    brew_bin="$(dirname "$(command -v brew)")"
    if [[ ":$PATH:" == *":$brew_bin:"* ]]; then
        echo "✅ Homebrew bin directory ($brew_bin) is in PATH"
    else
        echo "⚠️  Homebrew bin directory ($brew_bin) is not in PATH"
    fi
fi

# Neovim統合管理システムテスト
echo ""
echo "=== Neovim Unified Manager Test ==="
if [[ -x "$DOTFILES_DIR/bin/neovim-unified-manager.sh" ]]; then
    echo "✅ Neovim unified manager script found"
    
    # プラットフォーム検出テスト
    if bash "$DOTFILES_DIR/bin/neovim-unified-manager.sh" deps 2>&1 | grep -q "Installing dependencies for macOS"; then
        echo "✅ macOS platform detection working"
    else
        echo "❌ macOS platform detection failed"
    fi
else
    echo "❌ Neovim unified manager script not found"
fi

echo ""
echo "🍎 macOS test completed"

# 推奨アクション
echo ""
echo "=== Recommendations ==="
if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "💡 Install missing dependencies with:"
    echo "   make neovim-unified-deps"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "💡 Add to your shell profile:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

if ! xcode-select -p &>/dev/null; then
    echo "💡 Install Xcode Command Line Tools:"
    echo "   xcode-select --install"
fi