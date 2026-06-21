#!/usr/bin/env bash
# Rofi power modi script

if [ -z "$1" ]; then
    echo -e "󰌾  Lock"
    echo -e "󰍃  Logout"
    echo -e "󰒲  Suspend"
    echo -e "󰜉  Reboot"
    echo -e "󰐥  Shutdown"
else
    case "$1" in
        *Lock) hyprlock ;;
        *Logout) hyprctl dispatch exit ;;
        *Suspend) systemctl suspend ;;
        *Reboot) systemctl reboot ;;
        *Shutdown) systemctl poweroff ;;
    esac
fi
