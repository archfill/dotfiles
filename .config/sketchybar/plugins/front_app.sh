#!/bin/sh

# Front App Plugin for SketchyBar
# Theme: Catppuccin Mocha

# Catppuccin Mocha colors
TEXT_COLOR="0xffcdd6f4"   # Text

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" \
      label="$INFO" \
      label.color="$TEXT_COLOR"
fi
