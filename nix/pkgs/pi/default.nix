{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

let
  version = "0.85.1";

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

  # Official GitHub release binaries. Refresh with `make pi-update`.
  hashes = {
    "aarch64-darwin" = "sha256-1fcOPAz3OY6sI5/QJh7gdNmLe6f2tD/jYX8FLtW3nQY=";
    "x86_64-darwin" = "sha256-rbkYuEViXxhNi+pAjVXqyvIaqHI4eTwPW087lze85is=";
    "x86_64-linux" = "sha256-SU5Jj0fXTSH0CzOG9qXpIaPUlTGhacq1W72soOof4lo=";
    "aarch64-linux" = "sha256-BC0grohe5POxAoFfMoC5YsN3sun7RN5AN5CMxTDq5NQ=";
  };
in

assert platform != null
  || throw "pi prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "pi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-${platform.os}-${platform.arch}.tar.gz";
    hash = hashes.${stdenv.hostPlatform.system};
  };

  sourceRoot = "pi";

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  # The bundled clipboard native addon links against libgcc_s on Linux.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/pi $out/bin
    cp -R . $out/libexec/pi/
    chmod +x $out/libexec/pi/pi

    # Nix owns the version; skip network update checks and pin package dir
    # (store paths can tokenize poorly for Pi's package installer).
    makeWrapper $out/libexec/pi/pi $out/bin/pi \
      --set PI_SKIP_VERSION_CHECK 1 \
      --set PI_PACKAGE_DIR $out/libexec/pi

    runHook postInstall
  '';

  # Preserve the bundled Bun runtime / native assets as shipped.
  dontStrip = true;

  meta = with lib; {
    description = "Minimal terminal coding agent harness (prebuilt binary)";
    homepage = "https://pi.dev/";
    license = licenses.mit;
    mainProgram = "pi";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
