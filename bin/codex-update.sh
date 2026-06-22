#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_NIX="$DOTFILES_DIR/nix/pkgs/codex/default.nix"

platforms=(
  "aarch64-apple-darwin"
  "x86_64-apple-darwin"
  "x86_64-unknown-linux-musl"
  "aarch64-unknown-linux-musl"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/codex-update.sh [VERSION]
  VERSION=0.142.0 bin/codex-update.sh
  CODEX_INCLUDE_PRERELEASE=1 bin/codex-update.sh

If VERSION is omitted, the latest non-prerelease GitHub release tag matching
rust-v* is used. Set CODEX_INCLUDE_PRERELEASE=1 to include prereleases.
USAGE
}

latest_version() {
  curl -fsSL "https://api.github.com/repos/openai/codex/releases?per_page=30" |
    python3 -c '
import json
import os
import re
import sys

include_prerelease = os.environ.get("CODEX_INCLUDE_PRERELEASE") == "1"

for release in json.load(sys.stdin):
    if release.get("prerelease") and not include_prerelease:
        continue
    tag = release.get("tag_name", "")
    match = re.fullmatch(r"rust-v(.+)", tag)
    if match:
        print(match.group(1))
        sys.exit(0)

print("No rust-v* Codex release found", file=sys.stderr)
sys.exit(1)
'
}

prefetch_hash() {
  local version="$1"
  local platform="$2"

  nix store prefetch-file --hash-type sha256 --json \
    "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_codex_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$CODEX_NIX" "$version" "$hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
hashes = json.loads(sys.argv[3])
text = path.read_text()

text = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)

for platform, hash_value in hashes.items():
    pattern = rf'("{re.escape(platform)}"\s*=\s*)"[^"]+";'
    replacement = rf'\1"{hash_value}";'
    text, count = re.subn(pattern, replacement, text, count=1)
    if count != 1:
        raise SystemExit(f"Missing hash entry for {platform}")

path.write_text(text)
PY
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    return 0
  fi

  local version="${1:-${VERSION:-}}"
  if [[ -z "$version" ]]; then
    echo "==> Fetching latest Codex release"
    version="$(latest_version)"
  fi

  echo "==> Updating Codex to v${version}"

  local hashes_json="{"
  local first=1
  for platform in "${platforms[@]}"; do
    echo "==> Prefetching ${platform}"
    local hash
    hash="$(prefetch_hash "$version" "$platform")"
    if [[ "$first" -eq 0 ]]; then
      hashes_json+=","
    fi
    hashes_json+="\"${platform}\":\"${hash}\""
    first=0
  done
  hashes_json+="}"

  update_codex_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/codex/default.nix"
}

main "$@"
