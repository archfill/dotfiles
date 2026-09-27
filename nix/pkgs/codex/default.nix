{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bubblewrap,
}:

let
  version = "0.157.1";

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
    "aarch64-apple-darwin"       = "sha256-PEWxYrenb1EyUBWx0KgRLHMhm3qbWc1XYsN8m6VYlPo=";
    "x86_64-apple-darwin"        = "sha256-KBqbgGtfYrcNHitlEBvaNpCV8vcvoSMbjgQQ95AcmiA=";
    "x86_64-unknown-linux-musl"  = "sha256-6YwejgKOgTf6LSQVyC7Fjns3AaYn41VKrOWzyjFFSvI=";
    "aarch64-unknown-linux-musl" = "sha256-TGscF8HF/Q1PspUbdIGGe5Xqcysf6rJpyYWIsV2xYlM=";
  };

  codeModeHostHashes = {
    "aarch64-apple-darwin"       = "sha256-KIMy0slw31xhyPvf6sZKi/cvsawZRZQtpFN+z2MTgxQ=";
    "x86_64-apple-darwin"        = "sha256-P+Wo/Gs4/7tAV18XSfiUeessNE9tUzN7nqhUcGBbDJY=";
    "x86_64-unknown-linux-musl"  = "sha256-NRb5uLvmvAbue9uSspOhfqsZSz8QubnqEMW4Oely1/w=";
    "aarch64-unknown-linux-musl" = "sha256-6DdCgG2pjpp3rSQwnr0WKegid1WjQa0LQo+IXJe7MY4=";
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
