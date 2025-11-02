#!/bin/sh

# Space Plugin for SketchyBar
# Theme: Catppuccin Mocha
# Note: Actual color styling is handled by aerospace.sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

sketchybar --set "$NAME" background.drawing="$SELECTED"
