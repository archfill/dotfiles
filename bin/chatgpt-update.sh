#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHATGPT_NIX="$DOTFILES_DIR/nix/pkgs/chatgpt/default.nix"

BASE_URL="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest"

usage() {
  cat <<'USAGE'
Usage:
  bin/chatgpt-update.sh [--force]

The script first performs a lightweight check (a small HTTP Range request)
of the upstream version. When the version pinned in
nix/pkgs/chatgpt/default.nix is already up to date, nothing is downloaded.

Otherwise it downloads the latest official ChatGPT Linux .deb packages for
x86_64 and ARM64, reads their shared version, recalculates both Nix hashes,
and updates nix/pkgs/chatgpt/default.nix.

--force skips the lightweight check and always re-prefetches both packages.
USAGE
}

pinned_version() {
  sed -n 's/^[[:space:]]*version = "\([^"]*\)";.*/\1/p' "$CHATGPT_NIX" | head -n 1
}

# Read the Version field from a remote .deb without downloading it. A .deb is
# an ar archive whose second member is the (small) compressed control tarball,
# so the first few hundred bytes are enough to recover the version string.
remote_deb_version() {
  local url="$1"
  python3 - "$url" <<'PY'
import io
import lzma
import re
import sys
import tarfile
import urllib.request
import zlib

url = sys.argv[1]
limit = 262144
# The CDN rejects the default Python-urllib User-Agent with 403.
request = urllib.request.Request(
    url,
    headers={"Range": f"bytes=0-{limit - 1}", "User-Agent": "curl/8.5.0"},
)
with urllib.request.urlopen(request, timeout=60) as response:
    head = response.read(limit)

if len(head) < 8 or head[:8] != b"!<arch>\n":
    raise SystemExit(f"Not a Debian ar archive: {url}")

offset = 8
control_blob = None
while offset + 60 <= len(head):
    header = head[offset:offset + 60]
    offset += 60
    name = header[:16].decode("ascii", "replace").strip()
    try:
        size = int(header[48:58].decode("ascii").strip())
    except ValueError:
        raise SystemExit(f"Invalid ar member header in {url}")
    if name.startswith("control.tar"):
        control_blob = head[offset:offset + size]
        break
    offset += size
    if size % 2:
        offset += 1

if control_blob is None:
    raise SystemExit(f"control archive not found in the first {limit} bytes of {url}")

def decompress_gzip(blob):
    try:
        # Truncated input is fine: decompress() returns the decodable prefix.
        return zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(blob)
    except zlib.error:
        return None

def decompress_xz(blob):
    try:
        return lzma.LZMADecompressor().decompress(blob)
    except lzma.LZMAError:
        return None

tar_bytes = None
for decompress in (decompress_gzip, decompress_xz):
    tar_bytes = decompress(control_blob)
    if tar_bytes:
        break

if not tar_bytes:
    raise SystemExit(f"Unsupported control compression in {url} (need gzip or xz)")

try:
    with tarfile.open(fileobj=io.BytesIO(tar_bytes), mode="r:*") as control_tar:
        for member in control_tar.getmembers():
            if member.name.lstrip("./") != "control":
                continue
            control = control_tar.extractfile(member)
            if control is None:
                continue
            match = re.search(rb"^Version:\s*(.+?)\r?$", control.read(), re.MULTILINE)
            if match:
                print(match.group(1).decode("utf-8").strip())
                raise SystemExit(0)
except (tarfile.TarError, EOFError):
    pass

raise SystemExit(f"Version field not found in {url}")
PY
}

prefetch_json() {
  local url="$1"
  nix store prefetch-file --hash-type sha256 --json "$url"
}

deb_version() {
  local deb_path="$1"

  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb -f "$deb_path" Version
    return
  fi

  # Keep the updater usable on minimal Nix/Arch installations where dpkg-deb
  # is not installed. A .deb is an ar archive containing a compressed control
  # tarball; Python's standard library is enough to read that metadata.
  python3 - "$deb_path" <<'PY'
import io
import sys
import tarfile
from pathlib import Path

path = Path(sys.argv[1])

with path.open("rb") as archive:
    if archive.read(8) != b"!<arch>\n":
        raise SystemExit(f"Not a Debian ar archive: {path}")

    while True:
        header = archive.read(60)
        if not header:
            break
        if len(header) != 60 or header[-2:] != b"`\n":
            raise SystemExit(f"Invalid ar member header in {path}")

        name = header[:16].decode("ascii", "replace").strip().rstrip("/")
        size = int(header[48:58].decode("ascii").strip())

        if name.startswith("control.tar"):
            payload = archive.read(size)
            try:
                control_tar = tarfile.open(fileobj=io.BytesIO(payload), mode="r:*")
            except tarfile.ReadError as error:
                raise SystemExit(f"Unsupported control archive {name}: {error}") from error

            with control_tar:
                for member in control_tar.getmembers():
                    if member.name.lstrip("./") != "control":
                        continue
                    control = control_tar.extractfile(member)
                    if control is None:
                        continue
                    for line in control.read().decode("utf-8").splitlines():
                        if line.startswith("Version:"):
                            print(line.split(":", 1)[1].strip())
                            raise SystemExit(0)

            raise SystemExit(f"Version field not found in {path}")

        archive.seek(size, 1)
        if size % 2:
            archive.seek(1, 1)

raise SystemExit(f"control archive not found in {path}")
PY
}

update_chatgpt_nix() {
  local version="$1"
  local x86_hash="$2"
  local arm_hash="$3"

  python3 - "$CHATGPT_NIX" "$version" "$x86_hash" "$arm_hash" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
version, x86_hash, arm_hash = sys.argv[2:]
text = path.read_text()

text, count = re.subn(
    r'(^\s*version = ")[^"]+(";\s*$)',
    rf'\g<1>{version}\g<2>',
    text,
    count=1,
    flags=re.MULTILINE,
)
if count != 1:
    raise SystemExit("ChatGPT version declaration not found")

for system, hash_value in (("x86_64-linux", x86_hash), ("aarch64-linux", arm_hash)):
    pattern = rf'({re.escape(system)}\s*=\s*\{{.*?\bhash\s*=\s*)"[^"]+";'
    replacement = rf'\g<1>"{hash_value}";'
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.DOTALL)
    if count != 1:
        raise SystemExit(f"Hash declaration not found for {system}")

path.write_text(text)
PY
}

main() {
  local force=0
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  if [[ "${1:-}" == "--force" ]]; then
    force=1
    shift
  fi
  if [[ $# -ne 0 ]]; then
    echo "Unexpected argument: $1" >&2
    usage >&2
    exit 2
  fi

  local x86_url="$BASE_URL/chatgpt_amd64.deb"
  local arm_url="$BASE_URL/chatgpt_arm64.deb"

  if [[ "$force" -ne 1 ]]; then
    local pinned remote
    pinned="$(pinned_version 2>/dev/null || true)"
    if [[ -z "$pinned" ]]; then
      echo "==> Could not read the pinned version from nix/pkgs/chatgpt/default.nix; forcing full update"
    else
      echo "==> Checking upstream ChatGPT version (lightweight range request)"
      if remote="$(remote_deb_version "$x86_url")"; then
        if [[ "$remote" == "$pinned" ]]; then
          echo "==> ChatGPT $pinned is already pinned; skipping download"
          echo "==> Run with --force to re-prefetch anyway"
          exit 0
        fi
        echo "==> Upstream version changed: $pinned -> $remote"
      else
        echo "==> Lightweight check failed; falling back to full prefetch" >&2
      fi
    fi
  fi

  echo "==> Prefetching official ChatGPT Linux x86_64 package"
  local x86_json x86_hash x86_store_path version
  x86_json="$(prefetch_json "$x86_url")"
  x86_hash="$(printf '%s' "$x86_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])')"
  x86_store_path="$(printf '%s' "$x86_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["storePath"])')"
  version="$(deb_version "$x86_store_path")"

  if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
    echo "Unexpected ChatGPT version: $version" >&2
    exit 1
  fi
  echo "==> ChatGPT version: $version"

  echo "==> Prefetching official ChatGPT Linux ARM64 package"
  local arm_json arm_hash arm_store_path arm_version
  arm_json="$(prefetch_json "$arm_url")"
  arm_hash="$(printf '%s' "$arm_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["hash"])')"
  arm_store_path="$(printf '%s' "$arm_json" | python3 -c 'import json,sys; print(json.load(sys.stdin)["storePath"])')"
  arm_version="$(deb_version "$arm_store_path")"

  if [[ "$arm_version" != "$version" ]]; then
    echo "Architecture versions differ: x86_64=$version, aarch64=$arm_version" >&2
    exit 1
  fi

  update_chatgpt_nix "$version" "$x86_hash" "$arm_hash"
  echo "==> Updated nix/pkgs/chatgpt/default.nix"
  echo "==> Run 'make nix-rebuild' to install the updated app"
}

main "$@"
