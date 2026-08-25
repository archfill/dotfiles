{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

let
  version = "0.84.3";

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
    "aarch64-darwin" = "sha256-ASDJ+Z6gX+gB5ufCydkd1lY2VjyggDcRs3ufMpINS2M=";
    "x86_64-darwin" = "sha256-uZcGsyVPqvNpU5Xstpy34fTUgivT+DLm0fJjbYlra94=";
    "x86_64-linux" = "sha256-b4u2fCG8a4qKEG01T1bX/UoZCjzYrToy20X20oGl0Ag=";
    "aarch64-linux" = "sha256-581IzW9ktwjoRZqJCIKxAHMy9ua4dv4f1cUgOr0K3bc=";
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
