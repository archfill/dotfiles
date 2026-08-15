#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CURSOR_AGENT_NIX="$DOTFILES_DIR/nix/pkgs/cursor-agent/default.nix"

platforms=(
  "aarch64-darwin|darwin|arm64"
  "x86_64-darwin|darwin|x64"
  "x86_64-linux|linux|x64"
  "aarch64-linux|linux|arm64"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/cursor-agent-update.sh [VERSION]
  VERSION=2026.08.11-e8db854 bin/cursor-agent-update.sh

If VERSION is omitted, the version embedded in Cursor's official installer is
used. The Nix package owns updates, so the CLI should use its static channel.
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
  local version="$1"
  local hashes_json="$2"

  python3 - "$CURSOR_AGENT_NIX" "$version" "$hashes_json" <<'PY'
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
    echo "==> Resolving latest Cursor Agent version from official installer"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9a-f]+$ ]]; then
    echo "Invalid Cursor Agent version: $version" >&2
    exit 1
  fi

  echo "==> Cursor Agent version: $version"

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

  update_cursor_agent_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/cursor-agent/default.nix"
}

main "$@"
