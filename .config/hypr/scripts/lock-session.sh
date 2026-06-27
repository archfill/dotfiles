#!/usr/bin/env bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
lock_dir="$runtime_dir/hypr-lock-fcitx-watch.lock"

restart_fcitx() {
  command -v fcitx5 >/dev/null 2>&1 || return 0

  pkill -u "$USER" -x fcitx5 >/dev/null 2>&1 || true
  sleep 0.3
  fcitx5 -d >/dev/null 2>&1 || true
}

watch_unlock_once() {
  if ! mkdir "$lock_dir" 2>/dev/null; then
    return 0
  fi

  (
    trap 'rmdir "$lock_dir"' EXIT

    locked_seen=false
    for _ in $(seq 1 50); do
      if [ "$(caelestia shell lock isLocked 2>/dev/null || true)" = "true" ]; then
        locked_seen=true
        break
      fi
      sleep 0.1
    done

    [ "$locked_seen" = "true" ] || exit 0

    while [ "$(caelestia shell lock isLocked 2>/dev/null || true)" = "true" ]; do
      sleep 1
    done

    sleep 0.5
    restart_fcitx
  ) &
}

watch_unlock_once
caelestia shell lock lock
