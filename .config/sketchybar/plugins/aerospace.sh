#!/usr/bin/env bash

# Aerospace Workspace Plugin for SketchyBar
# Handles workspace indicator highlighting based on current focus

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
        background.color=0xffffffff \
        icon.color=0xff000000
elif has_windows "$WORKSPACE_ID"; then
    # Has windows but not focused - show with dim background
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color=0x40ffffff \
        icon.color=0xffffffff
else
    # Empty workspace - hide background
    sketchybar --set "$NAME" \
        background.drawing=off \
        icon.color=0x80ffffff
fi