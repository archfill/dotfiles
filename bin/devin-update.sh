#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVIN_NIX="$DOTFILES_DIR/nix/pkgs/devin/default.nix"

# platform key 一覧は下の Python 内で定義。Nix system への対応は
# nix/pkgs/devin/default.nix の platformMap を参照。

usage() {
  cat <<'USAGE'
Usage:
  bin/devin-update.sh [VERSION]
  VERSION=3000.10.27 bin/devin-update.sh

If VERSION is omitted, the latest promoted version is read from
https://static.devin.ai/cli/current/manifest.json. A specific version is
resolved via https://static.devin.ai/cli/<version>/manifest.json.

The manifest carries the sha256 of every platform tarball, so no tarball
downloads are needed here; fetchurl verifies the same hash at build time.
USAGE
}

fetch_manifest() {
  local version="$1"
  local url="https://static.devin.ai/cli/current/manifest.json"
  if [[ -n "$version" ]]; then
    url="https://static.devin.ai/cli/${version}/manifest.json"
  fi
  curl -fsSL "$url"
}

update_devin_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$DEVIN_NIX" "$version" "$hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
hashes = json.loads(sys.argv[3])
text = path.read_text()

text = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)

block_pattern = r'(?P<prefix>\bhashes\s*=\s*\{)(?P<body>.*?)(?P<suffix>\n\s*\};)'
match = re.search(block_pattern, text, flags=re.DOTALL)
if match is None:
    raise SystemExit("Missing hash block for hashes")

body = match.group("body")
for platform, hash_value in hashes.items():
    pattern = rf'("{re.escape(platform)}"\s*=\s*)"[^"]+";'
    replacement = rf'\1"{hash_value}";'
    body, count = re.subn(pattern, replacement, body, count=1)
    if count != 1:
        raise SystemExit(f"Missing hash entry for {platform}")

text = text[:match.start("body")] + body + text[match.end("body"):]

path.write_text(text)
PY
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    return 0
  fi

  local version="${1:-${VERSION:-}}"

  echo "==> Fetching Devin CLI manifest"
  local manifest
  manifest="$(fetch_manifest "$version")"

  # manifest.json の version と platform sha256 (hex) を SRI (base64) へ変換
  local parsed
  parsed="$(printf '%s' "$manifest" | python3 -c '
import base64
import json
import sys

manifest = json.load(sys.stdin)
version = manifest["version"]
platforms = [
    "aarch64-apple-darwin",
    "x86_64-apple-darwin",
    "x86_64-unknown-linux",
    "aarch64-unknown-linux",
]
hashes = {}
for platform in platforms:
    entry = manifest["platforms"].get(platform)
    if entry is None:
        print(f"manifest has no entry for {platform}", file=sys.stderr)
        sys.exit(1)
    hashes[platform] = "sha256-" + base64.b64encode(
        bytes.fromhex(entry["sha256"])
    ).decode()
print(json.dumps({"version": version, "hashes": hashes}))
')"

  version="$(printf '%s' "$parsed" | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])')"
  local hashes_json
  hashes_json="$(printf '%s' "$parsed" | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["hashes"]))')"

  echo "==> Updating Devin CLI to v${version}"
  update_devin_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/devin/default.nix"
}

main "$@"
