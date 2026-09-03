#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  rovehelm-update [--no-pull]

Update the personal Rovehelm installation from a clean local checkout.

Environment:
  ROVEHELM_REPO          Checkout path (default: /home/archfill/git/rovehelm)
  ROVEHELM_DATA_HOME    Application data root (default: XDG_DATA_HOME/rovehelm)
  ROVEHELM_VERSIONS_DIR Versioned bundle root
  ROVEHELM_CURRENT_LINK Current bundle symlink

The update keeps versioned bundles so the launcher can stage a safe daemon
upgrade without replacing binaries used by a live PTY session.
USAGE
}

die() {
  echo "rovehelm-update: $*" >&2
  exit 1
}

pull=true
while (($# > 0)); do
  case "$1" in
    --no-pull)
      pull=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "unknown argument: $1"
      ;;
  esac
done

[[ "$(uname -s)" == "Linux" ]] || die "this personal installer currently supports Linux only"

user_home="${HOME:?HOME is not set}"
data_home="${XDG_DATA_HOME:-$user_home/.local/share}"
rovehelm_data="${ROVEHELM_DATA_HOME:-$data_home/rovehelm}"
versions_dir="${ROVEHELM_VERSIONS_DIR:-$rovehelm_data/versions}"
current_link="${ROVEHELM_CURRENT_LINK:-$rovehelm_data/current}"
repo_arg="${ROVEHELM_REPO:-/home/archfill/git/rovehelm}"

[[ -d "$repo_arg" ]] || die "Rovehelm checkout not found: $repo_arg"
repo_dir="$(cd "$repo_arg" && pwd -P)"
git -C "$repo_dir" rev-parse --show-toplevel >/dev/null 2>&1 \
  || die "not a Git checkout: $repo_dir"

status="$(git -C "$repo_dir" status --porcelain=v1 --untracked-files=all)"
[[ -z "$status" ]] || die "checkout has local changes; commit or stash them before updating"

if [[ "$pull" == true ]]; then
  git -C "$repo_dir" pull --ff-only
fi

commit_id="$(git -C "$repo_dir" rev-parse --short=12 HEAD)"
build_dir="$repo_dir/target/release"
version_dir="$versions_dir/$commit_id"
required_binaries=(
  rovehelm-launcher
  rovehelm
  rovehelmd
  rovehelm-agent-hook
  rovehelm-messaging
)

bundle_is_complete() {
  local binary
  for binary in "${required_binaries[@]}"; do
    [[ -x "$version_dir/bin/$binary" ]] || return 1
  done
  [[ -f "$version_dir/share/rovehelm/integrations/pi/rovehelm-messaging.ts" ]] \
    && [[ -f "$version_dir/share/rovehelm/integrations/pi/manifest.json" ]]
}

temporary_dir=""
cleanup() {
  if [[ -n "$temporary_dir" && -d "$temporary_dir" ]]; then
    rm -rf -- "$temporary_dir"
  fi
}
trap cleanup EXIT

if bundle_is_complete; then
  echo "Rovehelm $commit_id is already installed; reusing the existing bundle."
else
  mkdir -p "$versions_dir"
  temporary_dir="$versions_dir/.${commit_id}.tmp.$$"
  mkdir "$temporary_dir"

  echo "Building Rovehelm $commit_id in the pinned Nix development shell..."
  (
    cd "$repo_dir"
    nix develop "${repo_dir}#default" -c cargo build --release --locked \
      -p rovehelm-launcher \
      -p rovehelm \
      -p rovehelmd \
      -p rovehelm-messaging
  )

  for binary in "${required_binaries[@]}"; do
    [[ -x "$build_dir/$binary" ]] || die "release binary was not built: $build_dir/$binary"
    install -Dm755 "$build_dir/$binary" "$temporary_dir/bin/$binary"
  done

  install -Dm644 "$repo_dir/integrations/pi/rovehelm-messaging.ts" \
    "$temporary_dir/share/rovehelm/integrations/pi/rovehelm-messaging.ts"
  install -Dm644 "$repo_dir/integrations/pi/manifest.json" \
    "$temporary_dir/share/rovehelm/integrations/pi/manifest.json"

  mv -- "$temporary_dir" "$version_dir"
  temporary_dir=""
  echo "Installed Rovehelm bundle: $version_dir"
fi

install -Dm644 "$repo_dir/packaging/linux/rovehelm.desktop" \
  "$data_home/applications/rovehelm.desktop"
install -Dm644 "$repo_dir/packaging/linux/com.archfill.rovehelm.png" \
  "$data_home/icons/hicolor/512x512/apps/com.archfill.rovehelm.png"

next_link="${current_link}.next.$$"
mkdir -p "$(dirname "$current_link")"
rm -f -- "$next_link"
ln -s "$version_dir" "$next_link"
mv -Tf -- "$next_link" "$current_link"

echo "Activated Rovehelm bundle: $version_dir"
"$version_dir/bin/rovehelm-launcher" upgrade
