{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "orca-ide";
  version = "1.4.159";
  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-GaK6tQqn1lydFrnl6F6JJC3+fkN+wxA4Z0lE58HuAQs=";
  };
  extracted = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${extracted}/orca-ide.desktop \
      $out/share/applications/orca-ide.desktop
    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=orca-ide'
    install -Dm444 ${extracted}/resources/app.asar.unpacked/resources/icon.png \
      $out/share/icons/hicolor/512x512/apps/orca-ide.png
  '';

  meta = with lib; {
    description = "Orca — worktree-native desktop environment for AI coding agents";
    homepage = "https://github.com/stablyai/orca";
    license = licenses.mit;
    mainProgram = "orca-ide";
    platforms = platforms.linux;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
