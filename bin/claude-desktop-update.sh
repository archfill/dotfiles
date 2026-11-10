#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DESKTOP_NIX="$DOTFILES_DIR/nix/pkgs/claude-desktop/default.nix"

BASE_URL="https://downloads.claude.ai/claude-desktop/apt/stable"

usage() {
  cat <<'USAGE'
Usage:
  bin/claude-desktop-update.sh [--force]

Reads the official apt repository index (Packages) for amd64 and arm64,
picks the newest version of each, and updates the version, URLs and hashes
in nix/pkgs/claude-desktop/default.nix. The index already carries SHA256
sums, so no .deb is downloaded.

When the pinned version is already the newest, nothing is changed.
--force rewrites the file even when the version is unchanged.
USAGE
}

pinned_version() {
  sed -n 's/^[[:space:]]*version = "\([^"]*\)";.*/\1/p' "$CLAUDE_DESKTOP_NIX" | head -n 1
}

# Print "<version> <filename> <sha256-hex>" for the newest package of an arch.
latest_entry() {
  local arch="$1"
  curl -fsSL "$BASE_URL/dists/stable/main/binary-$arch/Packages" | python3 -c '
import re
import sys

def vkey(v):
    return [int(p) if p.isdigit() else p for p in re.split(r"[.\-+~:]", v)]

best = None
for block in sys.stdin.read().split("\n\n"):
    fields = dict(
        line.split(": ", 1) for line in block.splitlines() if ": " in line and not line.startswith(" ")
    )
    if fields.get("Package") != "claude-desktop":
        continue
    try:
        entry = (fields["Version"], fields["Filename"], fields["SHA256"])
    except KeyError:
        continue
    if best is None or vkey(entry[0]) > vkey(best[0]):
        best = entry
if best is None:
    raise SystemExit("claude-desktop not found in Packages index")
print(*best)
'
}

to_sri() {
  nix hash convert --hash-algo sha256 --to sri "$1"
}

update_nix() {
  local version="$1" x86_url="$2" x86_hash="$3" arm_url="$4" arm_hash="$5"

  python3 - "$CLAUDE_DESKTOP_NIX" "$version" "$x86_url" "$x86_hash" "$arm_url" "$arm_hash" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version, x86_url, x86_hash, arm_url, arm_hash = sys.argv[2:]
text = path.read_text()

text, count = re.subn(
    r'(^\s*version = ")[^"]+(";\s*$)',
    rf'\g<1>{version}\g<2>',
    text,
    count=1,
    flags=re.MULTILINE,
)
if count != 1:
    raise SystemExit("Claude Desktop version declaration not found")

for system, url, hash_value in (
    ("x86_64-linux", x86_url, x86_hash),
    ("aarch64-linux", arm_url, arm_hash),
):
    pattern = (
        rf'({re.escape(system)}\s*=\s*\{{\s*url\s*=\s*)"[^"]+"(;\s*hash\s*=\s*)"[^"]+";'
    )
    replacement = rf'\g<1>"{url}"\g<2>"{hash_value}";'
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.DOTALL)
    if count != 1:
        raise SystemExit(f"url/hash declaration not found for {system}")

path.write_text(text)
PY
}

main() {
  local force=0
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  if [[ "${1:-}" == "--force" ]]; then
    force=1
    shift
  fi
  if [[ $# -ne 0 ]]; then
    echo "Unexpected argument: $1" >&2
    usage >&2
    exit 2
  fi

  echo "==> Reading official Claude Desktop apt index"
  local x86_version x86_file x86_sha arm_version arm_file arm_sha
  read -r x86_version x86_file x86_sha <<<"$(latest_entry amd64)"
  read -r arm_version arm_file arm_sha <<<"$(latest_entry arm64)"

  if [[ "$x86_version" != "$arm_version" ]]; then
    echo "Architecture versions differ: amd64=$x86_version, arm64=$arm_version" >&2
    exit 1
  fi
  if [[ ! "$x86_version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
    echo "Unexpected Claude Desktop version: $x86_version" >&2
    exit 1
  fi

  local pinned
  pinned="$(pinned_version 2>/dev/null || true)"
  if [[ "$force" -ne 1 && "$pinned" == "$x86_version" ]]; then
    echo "==> Claude Desktop $pinned is already up to date"
    echo "==> Run with --force to rewrite anyway"
    exit 0
  fi
  echo "==> Claude Desktop version: ${pinned:-unknown} -> $x86_version"

  update_nix "$x86_version" \
    "$BASE_URL/$x86_file" "$(to_sri "$x86_sha")" \
    "$BASE_URL/$arm_file" "$(to_sri "$arm_sha")"
  echo "==> Updated nix/pkgs/claude-desktop/default.nix"
  echo "==> Run 'make nix-rebuild' to install the updated app"
}

main "$@"
