#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GROK_BOT_NIX="$DOTFILES_DIR/nix/pkgs/grok-bot/default.nix"
FEED_URL="https://api2.cursor.sh/updates/api/update/linux-x64/sand/0.0.1/07d67027-2556-4c0e-9fd9-e0bde18922ca/stable"

usage() {
  cat <<'USAGE'
Usage:
  bin/grok-bot-update.sh [DEB_URL]

Without an argument, resolve the current stable Linux x86_64 release from
Grok Bot's official update feed and update the pinned .deb URL/hash.
An explicit official .deb URL can be supplied to pin a specific build.
USAGE
}

fail() {
  echo "grok-bot-update: $*" >&2
  exit 1
}

parse_deb_location() {
  local url="$1"
  local filename="${url##*/}"

  if [[ ! "$url" =~ ^(https://downloads\.cursor\.com/[a-z0-9-]+/stable)/([0-9a-f]{40})/linux/x64/(grok-bot_[^/]+_amd64\.deb|Grok_Bot_[^/]+\.deb)$ ]]; then
    return 1
  fi

  download_base="${BASH_REMATCH[1]}"
  build_id="${BASH_REMATCH[2]}"

  case "$filename" in
  grok-bot_*_amd64.deb)
    version="${filename#grok-bot_}"
    version="${version%_amd64.deb}"
    deb_file="grok-bot_\${finalAttrs.version}_amd64.deb"
    ;;
  Grok_Bot_*.deb)
    version="${filename#Grok_Bot_}"
    version="${version%.deb}"
    deb_file="Grok_Bot_\${finalAttrs.version}.deb"
    ;;
  *)
    return 1
    ;;
  esac
}

prefetch_deb() {
  local url="$1"
  echo "==> Prefetching $url" >&2
  nix store prefetch-file --hash-type sha256 --json "$url"
}

resolve_deb_from_feed() {
  local response="$1"
  local artifact_url

  version="$(jq -er '.version // .name' <<<"$response")" ||
    fail "stable feed did not contain a version"
  artifact_url="$(jq -er '.url' <<<"$response")" ||
    fail "stable feed did not contain an artifact URL"

  # The feed advertises the AppImage zsync sidecar. The official .deb shares
  # its namespace/build ID, so derive and verify the Debian artifact instead.
  if [[ ! "$artifact_url" =~ ^(https://downloads\.cursor\.com/[a-z0-9-]+/stable)/([0-9a-f]{40})/linux/x64/ ]]; then
    fail "unexpected stable feed URL: $artifact_url"
  fi
  download_base="${BASH_REMATCH[1]}"
  build_id="${BASH_REMATCH[2]}"

  local candidate candidate_meta
  for candidate in \
    "${download_base}/${build_id}/linux/x64/grok-bot_${version}_amd64.deb" \
    "${download_base}/${build_id}/linux/x64/Grok_Bot_${version}.deb"; do
    if candidate_meta="$(prefetch_deb "$candidate" 2>/dev/null)"; then
      deb_url="$candidate"
      prefetch="$candidate_meta"
      case "${candidate##*/}" in
      grok-bot_*_amd64.deb) deb_file="grok-bot_\${finalAttrs.version}_amd64.deb" ;;
      Grok_Bot_*.deb) deb_file="Grok_Bot_\${finalAttrs.version}.deb" ;;
      *) fail "unsupported .deb filename: ${candidate##*/}" ;;
      esac
      return 0
    fi
  done

  fail "no official Linux x86_64 .deb found for $version ($build_id)"
}

deb_field() {
  local deb_path="$1"
  local field="$2"

  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb -f "$deb_path" "$field"
  else
    # Arch and minimal NixOS installations may not have dpkg-deb. Use the
    # pinned nixpkgs tool transiently only for metadata validation.
    nix shell --extra-experimental-features 'nix-command flakes' \
      nixpkgs#dpkg --command dpkg-deb -f "$deb_path" "$field"
  fi
}

update_nix_definition() {
  local hash="$1"

  python3 - "$GROK_BOT_NIX" "$version" "$download_base" "$build_id" "$deb_file" "$hash" <<'PY'
import re
import sys
from pathlib import Path

path, version, download_base, build_id, deb_file, digest = sys.argv[1:]
text = Path(path).read_text()

replacements = {
    r'(^  version = ")[^"]+(";$)': rf'\g<1>{version}\g<2>',
    r'(^  buildId = ")[^"]+(";$)': rf'\g<1>{build_id}\g<2>',
    r'(^  downloadBase = ")[^"]+(";$)': rf'\g<1>{download_base}\g<2>',
    r'(^  debFile = ")[^"]+(";$)': rf'\g<1>{deb_file}\g<2>',
    r'(^    hash = ")[^"]+(";$)': rf'\g<1>{digest}\g<2>',
}

for pattern, replacement in replacements.items():
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"missing package metadata line: {pattern}")

Path(path).write_text(text)
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

  local deb_url="${1:-}"
  local prefetch=""
  local version=""
  local download_base=""
  local build_id=""
  local deb_file=""

  if [[ -n "$deb_url" ]]; then
    parse_deb_location "$deb_url" ||
      fail "unsupported official Linux x86_64 .deb URL: $deb_url"
    prefetch="$(prefetch_deb "$deb_url")"
  else
    echo "==> Resolving latest Grok Bot stable release"
    local response
    response="$(curl --retry 3 --retry-all-errors -fsSL "$FEED_URL")" ||
      fail "could not fetch stable update feed"
    resolve_deb_from_feed "$response"
  fi

  if [[ ! "$version" =~ ^[0-9][0-9A-Za-z._+~-]*$ ]]; then
    fail "invalid release version: $version"
  fi

  local hash deb_path
  hash="$(jq -er '.hash' <<<"$prefetch")" ||
    fail "nix prefetch did not return a hash"
  deb_path="$(jq -er '.storePath' <<<"$prefetch")" ||
    fail "nix prefetch did not return a store path"

  [[ "$(deb_field "$deb_path" Package)" == "grok-bot" ]] ||
    fail "downloaded artifact is not the grok-bot package"
  [[ "$(deb_field "$deb_path" Version)" == "$version" ]] ||
    fail "package version does not match feed: expected $version"
  [[ "$(deb_field "$deb_path" Architecture)" == "amd64" ]] ||
    fail "package architecture is not amd64"

  echo "==> Grok Bot version: $version"
  echo "==> Updating $GROK_BOT_NIX"
  update_nix_definition "$hash"
  echo "==> Updated nix/pkgs/grok-bot/default.nix"
}

main "$@"
