{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "2026.08.24-21-50-47-ef4ede3";

  # Origin publishes one self-contained binary per (os, arch) at
  # downloads.cursor.com/co/<version>/<os>-<arch>/co.tar.gz.
  # Note: glibc only on Linux (installer rejects musl).
  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin"  = "darwin-x64";
    "x86_64-linux"   = "linux-x64";
    "aarch64-linux"  = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # Official installer version and archives. Refresh with
  # `make origin-update` rather than the CLI's `origin update`.
  hashes = {
    "aarch64-darwin" = "sha256-xUAcAdt96Qy8/WNNP1M3Xn/EvWZCg9eaVOoAj7m85Yk=";
    "x86_64-darwin"  = "sha256-5DcZhvgT6w05z4o09tbA7GMmDjET1aLOpIHSIU/wX28=";
    "x86_64-linux"   = "sha256-YaMw7IFhofBPNNp1082XI9hpo0fqP6YNsqxD2qkqQF0=";
    "aarch64-linux"  = "sha256-21fp8amD+PTg8MoTavgB33hmInVKLsPGszyicWEqNu0=";
  };
in

assert platform != null
  || throw "origin prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "origin";
  inherit version;

  src = fetchurl {
    url = "https://downloads.cursor.com/co/${version}/${platform}/co.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system};
  };

  # The archive has no top-level directory (`origin` plus a legacy `co`
  # hardlink at the root), so unpack manually like nix/pkgs/codex.
  # Linux build is glibc-linked, so patch the ELF interpreter for Nix/NixOS.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    tar --no-same-owner -xzf $src -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Real binary lives in libexec; $out/bin/origin is a wrapper.
    mkdir -p $out/libexec/origin $out/bin
    install -Dm755 build/origin $out/libexec/origin/origin

    # `origin auth login` / `auth setup-git` append a git credential-helper
    # entry carrying this package's absolute store path, which every version
    # bump + GC invalidates (same known issue as gh's helper on NixOS —
    # nixpkgs does not patch it; home-manager sidesteps it by owning the
    # gitconfig, impossible here since gitconfig is an out-of-store symlink).
    # The wrapper rewrites such entries to a PATH-based `origin` invocation
    # right after those subcommands succeed. `auth login --local` (repo-local
    # config) is intentionally not covered.
    cat > $out/bin/origin <<'WRAPPER'
#!/bin/sh
# Wrapper for origin: pass through, then normalize gitconfig credential
# helpers written as absolute /nix/store paths into PATH-based lookups.
real="@out@/libexec/origin/origin"

"$real" "$@"
status=$?

if [ "$status" -eq 0 ]; then
  case "$1" in
    auth)
      case "$2" in
        login | setup-git)
          origin_fix_gitconfig() {
            cfg=$1
            [ -f "$cfg" ] || return 0
            grep -q '/nix/store/[^ ]*-origin-[^ ]*/origin credential-helper' "$cfg" || return 0
            tmp="$cfg.origin-fixup.$$"
            sed -e 's#/nix/store/[^ ]*-origin-[^ ]*/origin credential-helper$#origin credential-helper#' "$cfg" > "$tmp" || { rm -f "$tmp"; return 0; }
            cat "$tmp" > "$cfg"
            rm -f "$tmp"
          }
          origin_fix_gitconfig "$HOME/.gitconfig"
          origin_fix_gitconfig "$HOME/.config/git/config"
          if [ -n "$XDG_CONFIG_HOME" ]; then
            origin_fix_gitconfig "$XDG_CONFIG_HOME/git/config"
          fi
          ;;
      esac
      ;;
  esac
fi

exit $status
WRAPPER
    sed -i "s|@out@|$out|g" $out/bin/origin
    chmod +x $out/bin/origin

    runHook postInstall
  '';

  # Preserve the vendor-shipped binary as-is (bundled runtime payload).
  dontStrip = true;

  meta = with lib; {
    description = "Origin CLI — terminal client for Cursor Origin, Cursor's git forge";
    homepage = "https://cursor.com/docs/origin/cli";
    license = licenses.unfree;
    mainProgram = "origin";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
