{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bubblewrap,
}:

let
  version = "0.162.1";

  # Use the complete runtime package: daemon startup requires its manifest,
  # helper binaries, and resources, not just the standalone CLI executable.
  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
    "x86_64-darwin"  = "x86_64-apple-darwin";
    "x86_64-linux"   = "x86_64-unknown-linux-musl";
    "aarch64-linux"  = "aarch64-unknown-linux-musl";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # SRI hashes for codex rust-v${version}. Refresh: `make codex-update VERSION=...`
  hashes = {
    "aarch64-apple-darwin"       = "sha256-iON8zd9aD06p3BvhPGaiqU+cLRoE86zpBT1xs5OeiF0=";
    "x86_64-apple-darwin"        = "sha256-iUrCCv6BnU+ipL6M0nxU/WBjOLhgNujtm2yZeMLceu0=";
    "x86_64-unknown-linux-musl"  = "sha256-pnb1ciquDYbL43ZDMvCOqx/didwKMAs61P+/SGEfo+M=";
    "aarch64-unknown-linux-musl" = "sha256-U6nOC5S+snpj/esvdwTZUZnheziYqjO2BGGhqTrA2Is=";
  };
in

assert platform != null
  || throw "codex prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  # Preserve the upstream package layout when extracting the archive.
  dontUnpack = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    tar -xzf $src -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/codex $out/bin
    cp -R build/. $out/libexec/codex/
    # Keep bin/codex inside the package a native executable. The daemon checks
    # its contents against current_exe before copying the package.
    ln -s $out/libexec/codex/bin/codex-code-mode-host $out/bin/codex-code-mode-host

    # codex ships an in-place auto-updater that would rewrite the
    # /nix/store binary; disable it so Nix owns the version pinned here.
    # Linux needs bubblewrap on PATH for codex's sandboxing (landlock/seccomp).
    makeWrapper $out/libexec/codex/bin/codex $out/bin/codex \
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
