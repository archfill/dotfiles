#!/usr/bin/env bash
# Waybar disk module: shows / and /home usage

root_used=$(df -h / | awk 'NR==2 {print $5}')
home_used=$(df -h /home | awk 'NR==2 {print $5}')

echo "/ ${root_used} ~ ${home_used}"
