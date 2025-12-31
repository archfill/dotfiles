#!/bin/bash
# Wallpaper Picker for Hyprland
# Grid view with image thumbnails using rofi

WALLPAPER_DIR="$HOME/Nextcloud/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
CURRENT_WALLPAPER="$HOME/.config/hypr/current-wallpaper"
THUMB_SIZE=200

# Create cache directory
mkdir -p "$CACHE_DIR"

# Check dependencies
check_deps() {
    local missing=()
    command -v awww >/dev/null || missing+=("awww")
    command -v rofi >/dev/null || missing+=("rofi")
    command -v magick >/dev/null || missing+=("imagemagick")

    if [[ ${#missing[@]} -gt 0 ]]; then
        notify-send "Wallpaper Picker" "Missing: ${missing[*]}" -u critical
        exit 1
    fi
}

# Initialize awww if not running
init_awww() {
    if ! pgrep -x awww-daemon >/dev/null; then
        awww-daemon &
        sleep 0.5
    fi
}

# Generate thumbnail for a single image
generate_thumbnail() {
    local img="$1"
    local name=$(basename "$img")
    local thumb="$CACHE_DIR/${name%.*}.png"

    if [[ ! -f "$thumb" ]] || [[ "$img" -nt "$thumb" ]]; then
        magick "$img" -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
            -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
            "$thumb" 2>/dev/null
    fi
    echo "$thumb"
}

# Generate all thumbnails (parallel)
generate_all_thumbnails() {
    local count=0
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r img; do
        generate_thumbnail "$img" &
        ((count++))
        # Limit parallel jobs
        if ((count % 10 == 0)); then
            wait
        fi
    done
    wait
}

# List wallpapers with icons for rofi
list_wallpapers_with_icons() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | while read -r img; do
        local name=$(basename "$img")
        local thumb="$CACHE_DIR/${name%.*}.png"

        # Generate thumbnail if needed
        if [[ ! -f "$thumb" ]]; then
            generate_thumbnail "$img" >/dev/null
        fi

        # Output: filename\0icon\x1fthumbnail_path
        printf '%s\0icon\x1f%s\n' "$name" "$thumb"
    done
}

# Apply wallpaper and regenerate theme
apply_wallpaper() {
    local wallpaper="$1"
    local full_path="$WALLPAPER_DIR/$wallpaper"

    if [[ ! -f "$full_path" ]]; then
        notify-send "Wallpaper Picker" "File not found: $wallpaper" -u critical
        exit 1
    fi

    # Save current wallpaper path
    echo "$full_path" > "$CURRENT_WALLPAPER"

    # Apply wallpaper with awww
    awww img "$full_path"

    notify-send "Wallpaper" "Applied: $wallpaper" -t 2000

    # Regenerate colors with matugen
    if command -v matugen >/dev/null; then
        matugen image "$full_path" 2>/dev/null

        # Reload applications
        pkill waybar
        ~/.config/hypr/scripts/waybar-launch.sh &
        swaync-client -rs &

        notify-send "Theme Updated" "Colors regenerated" -t 2000
    fi
}

# Select wallpaper with rofi grid view
select_wallpaper() {
    # Get monitor info for sizing
    local monitor_width=$(hyprctl monitors -j | jq -r '.[0].width')
    local columns=5
    local icon_size=150

    if [[ "$monitor_width" -lt 2000 ]]; then
        columns=4
        icon_size=120
    fi

    local selected
    selected=$(list_wallpapers_with_icons | rofi -dmenu \
        -p "󰸉 Wallpaper" \
        -i \
        -show-icons \
        -theme-str "
            window { width: 80%; }
            listview {
                columns: $columns;
                lines: 3;
                spacing: 10px;
                fixed-columns: true;
            }
            element {
                orientation: vertical;
                padding: 10px;
            }
            element-icon {
                size: ${icon_size}px;
            }
            element-text {
                horizontal-align: 0.5;
                font: \"JetBrainsMono Nerd Font Propo 9\";
            }
        " \
        -theme ~/.config/rofi/wallpaper.rasi)

    if [[ -n "$selected" ]]; then
        apply_wallpaper "$selected"
    fi
}

# Random wallpaper
random_wallpaper() {
    local random_file
    random_file=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
    if [[ -f "$random_file" ]]; then
        apply_wallpaper "$(basename "$random_file")"
    fi
}

# Regenerate all thumbnails
regen_thumbnails() {
    rm -rf "$CACHE_DIR"
    mkdir -p "$CACHE_DIR"
    echo "Generating thumbnails..."
    generate_all_thumbnails
    echo "Done! Generated thumbnails for $(ls "$CACHE_DIR" | wc -l) images"
}

# Main
check_deps
init_awww

case "${1:-}" in
    --random|-r)
        random_wallpaper
        ;;
    --apply|-a)
        if [[ -n "$2" ]]; then
            apply_wallpaper "$2"
        else
            echo "Usage: $0 --apply <wallpaper-name>"
            exit 1
        fi
        ;;
    --current|-c)
        [[ -f "$CURRENT_WALLPAPER" ]] && cat "$CURRENT_WALLPAPER"
        ;;
    --regen|-g)
        regen_thumbnails
        ;;
    *)
        select_wallpaper
        ;;
esac
