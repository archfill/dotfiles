{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bubblewrap,
}:

let
  version = "0.154.0";

  # codex publishes a single prebuilt native binary per (arch, os).
  # Map the Nix system triple to the upstream tarball suffix.
  platformMap = {
    "aarch64-darwin" = "aarch64-apple-darwin";
    "x86_64-darwin"  = "x86_64-apple-darwin";
    "x86_64-linux"   = "x86_64-unknown-linux-musl";
    "aarch64-linux"  = "aarch64-unknown-linux-musl";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # SRI hashes for codex rust-v${version}. Refresh: `make codex-update VERSION=...`
  hashes = {
    "aarch64-apple-darwin"       = "sha256-NEMQoKWRwbGS4E/v8wQyGmmQfJSYuqrDMcp+FuvO+dc=";
    "x86_64-apple-darwin"        = "sha256-EhnIN9j4E7STpCTBJcADi12coWJ5vG0/5s4Dej4Ypuc=";
    "x86_64-unknown-linux-musl"  = "sha256-1+GLJZeujyQvXzHunpDe70jbye3WNNmGj7ZDXQjAfwI=";
    "aarch64-unknown-linux-musl" = "sha256-WDtI3zKAQhO9zTOMLlrbBrNDQIIfp1enJswKUk+jPCc=";
  };

  codeModeHostHashes = {
    "aarch64-apple-darwin"       = "sha256-UA7ioC6lmK5RkFLn19jiAdHbAZhvMMIU70FDZF3Ib60=";
    "x86_64-apple-darwin"        = "sha256-oPphQeWR9E3C2GpYnP55chIxe/ufo6bHMTHk27kzh/4=";
    "x86_64-unknown-linux-musl"  = "sha256-po33zKI8bafN4XVnfffeYcc6I0rdEzOhJUuG1kGvAfc=";
    "aarch64-unknown-linux-musl" = "sha256-IK76MCwgIrSW4ykRv5VKX3bH/XSca9ufvXEeMrZty/o=";
  };
in

assert platform != null
  || throw "codex prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation (finalAttrs: {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz";
    hash = hashes.${platform};
  };

  codeModeHostSrc = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-${platform}.tar.gz";
    hash = codeModeHostHashes.${platform};
  };

  # Each release asset is a single binary named `<artifact>-<platform>` with
  # no directory layout, so unpack both archives manually in buildPhase.
  dontUnpack = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    tar -xzf $src -C build
    tar -xzf $codeModeHostSrc -C build
    mv "build/codex-${platform}" build/codex
    mv "build/codex-code-mode-host-${platform}" build/codex-code-mode-host
    chmod u+w,+x build/codex build/codex-code-mode-host
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 build/codex $out/bin/codex
    install -Dm555 build/codex-code-mode-host $out/bin/codex-code-mode-host

    # codex ships an in-place auto-updater that would rewrite the
    # /nix/store binary; disable it so Nix owns the version pinned here.
    # Linux needs bubblewrap on PATH for codex's sandboxing (landlock/seccomp).
    wrapProgram $out/bin/codex \
      --set DISABLE_AUTOUPDATER 1 \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
      ''}
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI — lightweight AI coding agent (prebuilt native binary)";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    mainProgram = "codex";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
