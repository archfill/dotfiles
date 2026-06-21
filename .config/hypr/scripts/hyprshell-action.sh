#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  open-overview)
    exec hyprshell socat '"OpenOverview"'
    ;;
  switch-next)
    exec hyprshell socat '{"OpenSwitch":{"reverse":false}}'
    ;;
  switch-prev)
    exec hyprshell socat '{"OpenSwitch":{"reverse":true}}'
    ;;
  close-switch)
    exec hyprshell socat '{"CloseSwitch":{"switch":true}}'
    ;;
  *)
    printf 'usage: %s {open-overview|switch-next|switch-prev|close-switch}\n' "$0" >&2
    exit 2
    ;;
esac
