#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_NIX="$DOTFILES_DIR/nix/pkgs/claude-code/default.nix"

DOWNLOAD_BASE_URL="https://downloads.claude.ai/claude-code-releases"

# Nix system -> upstream platform name (manifest.json key)
declare -A PLATFORM_MAP=(
  ["aarch64-darwin"]="darwin-arm64"
  ["x86_64-darwin"]="darwin-x64"
  ["x86_64-linux"]="linux-x64"
  ["aarch64-linux"]="linux-arm64"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/claude-update.sh [VERSION]
  VERSION=2.1.278 bin/claude-update.sh
  CLAUDE_CHANNEL=stable bin/claude-update.sh

If VERSION is omitted, the latest version of the release channel is used.
CLAUDE_CHANNEL is "latest" (default) or "stable", matching the official
native installer channels.
USAGE
}

latest_version() {
  local channel="${CLAUDE_CHANNEL:-latest}"
  local version
  version="$(curl -fsSL "$DOWNLOAD_BASE_URL/$channel")"
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "Failed to get a valid version from $DOWNLOAD_BASE_URL/$channel (got: $version)" >&2
    exit 1
  fi
  echo "$version"
}

# Print a JSON map {platform: SRI hash} from the release manifest's published
# sha256 checksums (hex). One small request covers every platform.
manifest_hashes() {
  local version="$1"
  shift

  curl -fsSL "$DOWNLOAD_BASE_URL/$version/manifest.json" |
    python3 -c '
import base64
import json
import sys

platforms = json.load(sys.stdin).get("platforms", {})
result = {}
for platform in sys.argv[1:]:
    checksum = (platforms.get(platform) or {}).get("checksum", "")
    if len(checksum) != 64:
        print(f"No sha256 checksum in manifest for {platform}", file=sys.stderr)
        sys.exit(1)
    result[platform] = "sha256-" + base64.b64encode(bytes.fromhex(checksum)).decode()
print(json.dumps(result))
' "$@"
}

update_claude_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$CLAUDE_NIX" "$version" "$hashes_json" <<'PY'
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
    raise SystemExit("Missing hash block")

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
  if [[ -z "$version" ]]; then
    echo "==> Fetching latest Claude Code release (channel: ${CLAUDE_CHANNEL:-latest})"
    version="$(latest_version)"
  fi

  echo "==> Updating Claude Code to v${version}"

  echo "==> Reading sha256 checksums from the release manifest"
  local hashes_json
  hashes_json="$(manifest_hashes "$version" "${PLATFORM_MAP[@]}")"

  update_claude_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/claude-code/default.nix"
}

main "$@"
