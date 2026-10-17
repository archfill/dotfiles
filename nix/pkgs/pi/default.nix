{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libxcb,
}:

let
  version = "1.3.0";

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
    "aarch64-darwin" = "sha256-H5rmHN6uBN1oyvGh6KuOybKSBi9syzJS4KnL6TtbFvE=";
    "x86_64-darwin" = "sha256-n/Vi4uQ59Qlxsfa9m2KzCUZgDZ6bqk6hljXPYwpVMGY=";
    "x86_64-linux" = "sha256-JPW+Motm1No2h2KWmJUBl09Dq4Q0+7V8NcUjo+pQXe0=";
    "aarch64-linux" = "sha256-f9LqFPyjkOv59HQ4uq7wfEs9E9t8yORZgxEYORt+pls=";
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

  # The bundled native addons link against libgcc_s (clipboard) and
  # libxcb (linux-platform-x11.node) on Linux.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    libxcb
  ];

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
