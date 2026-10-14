{ lib, stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation {
  pname = "agent-safehouse";
  version = "0.12.0";
  src = fetchurl {
    url = "https://github.com/eugene1g/agent-safehouse/releases/download/v0.12.0/safehouse.sh";
    sha256 = "6298e4c8e8c0668bd2f79d8f8da7f605071c0b1f15328f263304783db6fe2829";
  };
  dontUnpack = true;
  dontBuild = true;
  dontFixup = true; # Preserve the release digest checked by the Pi installer.
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/safehouse
    chmod 755 $out/bin/safehouse
  '';
  meta = {
    description = "Native macOS sandbox for coding agents";
    homepage = "https://agent-safehouse.dev";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    mainProgram = "safehouse";
  };
}
