#!/usr/bin/env bash
# =====================================================
# Hyprland Monitor Auto-Detection Script
# =====================================================
# Automatically detects connected monitors and generates
# configuration for both Hyprland and Waybar
#
# Usage:
#   ./auto-detect-monitors.sh           # Interactive mode
#   ./auto-detect-monitors.sh --auto    # Auto-detect without confirmation
#   ./auto-detect-monitors.sh --mode single   # Force single display
#   ./auto-detect-monitors.sh --mode dual     # Force dual display
# =====================================================

set -euo pipefail

# =====================================================
# Variables
# =====================================================

MODE=""           # Display mode: "single", "dual", or "" (auto-detect)
AUTO_MODE=false   # Skip interactive menu if true
PRIMARY_TRANSFORM=0    # Primary monitor orientation: 0=landscape, 1=90°, 2=180°, 3=270°
SECONDARY_TRANSFORM=0  # Secondary monitor orientation: 0=landscape, 1=90°, 2=180°, 3=270°
SECONDARY_POSITION="left"  # Secondary monitor position: "left", "right", "above", "below"

# =====================================================
# Colors and Logging
# =====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC}  $*"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $*"
}

log_error() {
    echo -e "${RED}✗${NC}  $*"
}

# =====================================================
# Help Function
# =====================================================

show_help() {
    cat << EOF
${BOLD}Hyprland Monitor Auto-Detection Script${NC}

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    -h, --help          Show this help message
    -a, --auto, -y      Auto-detect mode without confirmation (skip interactive menu)
    -m, --mode MODE     Force display mode: "single" or "dual"

${BOLD}EXAMPLES:${NC}
    $0                          # Interactive mode (recommended)
    $0 --auto                   # Auto-detect and apply without confirmation
    $0 --mode single            # Force single display mode
    $0 --mode dual              # Force dual display mode

${BOLD}INTERACTIVE MODE:${NC}
    When run without options, the script will:
    1. Detect connected monitors
    2. Show interactive menu for mode selection
    3. Generate configuration based on your choice

EOF
    exit 0
}

# =====================================================
# Parse Command Line Options
# =====================================================

parse_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -a|--auto|-y)
                AUTO_MODE=true
                shift
                ;;
            -m|--mode)
                if [[ -n "${2:-}" ]]; then
                    MODE="$2"
                    if [[ "$MODE" != "single" && "$MODE" != "dual" ]]; then
                        log_error "Invalid mode: $MODE. Use 'single' or 'dual'."
                        exit 1
                    fi
                    shift 2
                else
                    log_error "--mode requires an argument (single or dual)"
                    exit 1
                fi
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# Parse command line options
parse_options "$@"

# =====================================================
# Check Dependencies
# =====================================================

if ! command -v hyprctl >/dev/null 2>&1; then
    log_error "hyprctl not found. This script requires Hyprland."
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    log_error "jq not found. Install: sudo pacman -S jq"
    exit 1
fi

# =====================================================
# Directory Setup
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_DIR="$(dirname "$SCRIPT_DIR")/waybar"

HYPR_MONITORS_CONF="${SCRIPT_DIR}/monitors.conf"
WAYBAR_MONITORS_ENV="${WAYBAR_DIR}/monitors.env"

# =====================================================
# Detect Monitors
# =====================================================

log_info "Detecting connected monitors..."

# Get monitor information as JSON
MONITORS_JSON=$(hyprctl monitors -j)

# Count monitors
MONITOR_COUNT=$(echo "$MONITORS_JSON" | jq 'length')

log_info "Found $MONITOR_COUNT monitor(s)"

if [[ $MONITOR_COUNT -eq 0 ]]; then
    log_error "No monitors detected"
    exit 1
fi

# Extract monitor names
MONITOR_NAMES=$(echo "$MONITORS_JSON" | jq -r '.[].name')
MONITOR_ARRAY=()
while IFS= read -r name; do
    MONITOR_ARRAY+=("$name")
done <<< "$MONITOR_NAMES"

# Get focused monitor (primary)
PRIMARY_MONITOR=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.focused == true) | .name')

# If no focused monitor, use first one
if [[ -z "$PRIMARY_MONITOR" ]]; then
    PRIMARY_MONITOR="${MONITOR_ARRAY[0]}"
fi

log_info "Primary monitor: $PRIMARY_MONITOR"

# Display detected monitors
echo ""
log_info "Detected monitors:"
for i in "${!MONITOR_ARRAY[@]}"; do
    monitor="${MONITOR_ARRAY[$i]}"
    info=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$monitor\") | \"\(.width)x\(.height)@\(.refreshRate | floor)Hz\"")

    if [[ "$monitor" == "$PRIMARY_MONITOR" ]]; then
        echo "  ${GREEN}●${NC} $monitor - $info (primary)"
    else
        echo "  ○ $monitor - $info"
    fi
done
echo ""

# =====================================================
# Interactive Menu
# =====================================================

show_orientation_menu() {
    local monitor_name="$1"
    local default_transform="${2:-0}"
    local is_primary="${3:-false}"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    if [[ "$is_primary" == "true" ]]; then
        echo -e "${BOLD}  Primary Monitor Orientation${NC}"
    else
        echo -e "${BOLD}  Secondary Monitor Orientation${NC}"
    fi
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Monitor: ${CYAN}${monitor_name}${NC}"
    echo ""
    echo -e "${BOLD}Select orientation:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Landscape (0°) - Normal horizontal"
    echo -e "  ${CYAN}2)${NC} Portrait Right (90°) - Rotated right"
    echo -e "  ${CYAN}3)${NC} Upside Down (180°) - Flipped"
    echo -e "  ${CYAN}4)${NC} Portrait Left (270°) - Rotated left ${YELLOW}[Recommended for portrait]${NC}"
    echo ""

    local default_choice=1
    case $default_transform in
        0) default_choice=1 ;;
        1) default_choice=2 ;;
        2) default_choice=3 ;;
        3) default_choice=4 ;;
    esac

    echo -ne "${BOLD}Enter your choice [1-4] (default: ${default_choice}): ${NC}"

    read -r choice
    choice=${choice:-$default_choice}
    echo ""

    local selected_transform=0
    case $choice in
        1)
            log_info "Selected: Landscape (0°)"
            selected_transform=0
            ;;
        2)
            log_info "Selected: Portrait Right (90°)"
            selected_transform=1
            ;;
        3)
            log_info "Selected: Upside Down (180°)"
            selected_transform=2
            ;;
        4)
            log_info "Selected: Portrait Left (270°)"
            selected_transform=3
            ;;
        *)
            log_warning "Invalid choice: $choice, using default (${default_choice})"
            selected_transform=$default_transform
            ;;
    esac

    echo "$selected_transform"
}

show_position_menu() {
    local default_position="${1:-left}"

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Secondary Monitor Position${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}Select where to place the secondary monitor:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Left of primary (default)"
    echo -e "  ${CYAN}2)${NC} Right of primary"
    echo -e "  ${CYAN}3)${NC} Above primary"
    echo -e "  ${CYAN}4)${NC} Below primary"
    echo ""

    local default_choice=1
    case $default_position in
        left)  default_choice=1 ;;
        right) default_choice=2 ;;
        above) default_choice=3 ;;
        below) default_choice=4 ;;
    esac

    echo -ne "${BOLD}Enter your choice [1-4] (default: ${default_choice}): ${NC}"

    read -r choice
    choice=${choice:-$default_choice}
    echo ""

    local selected_position="left"
    case $choice in
        1)
            log_info "Selected: Left of primary"
            selected_position="left"
            ;;
        2)
            log_info "Selected: Right of primary"
            selected_position="right"
            ;;
        3)
            log_info "Selected: Above primary"
            selected_position="above"
            ;;
        4)
            log_info "Selected: Below primary"
            selected_position="below"
            ;;
        *)
            log_warning "Invalid choice: $choice, using default (left)"
            selected_position="left"
            ;;
    esac

    echo "$selected_position"
}

show_interactive_menu() {
    local recommended_mode
    if [[ $MONITOR_COUNT -eq 1 ]]; then
        recommended_mode="Single"
    else
        recommended_mode="Dual"
    fi

    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Display Mode Selection${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Detected: ${CYAN}${MONITOR_COUNT}${NC} monitor(s)"
    echo ""
    echo -e "${BOLD}Please select display mode:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Auto (recommended - ${recommended_mode} display)"
    echo -e "  ${CYAN}2)${NC} Single display (use ${PRIMARY_MONITOR} only)"

    if [[ $MONITOR_COUNT -gt 1 ]]; then
        echo -e "  ${CYAN}3)${NC} Dual display (use both monitors)"
    else
        echo -e "  ${YELLOW}3)${NC} Dual display ${YELLOW}(unavailable - only 1 monitor detected)${NC}"
    fi

    echo -e "  ${RED}4)${NC} Cancel"
    echo ""
    echo -ne "${BOLD}Enter your choice [1-4]: ${NC}"

    read -r choice
    echo ""

    case $choice in
        1)
            log_info "Selected: Auto mode (${recommended_mode} display)"
            MODE=""  # Auto-detect
            ;;
        2)
            log_info "Selected: Single display mode"
            MODE="single"
            ;;
        3)
            if [[ $MONITOR_COUNT -gt 1 ]]; then
                log_info "Selected: Dual display mode"
                MODE="dual"
            else
                log_error "Dual display is not available with only 1 monitor"
                log_info "Falling back to single display mode"
                MODE="single"
            fi
            ;;
        4)
            log_info "Cancelled by user"
            exit 0
            ;;
        *)
            log_error "Invalid choice: $choice"
            log_info "Falling back to auto mode (${recommended_mode} display)"
            MODE=""
            ;;
    esac
}

# Show interactive menu if not in auto mode and mode not specified
if [[ "$AUTO_MODE" == "false" ]] && [[ -z "$MODE" ]]; then
    show_interactive_menu
fi

# If MODE is still empty, use auto-detection
if [[ -z "$MODE" ]]; then
    if [[ $MONITOR_COUNT -eq 1 ]]; then
        MODE="single"
    else
        MODE="dual"
    fi
fi

# Show orientation selection menu if not in auto mode
if [[ "$AUTO_MODE" == "false" ]]; then
    # Primary monitor orientation
    PRIMARY_TRANSFORM=$(show_orientation_menu "$PRIMARY_MONITOR" 0 true)

    # Secondary monitor orientation (only for dual mode)
    if [[ "$MODE" == "dual" ]] && [[ $MONITOR_COUNT -gt 1 ]]; then
        # Determine secondary monitor
        SECONDARY_MONITOR=""
        for monitor in "${MONITOR_ARRAY[@]}"; do
            if [[ "$monitor" != "$PRIMARY_MONITOR" ]]; then
                SECONDARY_MONITOR="$monitor"
                break
            fi
        done

        # Default secondary to portrait left (270°) as user preference
        SECONDARY_TRANSFORM=$(show_orientation_menu "$SECONDARY_MONITOR" 3 false)

        # Secondary monitor position selection
        SECONDARY_POSITION=$(show_position_menu "left")
    fi
else
    # Auto mode: use defaults
    # Primary: landscape (0), Secondary: portrait left (270°) for user's setup
    if [[ "$MODE" == "dual" ]]; then
        SECONDARY_TRANSFORM=3  # Portrait left (270°)
        SECONDARY_POSITION="left"  # Default to left
    fi
fi

# =====================================================
# Generate Hyprland Configuration
# =====================================================

log_info "Generating Hyprland configuration..."

if [[ "$MODE" == "single" ]]; then
    # Single monitor
    log_info "Display Mode: Single (forced or selected)"

    # Build monitor config string with transform if needed
    PRIMARY_CONFIG="${PRIMARY_MONITOR},preferred,auto,1"
    if [[ $PRIMARY_TRANSFORM -ne 0 ]]; then
        PRIMARY_CONFIG="${PRIMARY_CONFIG},transform,${PRIMARY_TRANSFORM}"
    fi

    cat > "$HYPR_MONITORS_CONF" << EOF
# =====================================================
# Monitor Configuration (Auto-generated)
# =====================================================
# Generated by: auto-detect-monitors.sh
# Date: $(date '+%Y-%m-%d %H:%M:%S')
# Detected: $MONITOR_COUNT monitor (Single display)
# =====================================================

# Single Monitor Setup
monitor=${PRIMARY_CONFIG}

# Workspace assignment (optional - all workspaces default to single monitor)
# workspace=1,monitor:${PRIMARY_MONITOR}
# workspace=2,monitor:${PRIMARY_MONITOR}
# workspace=3,monitor:${PRIMARY_MONITOR}
# workspace=4,monitor:${PRIMARY_MONITOR}
# workspace=5,monitor:${PRIMARY_MONITOR}
# workspace=6,monitor:${PRIMARY_MONITOR}
# workspace=7,monitor:${PRIMARY_MONITOR}
# workspace=8,monitor:${PRIMARY_MONITOR}
# workspace=9,monitor:${PRIMARY_MONITOR}
# workspace=10,monitor:${PRIMARY_MONITOR}
EOF

else
    # Dual (or more) monitors
    log_info "Display Mode: Dual (forced or selected)"

    # Determine secondary monitor
    SECONDARY_MONITOR=""
    for monitor in "${MONITOR_ARRAY[@]}"; do
        if [[ "$monitor" != "$PRIMARY_MONITOR" ]]; then
            SECONDARY_MONITOR="$monitor"
            break
        fi
    done

    log_info "Secondary monitor: $SECONDARY_MONITOR"

    # Get monitor positions and dimensions
    PRIMARY_INFO=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$PRIMARY_MONITOR\")")
    SECONDARY_INFO=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name == \"$SECONDARY_MONITOR\")")

    PRIMARY_WIDTH=$(echo "$PRIMARY_INFO" | jq -r '.width')
    PRIMARY_HEIGHT=$(echo "$PRIMARY_INFO" | jq -r '.height')
    PRIMARY_REFRESH=$(echo "$PRIMARY_INFO" | jq -r '.refreshRate | floor')
    PRIMARY_X=$(echo "$PRIMARY_INFO" | jq -r '.x')
    PRIMARY_Y=$(echo "$PRIMARY_INFO" | jq -r '.y')
    # PRIMARY_TRANSFORM is already set by user selection or default (0)

    SECONDARY_WIDTH=$(echo "$SECONDARY_INFO" | jq -r '.width')
    SECONDARY_HEIGHT=$(echo "$SECONDARY_INFO" | jq -r '.height')
    SECONDARY_REFRESH=$(echo "$SECONDARY_INFO" | jq -r '.refreshRate | floor')
    # SECONDARY_TRANSFORM is already set by user selection or default (0)

    # Calculate actual display dimensions considering transform
    # Transform 1 (90°) and 3 (270°) swap width and height
    PRIMARY_DISPLAY_WIDTH=$PRIMARY_WIDTH
    PRIMARY_DISPLAY_HEIGHT=$PRIMARY_HEIGHT
    if [[ $PRIMARY_TRANSFORM -eq 1 ]] || [[ $PRIMARY_TRANSFORM -eq 3 ]]; then
        PRIMARY_DISPLAY_WIDTH=$PRIMARY_HEIGHT
        PRIMARY_DISPLAY_HEIGHT=$PRIMARY_WIDTH
    fi

    SECONDARY_DISPLAY_WIDTH=$SECONDARY_WIDTH
    SECONDARY_DISPLAY_HEIGHT=$SECONDARY_HEIGHT
    if [[ $SECONDARY_TRANSFORM -eq 1 ]] || [[ $SECONDARY_TRANSFORM -eq 3 ]]; then
        SECONDARY_DISPLAY_WIDTH=$SECONDARY_HEIGHT
        SECONDARY_DISPLAY_HEIGHT=$SECONDARY_WIDTH
    fi

    # Calculate monitor positions based on selected placement
    PRIMARY_X=0
    PRIMARY_Y=0
    SECONDARY_X=0
    SECONDARY_Y=0

    case $SECONDARY_POSITION in
        left)
            # Secondary on left, primary on right
            SECONDARY_X=0
            SECONDARY_Y=0
            PRIMARY_X=$SECONDARY_DISPLAY_WIDTH
            PRIMARY_Y=0
            ;;
        right)
            # Primary on left, secondary on right
            PRIMARY_X=0
            PRIMARY_Y=0
            SECONDARY_X=$PRIMARY_DISPLAY_WIDTH
            SECONDARY_Y=0
            ;;
        above)
            # Secondary above, primary below
            SECONDARY_X=0
            SECONDARY_Y=0
            PRIMARY_X=0
            PRIMARY_Y=$SECONDARY_DISPLAY_HEIGHT
            ;;
        below)
            # Primary above, secondary below
            PRIMARY_X=0
            PRIMARY_Y=0
            SECONDARY_X=0
            SECONDARY_Y=$PRIMARY_DISPLAY_HEIGHT
            ;;
    esac

    log_info "Secondary position: $SECONDARY_POSITION"

    # Build monitor config strings
    PRIMARY_CONFIG="${PRIMARY_MONITOR},${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}@${PRIMARY_REFRESH},${PRIMARY_X}x${PRIMARY_Y},1"
    SECONDARY_CONFIG="${SECONDARY_MONITOR},${SECONDARY_WIDTH}x${SECONDARY_HEIGHT}@${SECONDARY_REFRESH},${SECONDARY_X}x${SECONDARY_Y},1"

    # Add transform if needed
    if [[ $PRIMARY_TRANSFORM -ne 0 ]]; then
        PRIMARY_CONFIG="${PRIMARY_CONFIG},transform,${PRIMARY_TRANSFORM}"
    fi
    if [[ $SECONDARY_TRANSFORM -ne 0 ]]; then
        SECONDARY_CONFIG="${SECONDARY_CONFIG},transform,${SECONDARY_TRANSFORM}"
    fi

    cat > "$HYPR_MONITORS_CONF" << EOF
# =====================================================
# Monitor Configuration (Auto-generated)
# =====================================================
# Generated by: auto-detect-monitors.sh
# Date: $(date '+%Y-%m-%d %H:%M:%S')
# Detected: $MONITOR_COUNT monitors (Dual display)
# =====================================================

# Primary Monitor (Main)
monitor=${PRIMARY_CONFIG}

# Secondary Monitor (Sub)
monitor=${SECONDARY_CONFIG}

# =====================================================
# Workspace Assignment
# =====================================================

# Primary monitor: Workspaces 1-5
workspace=1,monitor:${PRIMARY_MONITOR}
workspace=2,monitor:${PRIMARY_MONITOR}
workspace=3,monitor:${PRIMARY_MONITOR}
workspace=4,monitor:${PRIMARY_MONITOR}
workspace=5,monitor:${PRIMARY_MONITOR}

# Secondary monitor: Workspaces 6-10
workspace=6,monitor:${SECONDARY_MONITOR}
workspace=7,monitor:${SECONDARY_MONITOR}
workspace=8,monitor:${SECONDARY_MONITOR}
workspace=9,monitor:${SECONDARY_MONITOR}
workspace=10,monitor:${SECONDARY_MONITOR}
EOF

fi

log_success "Generated: $HYPR_MONITORS_CONF"

# =====================================================
# Generate Waybar Configuration
# =====================================================

log_info "Generating Waybar configuration..."

if [[ "$MODE" == "single" ]]; then
    # Single monitor
    cat > "$WAYBAR_MONITORS_ENV" << EOF
# =====================================================
# Waybar Monitor Configuration (Auto-generated)
# =====================================================
# Generated by: auto-detect-monitors.sh
# Date: $(date '+%Y-%m-%d %H:%M:%S')
# Detected: $MONITOR_COUNT monitor (Single display)
# =====================================================

# Main monitor (Workspaces 1-10)
MONITOR_MAIN=${PRIMARY_MONITOR}

# Sub monitor (leave empty for single display)
MONITOR_SUB=""
EOF

else
    # Dual monitors
    cat > "$WAYBAR_MONITORS_ENV" << EOF
# =====================================================
# Waybar Monitor Configuration (Auto-generated)
# =====================================================
# Generated by: auto-detect-monitors.sh
# Date: $(date '+%Y-%m-%d %H:%M:%S')
# Detected: $MONITOR_COUNT monitors (Dual display)
# =====================================================

# Main monitor (Workspaces 1-5)
MONITOR_MAIN=${PRIMARY_MONITOR}

# Sub monitor (Workspaces 6-10)
MONITOR_SUB=${SECONDARY_MONITOR}
EOF

fi

log_success "Generated: $WAYBAR_MONITORS_ENV"

# =====================================================
# Build Waybar Config
# =====================================================

if [[ -f "${WAYBAR_DIR}/build-config.sh" ]]; then
    log_info "Building Waybar configuration..."
    cd "$WAYBAR_DIR"
    ./build-config.sh
else
    log_warning "Waybar build script not found, skipping"
fi

# =====================================================
# Summary
# =====================================================

echo ""
log_success "Monitor configuration completed!"
echo ""
log_info "Summary:"
log_info "  Display Mode: $([ "$MODE" == "single" ] && echo 'Single' || echo 'Dual')"
log_info "  Monitor Count: $MONITOR_COUNT"
log_info "  Primary: $PRIMARY_MONITOR"
if [[ "$MODE" == "dual" ]] && [[ -n "${SECONDARY_MONITOR:-}" ]]; then
    log_info "  Secondary: $SECONDARY_MONITOR"
fi
echo ""
log_info "Generated files:"
log_info "  - $HYPR_MONITORS_CONF"
log_info "  - $WAYBAR_MONITORS_ENV"
if [[ -f "${WAYBAR_DIR}/config.jsonc" ]]; then
    log_info "  - ${WAYBAR_DIR}/config.jsonc"
fi
log_info "  - $HYPRPAPER_CONF"
echo ""
log_info "Next steps:"
log_info "  1. Reload Hyprland: hyprctl reload"
echo ""
