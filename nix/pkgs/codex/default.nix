{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bubblewrap,
}:

let
  version = "0.153.4";

  # codex publishes a single prebuilt native binary per (arch, os).
  # Map the Nix system triple to the upstream tarball suffix.
  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
    "x86_64-darwin"  = "x86_64-apple-darwin";
    "x86_64-linux"   = "x86_64-unknown-linux-musl";
    "aarch64-linux"  = "aarch64-unknown-linux-musl";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # SRI hashes for codex rust-v${version}. Refresh: `make codex-update VERSION=...`
  hashes = {
    "aarch64-apple-darwin"       = "sha256-jPkR6mdlI7+yEh7FYYSNKrpWSJCtU2202KM1PyuYULE=";
    "x86_64-apple-darwin"        = "sha256-1pIA8L+EGx0aB/gLgM90Ki5Pwrq5GuikSxBC+OjKn6Q=";
    "x86_64-unknown-linux-musl"  = "sha256-9HlCTsoJJITcQNh64oxE9MxAI0pgBF1hMeSTgA2BSjA=";
    "aarch64-unknown-linux-musl" = "sha256-XNphgr2Uw6MPLrY6SVSJ6/f2kf3bFNcPSMbBpQcbbN4=";
  };

  codeModeHostHashes = {
    "aarch64-apple-darwin"       = "sha256-Ramw/fU7mLhaa7keF13ZDpYTKKehT7UKQJAiBRmd8d8=";
    "x86_64-apple-darwin"        = "sha256-L/rr0BA9l2Iyw1hBmlCIWdqGLhKPPKC7BxVBNG++O/c=";
    "x86_64-unknown-linux-musl"  = "sha256-+VgwqGlZCVdmS7/Ge8ywh3OAa2k2cLrxWQgXb4m0zTE=";
    "aarch64-unknown-linux-musl" = "sha256-2AR7jTM3DWCQ5ynSfrdt5gomhrqhwUPBOMmwXccNgTs=";
  };
in

assert platform != null
  || throw "codex prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  codeModeHostSrc = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-${platform}.tar.gz";
    hash = codeModeHostHashes.${platform};
  };

  # Each release asset is a single binary named `<artifact>-<platform>` with
  # no directory layout, so unpack both archives manually in buildPhase.
  dontUnpack = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    tar -xzf $src -C build
    tar -xzf $codeModeHostSrc -C build
    mv "build/codex-${platform}" build/codex
    mv "build/codex-code-mode-host-${platform}" build/codex-code-mode-host
    chmod u+w,+x build/codex build/codex-code-mode-host
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 build/codex $out/bin/codex
    install -Dm555 build/codex-code-mode-host $out/bin/codex-code-mode-host

    # codex ships an in-place auto-updater that would rewrite the
    # /nix/store binary; disable it so Nix owns the version pinned here.
    # Linux needs bubblewrap on PATH for codex's sandboxing (landlock/seccomp).
    wrapProgram $out/bin/codex \
      --set DISABLE_AUTOUPDATER 1 \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
      ''}
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI — lightweight AI coding agent (prebuilt native binary)";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    mainProgram = "codex";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
