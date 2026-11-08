{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  autoPatchelfHook,
}:

let
  # Namespace (namespace.so) 公式 CLI の GitHub release を固定する。nixpkgs の
  # `nsc` は NATS の別ツールなので使えない。`nsc version update` による
  # in-place update は /nix/store と衝突するため使わず、更新は version と
  # hash を書き換える。
  version = "0.0.588";
  platform = {
    "aarch64-darwin" = "darwin_arm64";
    "x86_64-linux" = "linux_amd64";
    "aarch64-linux" = "linux_arm64";
  };
  hashes = {
    "aarch64-darwin" = "sha256-1NvthjOFYQaDchDkmkInbV3AADMWd0l1z8FnnvRAWPw=";
    "x86_64-linux" = "sha256-ukbRDcsxyv9J7aVZfGII6JF8SQoGAkgNbeEnaI8oehA=";
    "aarch64-linux" = "sha256-J11bv7ZPEI6H3Redliq/v0EoTZATokKd2djA5AvQCyA=";
  };
  system = stdenvNoCC.hostPlatform.system;
in
stdenvNoCC.mkDerivation {
  pname = "nsc";
  inherit version;

  src = fetchurl {
    url = "https://github.com/namespacelabs/foundation/releases/download/v${version}/nsc_${version}_${
      platform.${system} or (throw "nsc prebuilt unavailable for ${system}")
    }.tar.gz";
    hash = hashes.${system};
  };

  sourceRoot = ".";
  dontBuild = true;
  strictDeps = true;

  nativeBuildInputs = [ installShellFiles ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 nsc "$out/bin/nsc"
    # `nsc docker login` / Bazel 連携が PATH 上に要求する credential helper。
    install -Dm755 docker-credential-nsc "$out/bin/docker-credential-nsc"
    install -Dm755 bazel-credential-nsc "$out/bin/bazel-credential-nsc"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Namespace (namespace.so) cloud CLI";
    homepage = "https://namespace.so/docs/reference/cli/installation";
    license = licenses.asl20;
    mainProgram = "nsc";
    platforms = builtins.attrNames platform;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
