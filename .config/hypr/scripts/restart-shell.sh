#!/usr/bin/env bash
set -u

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dms"
log_file="$log_dir/start.log"
mkdir -p "$log_dir"

{
  printf '\n[%s] restarting DMS\n' "$(date --iso-8601=seconds)"
  export PATH="/run/current-system/sw/bin:$PATH"

  for _ in {1..20}; do
    if hyprctl monitors >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done

  if command -v dms >/dev/null 2>&1; then
    systemctl --user restart dms.service
    exit 0
  fi

  echo "dms is not available" >&2
  exit 1
} >>"$log_file" 2>&1
