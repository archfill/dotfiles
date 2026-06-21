#!/usr/bin/env bash
set -euo pipefail

# Manual sleep actions should lock before entering suspend so resume always lands
# on an authentication screen.
caelestia shell lock lock >/dev/null 2>&1 || true

sleep 1
systemctl suspend
