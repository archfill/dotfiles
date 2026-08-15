#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PI_NIX="$DOTFILES_DIR/nix/pkgs/pi/default.nix"

platforms=(
  "aarch64-darwin|darwin|arm64"
  "x86_64-darwin|darwin|x64"
  "x86_64-linux|linux|x64"
  "aarch64-linux|linux|arm64"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/pi-update.sh [VERSION]
  VERSION=0.84.2 bin/pi-update.sh

If VERSION is omitted, the latest non-prerelease GitHub release tag (v*) is used.
USAGE
}

latest_version() {
  curl -fsSL "https://api.github.com/repos/earendil-works/pi/releases?per_page=20" |
    python3 -c '
import json
import re
import sys

for release in json.load(sys.stdin):
    if release.get("prerelease"):
        continue
    tag = release.get("tag_name", "")
    match = re.fullmatch(r"v(.+)", tag)
    if match:
        print(match.group(1))
        sys.exit(0)

print("No v* Pi release found", file=sys.stderr)
sys.exit(1)
'
}

prefetch_hash() {
  local version="$1"
  local os="$2"
  local arch="$3"

  nix store prefetch-file --hash-type sha256 --json \
    "https://github.com/earendil-works/pi/releases/download/v${version}/pi-${os}-${arch}.tar.gz" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_pi_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$PI_NIX" "$version" "$hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
hashes = json.loads(sys.argv[3])
text = path.read_text()

text = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)

for system, hash_value in hashes.items():
    pattern = rf'("{re.escape(system)}"\s*=\s*)"[^"]+";'
    replacement = rf'\1"{hash_value}";'
    text, count = re.subn(pattern, replacement, text, count=1)
    if count != 1:
        raise SystemExit(f"Missing hash entry for {system}")

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
    echo "==> Fetching latest Pi release"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-].+)?$ ]]; then
    echo "Invalid Pi version: $version" >&2
    exit 1
  fi

  echo "==> Updating Pi to v${version}"

  local hashes_json="{}"
  local entry system os arch hash
  for entry in "${platforms[@]}"; do
    IFS='|' read -r system os arch <<<"$entry"
    echo "==> Prefetching $system"
    hash="$(prefetch_hash "$version" "$os" "$arch")"
    hashes_json="$(
      python3 -c \
        'import json,sys; data=json.loads(sys.argv[1]); data[sys.argv[2]]=sys.argv[3]; print(json.dumps(data))' \
        "$hashes_json" "$system" "$hash"
    )"
  done

  update_pi_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/pi/default.nix"
}

main "$@"
