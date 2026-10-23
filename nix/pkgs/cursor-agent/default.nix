{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  platformMap = {
    "aarch64-darwin" = {
      os = "darwin";
      arch = "arm64";
    };
    "x86_64-darwin" = {
      os = "darwin";
      arch = "x64";
    };
    "x86_64-linux" = {
      os = "linux";
      arch = "x64";
    };
    "aarch64-linux" = {
      os = "linux";
      arch = "arm64";
    };
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # Per-system pins: each host refreshes only its own entry with
  # `make cursor-agent-update`, so other systems may lag behind.
  sources = {
    "aarch64-darwin" = {
      version = "2026.10.19-6bbf2c4";
      hash = "sha256-CV3MuSNIjSgKrml7powTqSu9nOHcYQVAHhR+JYafKxM=";
    };
    "x86_64-darwin" = {
      version = "2026.10.16-e3cb207";
      hash = "sha256-kzcuOE6Tl7VLHk/bGBJmL2jnthwMYMs/L0t4jJ4HecQ=";
    };
    "x86_64-linux" = {
      version = "2026.10.22-27dcf5f";
      hash = "sha256-hSlpRORgCoPEt2T1eNFQK/nEFtsgDTOlk+jz7Kv9wpQ=";
    };
    "aarch64-linux" = {
      version = "2026.10.16-e3cb207";
      hash = "sha256-TPB38VDrjR4nC/HeppcAGEw5pIR/4ZLVI/W7NNS2JZc=";
    };
  };
  source = sources.${stdenv.hostPlatform.system} or null;
in

assert platform != null && source != null
  || throw "cursor-agent prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "cursor-agent";
  inherit (source) version;

  src = fetchurl {
    url = "https://downloads.cursor.com/lab/${source.version}/${platform.os}/${platform.arch}/agent-cli-package.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = "dist-package";

  # The bundled native Node modules link against the C++ runtime and zlib.
  # Keep these available to autoPatchelfHook so the prebuilt package can be
  # used on NixOS instead of relying on host /usr/lib paths.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    stdenv.cc.cc.lib
  ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ zlib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/cursor-agent $out/bin
    cp -R . $out/libexec/cursor-agent/
    # canonical 名 `agent` は Grok Build 側が専有するため、ここでは
    # `cursor-agent` のみ提供する (home.packages の bin 衝突を避ける)。
    ln -s ../libexec/cursor-agent/cursor-agent $out/bin/cursor-agent

    runHook postInstall
  '';

  # Preserve the bundled Node runtime and native modules as shipped. Linux's
  # autoPatchelfHook only adjusts their dynamic loader paths for Nix/NixOS.
  dontStrip = true;

  meta = with lib; {
    description = "Cursor Agent CLI for terminal-based coding workflows";
    homepage = "https://cursor.com/docs/cli";
    license = licenses.unfree;
    mainProgram = "cursor-agent";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
