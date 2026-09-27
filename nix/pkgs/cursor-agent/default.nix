{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  version = "2026.09.26-dd393fe";

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

  # Official installer version and archives. Refresh with
  # `make cursor-agent-update` rather than the CLI's in-place updater.
  hashes = {
    "aarch64-darwin" = "sha256-U4gn2Wp3m6uFSoZcjkKFno6H2zS19pdwJhuQ/Iz/8ZE=";
    "x86_64-darwin" = "sha256-7RdxxEy/D4BZxnysDZOeamDrcwvQZtfcTLsU3jFM+24=";
    "x86_64-linux" = "sha256-gIX9Eg9ccfTq5/6iagQ3GOVkTjBx5PqzIgoOWMUflZM=";
    "aarch64-linux" = "sha256-qxF40NjBCyVOfkJ9HWc1M6OJM4Qk51A0vpq52gKEW94=";
  };
in

assert platform != null
  || throw "cursor-agent prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "cursor-agent";
  inherit version;

  src = fetchurl {
    url = "https://downloads.cursor.com/lab/${version}/${platform.os}/${platform.arch}/agent-cli-package.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system};
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
    ln -s ../libexec/cursor-agent/cursor-agent $out/bin/agent
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
