#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GROK_BUILD_NIX="$DOTFILES_DIR/nix/pkgs/grok-build/default.nix"

platforms=(
  "aarch64-darwin|macos-aarch64"
  "x86_64-linux|linux-x86_64"
  "aarch64-linux|linux-aarch64"
)

usage() {
  cat <<'USAGE'
Usage:
  bin/grok-build-update.sh [VERSION]
  VERSION=1.0.52 bin/grok-build-update.sh

If VERSION is omitted, the stable-channel version pointer
(https://x.ai/cli/stable) is used. The Nix package owns updates, so the CLI
should not update itself in place.
USAGE
}

latest_version() {
  curl -fsSL "https://x.ai/cli/stable" | tr -d '[:space:]'
}

prefetch_hash() {
  local version="$1"
  local platform="$2"

  nix store prefetch-file --hash-type sha256 --json \
    "https://x.ai/cli/grok-${version}-${platform}" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])'
}

update_grok_build_nix() {
  local version="$1"
  local hashes_json="$2"

  python3 - "$GROK_BUILD_NIX" "$version" "$hashes_json" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version = sys.argv[2]
hashes = json.loads(sys.argv[3])
text = path.read_text()

# 置換対象を `hashes = {` 以降に限定する (platform attrset の行も同じ形を
# しているため、素朴に置換すると platform 側の値を壊す)。
head, sep, tail = text.partition("  hashes = {")
if not sep:
    raise SystemExit("hashes block not found")

head, count = re.subn(r'(^  version = ")[^"]+(";$)', rf'\g<1>{version}\g<2>', head, count=1, flags=re.MULTILINE)
if count != 1:
    raise SystemExit("missing version line")

for system, hash_value in hashes.items():
    pattern = rf'(^    "{re.escape(system)}" = ")[^"]+(";$)'
    tail, count = re.subn(pattern, rf'\g<1>{hash_value}\g<2>', tail, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"missing hash entry for {system}")

Path(path).write_text(head + sep + tail)
PY
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  if [[ "$#" -gt 1 ]]; then
    usage >&2
    exit 2
  fi

  local version="${1:-${VERSION:-}}"
  if [[ -z "$version" ]]; then
    echo "==> Resolving stable Grok Build version from x.ai/cli/stable"
    version="$(latest_version)"
  fi

  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9._]+)?$ ]]; then
    echo "Invalid Grok Build version: $version" >&2
    exit 1
  fi

  # 未変更なら prefetch (3 プラットフォーム分のダウンロード) をスキップする。
  current_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$GROK_BUILD_NIX" | head -1)"
  if [[ "$version" == "$current_version" ]]; then
    echo "==> Already at stable Grok Build version $version; nothing to do"
    exit 0
  fi

  echo "==> Grok Build version: $version"

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

  update_grok_build_nix "$version" "$hashes_json"
  echo "==> Updated nix/pkgs/grok-build/default.nix"
}

main "$@"
