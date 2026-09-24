{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  versionCheckHook,
}:

let
  version = "3000.11.3";

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
    "aarch64-apple-darwin"  = "sha256-wIzD81B9EDJGuMYBpYT8xxn9d/bMEPJsyQ6fQYZkDfI=";
    "x86_64-apple-darwin"   = "sha256-WU+JtrDQPf/sTqvHVBBORHHMQ6AUohZOL919DXUtAQA=";
    "x86_64-unknown-linux"  = "sha256-g7OxE8Ab8qPp4QDbCNd+awhoBqd1TwkeIIMb3+IVFX4=";
    "aarch64-unknown-linux" = "sha256-IaLXqN6meYcGfN5+s/5xk6SNqo+MPVDUFMYDxKK2fxU=";
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
