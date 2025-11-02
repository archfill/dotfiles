#!/bin/sh

# Clock Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
ICON_COLOR="0xffcdd6f4"   # Text
TEXT_COLOR="0xffcdd6f4"   # Text

sketchybar --set "$NAME" \
    label="$(date '+%m/%d %H:%M')" \
    icon.color="$ICON_COLOR" \
    label.color="$TEXT_COLOR"

