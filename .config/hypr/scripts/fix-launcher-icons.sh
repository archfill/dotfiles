#!/usr/bin/env bash
set -euo pipefail

apps_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

set_icon() {
  local file="$apps_dir/$1"
  local icon="$2"

  [[ -f "$file" ]] || return 0
  sed -i "0,/^Icon=.*/s//Icon=$icon/" "$file"
}

# Waydroid may leave desktop entries pointing at removed PNG files under
# ~/.local/share/waydroid/data/icons. Use stable themed icons instead so
# launchers that rely on icon lookup do not show broken placeholders.
set_icon "waydroid.com.google.android.contacts.desktop" "org.gnome.Contacts"
set_icon "waydroid.com.google.android.apps.messaging.desktop" "org.gnome.Settings-mobile-network-symbolic"
set_icon "waydroid.com.android.vending.desktop" "org.gnome.Settings-applications-symbolic"
set_icon "waydroid.com.android.settings.desktop" "org.gnome.Settings"
set_icon "waydroid.com.android.calculator2.desktop" "org.gnome.Calculator"
set_icon "waydroid.com.android.deskclock.desktop" "org.gnome.clocks"
set_icon "waydroid.com.android.documentsui.desktop" "folder"
set_icon "waydroid.com.android.gallery3d.desktop" "image-x-generic"
set_icon "waydroid.org.lineageos.aperture.desktop" "org.gnome.Settings-camera-access-symbolic"
set_icon "waydroid.org.lineageos.etar.desktop" "org.gnome.Calendar"
set_icon "waydroid.org.lineageos.eleven.desktop" "org.gnome.Music"
set_icon "waydroid.org.lineageos.jelly.desktop" "applications-internet"
set_icon "waydroid.org.lineageos.recorder.desktop" "media-record"

update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
