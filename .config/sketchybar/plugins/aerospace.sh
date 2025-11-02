#!/usr/bin/env bash

# Aerospace Workspace Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
COLOR_ACTIVE_BG="0xcc89b4fa"     # Blue (active workspace)
COLOR_ACTIVE_ICON="0xff1e1e2e"   # Base (dark icon on blue)
COLOR_OCCUPIED_BG="0xcc313244"   # Surface0 (has windows)
COLOR_OCCUPIED_ICON="0xffcdd6f4" # Text
COLOR_EMPTY_ICON="0xff6c7086"    # Overlay0 (empty workspace)

WORKSPACE_ID="$1"
# Set NAME environment variable for sketchybar commands
export NAME="space.$WORKSPACE_ID"

# Check if this workspace has any windows
has_windows() {
    local workspace="$1"
    aerospace list-windows --workspace "$workspace" 2>/dev/null | grep -q "."
}

# Check if this is the currently focused workspace
is_focused() {
    local workspace="$1"
    local focused_workspace=$(aerospace list-workspaces --focused)
    [[ "$workspace" == "$focused_workspace" ]]
}

# Determine the display state
if is_focused "$WORKSPACE_ID"; then
    # Focused workspace - show with active background
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color="$COLOR_ACTIVE_BG" \
        icon.color="$COLOR_ACTIVE_ICON"
elif has_windows "$WORKSPACE_ID"; then
    # Has windows but not focused - show with dim background
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color="$COLOR_OCCUPIED_BG" \
        icon.color="$COLOR_OCCUPIED_ICON"
else
    # Empty workspace - hide background
    sketchybar --set "$NAME" \
        background.drawing=off \
        icon.color="$COLOR_EMPTY_ICON"
fi