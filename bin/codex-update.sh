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

# Print a JSON map {platform: SRI hash} from the release's published asset
# digests (sha256:<hex>). One API call covers every platform; no downloads.
release_hashes() {
  local version="$1"

  curl -fsSL "https://api.github.com/repos/openai/codex/releases/tags/rust-v${version}" |
    python3 -c '
import base64
import json
import sys

platforms = sys.argv[1:]
assets = {a["name"]: a.get("digest") or "" for a in json.load(sys.stdin).get("assets", [])}
result = {}
for platform in platforms:
    name = f"codex-package-{platform}.tar.gz"
    digest = assets.get(name, "")
    if not digest.startswith("sha256:"):
        print(f"No sha256 digest published for {name}", file=sys.stderr)
        sys.exit(1)
    result[platform] = "sha256-" + base64.b64encode(bytes.fromhex(digest[7:])).decode()
print(json.dumps(result))
' "${platforms[@]}"
}

update_codex_nix() {
  local version="$1"
  local package_hashes_json="$2"

  python3 - "$CODEX_NIX" "$version" "$package_hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
package_hashes = json.loads(sys.argv[3])
text = path.read_text()

text = re.sub(r'version = "[^"]+";', f'version = "{version}";', text, count=1)

def replace_hash_block(text, name, values):
    block_pattern = rf'(?P<prefix>\b{re.escape(name)}\s*=\s*\{{)(?P<body>.*?)(?P<suffix>\n\s*\}};)'
    match = re.search(block_pattern, text, flags=re.DOTALL)
    if match is None:
        raise SystemExit(f"Missing hash block for {name}")

    body = match.group("body")
    for platform, hash_value in values.items():
        pattern = rf'("{re.escape(platform)}"\s*=\s*)"[^"]+";'
        replacement = rf'\1"{hash_value}";'
        body, count = re.subn(pattern, replacement, body, count=1)
        if count != 1:
            raise SystemExit(f"Missing hash entry for {platform} in {name}")

    return text[:match.start("body")] + body + text[match.end("body"):]


text = replace_hash_block(text, "packageHashes", package_hashes)

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

  echo "==> Reading published sha256 digests from the GitHub release"
  local package_hashes_json
  package_hashes_json="$(release_hashes "$version")"

  update_codex_nix "$version" "$package_hashes_json"
  echo "==> Updated nix/pkgs/codex/default.nix"
}

main "$@"
