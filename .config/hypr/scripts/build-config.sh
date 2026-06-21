#!/usr/bin/env bash
# =====================================================
# Hyprland Configuration Builder
# =====================================================
# Generates monitor config from template using monitor settings
# =====================================================

set -euo pipefail

# =====================================================
# Directory Setup
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# =====================================================
# Check Dependencies
# =====================================================

if ! command -v envsubst >/dev/null 2>&1; then
    echo "❌ Error: envsubst not found"
    echo "Install: sudo pacman -S gettext (Arch) or sudo apt install gettext-base (Ubuntu)"
    exit 1
fi

# =====================================================
# Load Monitor Configuration
# =====================================================

if [[ ! -f "monitors.env" ]]; then
    echo "⚠️  monitors.env not found. Creating from example..."

    if [[ -f "monitors.env.example" ]]; then
        cp monitors.env.example monitors.env
        echo "✅ Created monitors.env from example"
        echo ""
        echo "📝 Please edit monitors.env to match your hardware:"
        echo "   hyprctl monitors  # Check your monitor names"
        echo "   nvim monitors.env  # Edit configuration"
        echo ""
    else
        echo "❌ Error: monitors.env.example not found"
        exit 1
    fi
fi

# Load environment variables
# shellcheck disable=SC1091
source monitors.env

# Validate required variables
if [[ -z "${MONITOR_MAIN:-}" ]]; then
    echo "❌ Error: MONITOR_MAIN not set in monitors.env"
    exit 1
fi

# =====================================================
# Detect Display Configuration
# =====================================================

if [[ -z "${MONITOR_SUB:-}" ]]; then
    DISPLAY_MODE="single"
    echo "🔧 Building monitor configuration..."
    echo "   Display Mode: Single"
    echo "   Monitor: $MONITOR_MAIN (Workspaces 1-10)"
else
    DISPLAY_MODE="dual"
    echo "🔧 Building monitor configuration..."
    echo "   Display Mode: Dual"
    echo "   Main Monitor: $MONITOR_MAIN (Workspaces 1-5)"
    echo "   Sub Monitor:  $MONITOR_SUB (Workspaces 6-10)"
fi

# =====================================================
# Build Configuration
# =====================================================

# Export for envsubst
export MONITOR_MAIN
# Set default value for MONITOR_SUB to avoid envsubst errors
export MONITOR_SUB="${MONITOR_SUB:-}"

# Generate base config from template
envsubst < config.template.jsonc > config.jsonc.tmp

# Adjust persistent-workspaces based on display mode
if [[ "$DISPLAY_MODE" == "single" ]]; then
    # Single display: Replace persistent-workspaces to assign all workspaces (1-10) to main monitor
    # Use sed to replace the entire persistent-workspaces block
    sed -i '/^ *"persistent-workspaces": {$/,/^    },$/c\
    "persistent-workspaces": {\
      "'"$MONITOR_MAIN"'": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\
    },' config.jsonc.tmp
    mv config.jsonc.tmp config.jsonc
else
    # Dual display: Keep the template configuration
    mv config.jsonc.tmp config.jsonc
fi

echo "✅ Configuration generated: config.jsonc"

# =====================================================
# Restart Caelestia Shell
# =====================================================

if systemctl --user is-active --quiet caelestia.service; then
    echo "🔄 Restarting Caelestia Shell..."
    "$HOME/.config/hypr/scripts/restart-shell.sh" &
    disown
    echo "✅ Caelestia Shell restarted"
else
    echo "ℹ️  Caelestia Shell is not running. Start it with: systemctl --user start caelestia.service"
fi

echo ""
echo "✨ Done!"
