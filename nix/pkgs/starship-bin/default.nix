{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "1.26.0";

  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  hashes = {
    "aarch64-apple-darwin" = "sha256-xAsnsR9YBBHgaPL6bBvngwo4fAvEepTR038ysFTFNh0=";
  };
in

assert platform != null
  || throw "starship-bin prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "starship";
  inherit version;

  src = fetchurl {
    url = "https://github.com/starship/starship/releases/download/v${version}/starship-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    tar -xzf $src
    install -Dm555 starship $out/bin/starship
    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-shell prompt for astronauts";
    homepage = "https://starship.rs";
    license = licenses.isc;
    mainProgram = "starship";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
