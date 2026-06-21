{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "win32yank";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip";
    hash = "sha256-JHyaBblDh6iEtJ09sT+AaxZ338OAIPlV9xm+aQImDNY=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 win32yank.exe "$out/bin/win32yank.exe"
    ln -s "$out/bin/win32yank.exe" "$out/bin/win32yank"
    runHook postInstall
  '';

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  meta = with lib; {
    description = "Clipboard tool for Neovim running inside WSL";
    homepage = "https://github.com/equalsraf/win32yank";
    license = licenses.mit;
    mainProgram = "win32yank";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
