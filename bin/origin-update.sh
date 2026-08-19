#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORIGIN_NIX="$DOTFILES_DIR/nix/pkgs/origin/default.nix"

platforms=(
  "aarch64-darwin|darwin-arm64"
  "x86_64-darwin|darwin-x64"
  "x86_64-linux|linux-x64"
  "aarch64-linux|linux-arm64"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/origin-update.sh [VERSION]
  VERSION=2026.08.15-22-58-04-922a05a bin/origin-update.sh

If VERSION is omitted, the stable-channel version embedded in Cursor's
official installer is used. The Nix package owns updates, so the CLI
should not run `origin update` itself.
USAGE
}

latest_version() {
  curl -fsSL "https://downloads.cursor.com/origin/install.sh" |
    python3 -c '
import re
import sys

installer = sys.stdin.read()
match = re.search(r"stable\)\s*\n\s*version=\"([^\"]+)\"", installer)
if match is None:
    print("No stable Origin version found in official installer", file=sys.stderr)
    sys.exit(1)

print(match.group(1))
'
}

prefetch_hash() {
  local version="$1"
  local platform="$2"

  nix store prefetch-file --hash-type sha256 --json \
    "https://downloads.cursor.com/co/${version}/${platform}/co.tar.gz" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_origin_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$ORIGIN_NIX" "$version" "$hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
hashes = json.loads(sys.argv[3])
text = path.read_text()

text = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)

# Scope the rewrite to the hashes block: platformMap also maps system
# names to "..." strings, so a bare first-match replace would clobber it.
block_pattern = r'(?P<prefix>\bhashes\s*=\s*\{)(?P<body>.*?)(?P<suffix>\n\s*\};)'
match = re.search(block_pattern, text, flags=re.DOTALL)
if match is None:
    raise SystemExit("Missing hashes block")

body = match.group("body")
for system, hash_value in hashes.items():
    pattern = rf'("{re.escape(system)}"\s*=\s*)"[^"]+";'
    replacement = rf'\1"{hash_value}";'
    body, count = re.subn(pattern, replacement, body, count=1)
    if count != 1:
        raise SystemExit(f"Missing hash entry for {system}")

text = text[:match.start("body")] + body + text[match.end("body"):]

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
    echo "==> Resolving stable Origin version from official installer"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9a-f]+$ ]]; then
    echo "Invalid Origin version: $version" >&2
    exit 1
  fi

  echo "==> Origin version: $version"

  local hashes_json="{}"
  local entry system platform hash
  for entry in "${platforms[@]}"; do
    IFS='|' read -r system platform <<<"$entry"
    echo "==> Prefetching $system"
    hash="$(prefetch_hash "$version" "$platform")"
    hashes_json="$(
      python3 -c \
        'import json,sys; data=json.loads(sys.argv[1]); data[sys.argv[2]]=sys.argv[3]; print(json.dumps(data))' \
        "$hashes_json" "$system" "$hash"
    )"
  done

  update_origin_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/origin/default.nix"
}

main "$@"
