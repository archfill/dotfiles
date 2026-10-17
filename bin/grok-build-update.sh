#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GROK_BUILD_NIX="$DOTFILES_DIR/nix/pkgs/grok-build/default.nix"

# Nix system -> platform suffix in x.ai's download URL.
platform_for_system() {
  case "$1" in
    aarch64-darwin) echo "macos-aarch64" ;;
    x86_64-linux) echo "linux-x86_64" ;;
    aarch64-linux) echo "linux-aarch64" ;;
    *) return 1 ;;
  esac
}

usage() {
  cat <<'USAGE'
Usage:
  bin/grok-build-update.sh [VERSION]
  VERSION=1.0.52 bin/grok-build-update.sh

If VERSION is omitted, the stable-channel version pointer
(https://x.ai/cli/stable) is used. The Nix package owns updates, so the CLI
should not update itself in place.

Only the entry (version and hash) for the current machine's Nix system is
updated; entries for other systems are left untouched and refreshed by running
this script on those hosts.
USAGE
}

latest_version() {
  curl -fsSL "https://x.ai/cli/stable" | tr -d '[:space:]'
}

prefetch_hash() {
  local version="$1"
  local platform="$2"

  nix store prefetch-file --hash-type sha256 --json \
    "https://x.ai/cli/grok-${version}-${platform}" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_grok_build_nix() {
  local system="$1"
  local version="$2"
  local hash="$3"

  python3 - "$GROK_BUILD_NIX" "$system" "$version" "$hash" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
system, version, hash_value = sys.argv[2:5]
text = path.read_text()

# Rewrite only this system's entry inside the `sources` attrset.
pattern = rf'("{re.escape(system)}" = \{{\s*version = )"[^"]+"(;\s*hash = )"[^"]+"(;)'
text, count = re.subn(
    pattern, rf'\g<1>"{version}"\g<2>"{hash_value}"\g<3>', text, count=1
)
if count != 1:
    raise SystemExit(f"missing sources entry for {system}")

path.write_text(text)
PY
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  if [[ "$#" -gt 1 ]]; then
    usage >&2
    exit 2
  fi

  local version="${1:-${VERSION:-}}"
  if [[ -z "$version" ]]; then
    echo "==> Resolving stable Grok Build version from x.ai/cli/stable"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9._]+)?$ ]]; then
    echo "Invalid Grok Build version: $version" >&2
    exit 1
  fi

  local system platform
  system="$(nix eval --impure --raw --expr builtins.currentSystem)"
  if ! platform="$(platform_for_system "$system")"; then
    echo "Unsupported Nix system: $system" >&2
    exit 1
  fi
  if ! grep -q "^    \"$system\" = {" "$GROK_BUILD_NIX"; then
    echo "No sources entry for $system in $GROK_BUILD_NIX" >&2
    exit 1
  fi

  # 未変更なら prefetch をスキップする (自 system のエントリの version と比較)。
  local current_version
  current_version="$(
    sed -n "/^    \"$system\" = {/,/};/s/^      version = \"\(.*\)\";\$/\1/p" "$GROK_BUILD_NIX" | head -1
  )"
  if [[ "$version" == "$current_version" ]]; then
    echo "==> $system is already at Grok Build version $version; nothing to do"
    exit 0
  fi

  echo "==> Grok Build version: $version"
  echo "==> Prefetching $system"
  local hash
  hash="$(prefetch_hash "$version" "$platform")"

  update_grok_build_nix "$system" "$version" "$hash"
  echo "==> Updated $system entry in nix/pkgs/grok-build/default.nix"
}

main "$@"
