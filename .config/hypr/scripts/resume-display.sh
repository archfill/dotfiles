#!/usr/bin/env bash
set -euo pipefail

# NVIDIA/DPMS can need a short grace period after resume before Hyprland accepts
# output commands reliably.
for delay in 1 2 4; do
  sleep "$delay"
  hyprctl dispatch dpms on >/dev/null 2>&1 || true
done
