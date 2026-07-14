#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORCA_NIX="$DOTFILES_DIR/nix/pkgs/orca/default.nix"

usage() {
  cat <<'USAGE'
Usage:
  bin/orca-update.sh [VERSION]
  VERSION=1.4.139 bin/orca-update.sh

If VERSION is omitted, the latest GitHub release is used.
USAGE
}

latest_version() {
  curl -fsSL "https://api.github.com/repos/stablyai/orca/releases/latest" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].removeprefix("v"))'
}

prefetch_hash() {
  local version="$1"

  nix store prefetch-file --hash-type sha256 --json \
    "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_orca_nix() {
  local version="$1"
  local hash="$2"

  python3 - "$ORCA_NIX" "$version" "$hash" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
hash_value = sys.argv[3]
text = path.read_text()

text, version_count = re.subn(
    r'version = "[^"]+";', f'version = "{version}";', text, count=1
)
text, hash_count = re.subn(
    r'hash = "sha256-[^"]+";', f'hash = "{hash_value}";', text, count=1
)

if version_count != 1 or hash_count != 1:
    raise SystemExit("failed to update exactly one Orca version and hash")

path.write_text(text)
PY
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

version="${1:-${VERSION:-}}"
if [[ -z "$version" ]]; then
  version="$(latest_version)"
fi
version="${version#v}"

echo "==> Updating Orca to v${version}"
hash="$(prefetch_hash "$version")"
update_orca_nix "$version" "$hash"
echo "==> Updated $ORCA_NIX"
