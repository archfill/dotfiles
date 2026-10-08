{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bubblewrap,
}:

let
  version = "0.161.0";

  # Codex publishes a complete package per (arch, os). The package metadata and
  # bundled resources are required by the background app-server daemon.
  # Map the Nix system triple to the upstream tarball suffix.
  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
    "x86_64-darwin"  = "x86_64-apple-darwin";
    "x86_64-linux"   = "x86_64-unknown-linux-musl";
    "aarch64-linux"  = "aarch64-unknown-linux-musl";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # SRI hashes for codex rust-v${version}. Refresh: `make codex-update VERSION=...`
  packageHashes = {
    "aarch64-apple-darwin"       = "sha256-8P7uhTfa+N1rTgo252RUmtFK/btBnYd1rquf6yAYIxM=";
    "x86_64-apple-darwin"        = "sha256-U/fJCBq4NoSj1Ps128SwXT67IEvrLqsABibBXwsV5zg=";
    "x86_64-unknown-linux-musl"  = "sha256-BNirnby53w7fPGfcpQcqN0ur/fdiqbxK5kmuFAuOLPA=";
    "aarch64-unknown-linux-musl" = "sha256-PALirjS+DQbmJVfpj8XAp4O+xaL+1Ab+AOVlgDv4Tug=";
  };
in

assert platform != null
  || throw "codex prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-${platform}.tar.gz";
    hash = packageHashes.${platform};
  };

  # The archive has bin/, codex-package.json, codex-path/, and
  # codex-resources/ at its root. Preserve that layout verbatim under libexec;
  # app-server daemon package detection resolves the real executable and looks
  # for the manifest next to its bin directory.
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    packageRoot=$out/libexec/codex-package
    mkdir -p $packageRoot $out/bin
    tar -xzf $src -C $packageRoot

    # Keep the upstream package entrypoint untouched: daemon bootstrap verifies
    # that it is byte-identical to the running executable. Put the Nix-specific
    # environment wrapper outside the complete package instead.
    makeWrapper $packageRoot/bin/codex $out/bin/codex \
      --set DISABLE_AUTOUPDATER 1 \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
      ''}
    ln -s $packageRoot/bin/codex-code-mode-host $out/bin/codex-code-mode-host
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
