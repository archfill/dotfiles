#!/bin/bash
# Rofi Power Menu for Hyprland

options="  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" \
    -theme-str 'window { width: 200px; }' \
    -theme-str 'listview { lines: 5; }')

case "$chosen" in
    *Lock)
        hyprlock
        ;;
    *Logout)
        hyprctl dispatch exit
        ;;
    *Suspend)
        systemctl suspend
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
esac
