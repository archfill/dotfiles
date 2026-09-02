{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  version = "2026.08.31-4057e58";

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
    "aarch64-darwin" = "sha256-qUSDz1oWB7/hLLNCFr4Mj5WJnw9pj7heUAuijXMy+7A=";
    "x86_64-darwin" = "sha256-A+ZpMHEDa8TFJZuCXtrVrQvlJlug180Pa4MAT4Zkqm4=";
    "x86_64-linux" = "sha256-fjBttXUCGamcAO1Rf+iyNdPFTkyl934v8WDMl85wd5g=";
    "aarch64-linux" = "sha256-z122tQR7MoDYpJRxz9Qb6x1eR1d0F3313yhRhXq2UUo=";
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
