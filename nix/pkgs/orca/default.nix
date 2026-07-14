{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.4.139";
in
appimageTools.wrapType2 {
  pname = "orca-ide";
  inherit version;

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-NauNw7FCdUTqH8Z/jFSjN/C5tNMVq+5O7dkwYAa0P7I=";
  };

  meta = with lib; {
    description = "Orca — worktree-native desktop environment for AI coding agents";
    homepage = "https://github.com/stablyai/orca";
    license = licenses.mit;
    mainProgram = "orca-ide";
    platforms = platforms.linux;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
