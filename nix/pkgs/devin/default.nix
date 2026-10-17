{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  versionCheckHook,
}:

let
  version = "3000.11.92";

  # devin publishes versioned prebuilt native binary tarballs per (arch, os).
  # Map the Nix system triple to the upstream platform key
  # (https://static.devin.ai/cli/<version>/manifest.json).
  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
    "x86_64-darwin"  = "x86_64-apple-darwin";
    "x86_64-linux"   = "x86_64-unknown-linux";
    "aarch64-linux"  = "aarch64-unknown-linux";
  };

  platform = platformMap.${stdenvNoCC.hostPlatform.system} or null;

  # SRI hashes for devin v${version}. Refresh: `make devin-update VERSION=...`
  hashes = {
    "aarch64-apple-darwin"  = "sha256-YEc5IhLOBz7eJyTYQkbMBN1HgRodHiCE7uclJwOUCsE=";
    "x86_64-apple-darwin"   = "sha256-Wc9FdvCzRfidskj5moJWLS7XoYn3zioyc/tTdKdJ56w=";
    "x86_64-unknown-linux"  = "sha256-LYKROWguA4zxIlEPEXDu49cGC8x+v5JEXLxdKMn7z6A=";
    "aarch64-unknown-linux" = "sha256-iB6DsN8G3VejBwBOKZQHwsN0XyiFRuCjOaZ/vr58tsA=";
  };
in

assert platform != null
  || throw "devin prebuilt unavailable for ${stdenvNoCC.hostPlatform.system}";

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "devin";
  inherit version;

  src = fetchurl {
    url = "https://static.devin.ai/cli/${finalAttrs.version}/devin-${finalAttrs.version}-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  sourceRoot = ".";

  outputs = [
    "out"
    "man"
    "doc"
  ];

  strictDeps = true;

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    installBin ./bin/devin
    installManPage ./share/man/man1/*.1

    mkdir -p $out/share/doc
    mv ./share/devin/docs/* $out/share/doc

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = with lib; {
    description = "Cognition Devin CLI — coding agent with Devin Cloud integration (prebuilt native binary)";
    homepage = "https://devin.ai/cli";
    license = licenses.unfree;
    mainProgram = "devin";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
