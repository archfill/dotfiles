# Normalize GitHub CLI credential helpers written as absolute Nix store paths.
#
# gh auth login/setup-git resolves its own executable path on Linux. When gh is
# reached through a Nix profile symlink, that path points into /nix/store and
# becomes stale after a package update and garbage collection.
normalize_gh_gitconfig() {
  cfg="$1"
  [ -f "$cfg" ] || return 0

  tmp="$(mktemp "${cfg}.gh-fixup.XXXXXX")" || return 0
  if ! sed -E \
    's#/nix/store/[^/[:space:]]*/bin/(\.gh-wrapped|gh) auth git-credential$#gh auth git-credential#' \
    "$cfg" > "$tmp"; then
    rm -f "$tmp"
    return 0
  fi

  # Keep out-of-store symlinks (used by this repository) intact.
  if ! cat "$tmp" > "$cfg"; then
    rm -f "$tmp"
    return 0
  fi
  rm -f "$tmp"
}
