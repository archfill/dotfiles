#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CURSOR_AGENT_NIX="$DOTFILES_DIR/nix/pkgs/cursor-agent/default.nix"

# Nix system -> "os|arch" for Cursor's download URL.
platform_for_system() {
  case "$1" in
    aarch64-darwin) echo "darwin|arm64" ;;
    x86_64-darwin) echo "darwin|x64" ;;
    x86_64-linux) echo "linux|x64" ;;
    aarch64-linux) echo "linux|arm64" ;;
    *) return 1 ;;
  esac
}

usage() {
  cat <<'USAGE'
Usage:
  bin/cursor-agent-update.sh [VERSION]
  VERSION=2026.08.11-e8db854 bin/cursor-agent-update.sh

If VERSION is omitted, the version embedded in Cursor's official installer is
used. The Nix package owns updates, so the CLI should use its static channel.

Only the entry (version and hash) for the current machine's Nix system is
updated; entries for other systems are left untouched and refreshed by running
this script on those hosts.
USAGE
}

latest_version() {
  curl -fsSL "https://cursor.com/install" |
    python3 -c '
import re
import sys

installer = sys.stdin.read()
match = re.search(
    r"https://downloads\.cursor\.com/lab/([^/]+)/\$\{OS\}/\$\{ARCH\}/agent-cli-package\.tar\.gz",
    installer,
)
if match is None:
    print("No Cursor Agent version found in official installer", file=sys.stderr)
    sys.exit(1)

print(match.group(1))
'
}

prefetch_hash() {
  local version="$1"
  local os="$2"
  local arch="$3"

  nix store prefetch-file --hash-type sha256 --json \
    "https://downloads.cursor.com/lab/${version}/${os}/${arch}/agent-cli-package.tar.gz" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_cursor_agent_nix() {
  local system="$1"
  local version="$2"
  local hash="$3"

  python3 - "$CURSOR_AGENT_NIX" "$system" "$version" "$hash" <<'PY'
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
    raise SystemExit(f"Missing sources entry for {system}")

path.write_text(text)
PY
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  local version="${1:-${VERSION:-}}"
  if [[ -z "$version" ]]; then
    echo "==> Resolving latest Cursor Agent version from official installer"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9a-f]+$ ]]; then
    echo "Invalid Cursor Agent version: $version" >&2
    exit 1
  fi

  echo "==> Cursor Agent version: $version"

  local system platform os arch
  system="$(nix eval --impure --raw --expr builtins.currentSystem)"
  if ! platform="$(platform_for_system "$system")"; then
    echo "Unsupported Nix system: $system" >&2
    exit 1
  fi
  IFS='|' read -r os arch <<<"$platform"
  if ! grep -q "^    \"$system\" = {" "$CURSOR_AGENT_NIX"; then
    echo "No sources entry for $system in $CURSOR_AGENT_NIX" >&2
    exit 1
  fi

  # 未変更なら prefetch をスキップする (自 system のエントリの version と比較)。
  local current_version
  current_version="$(
    sed -n "/^    \"$system\" = {/,/};/s/^      version = \"\(.*\)\";\$/\1/p" "$CURSOR_AGENT_NIX" | head -1
  )"
  if [[ "$version" == "$current_version" ]]; then
    echo "==> $system is already at Cursor Agent version $version; nothing to do"
    exit 0
  fi

  echo "==> Prefetching $system"
  local hash
  hash="$(prefetch_hash "$version" "$os" "$arch")"

  update_cursor_agent_nix "$system" "$version" "$hash"
  echo "==> Updated $system entry in nix/pkgs/cursor-agent/default.nix"
}

main "$@"
