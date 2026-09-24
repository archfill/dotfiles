{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
}:

let
  version = "2.1.281";

  # Anthropic 公式 download service (native installer と同じ配布物)。
  # 単一の prebuilt native binary が platform 名ごとに置かれている。
  # Linux は glibc 版を使用し autoPatchelfHook で NixOS 対応する
  # (musl 版は静的リンクではなく musl loader 要求のため不採用)。
  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin"  = "darwin-x64";
    "x86_64-linux"   = "linux-x64";
    "aarch64-linux"  = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  # SRI hashes for claude-code v${version}. Refresh: `make claude-update VERSION=...`
  hashes = {
    "darwin-arm64" = "sha256-qSKYH287VaJR75+duqBiGl+Zy8tcpn+KeXR2zPyD9iY=";
    "darwin-x64"   = "sha256-qTVcuw0pHOlI789hpu85dAFnL2T6Xl5nvKCS/tbNkIg=";
    "linux-x64"    = "sha256-Vv49qIRYRl+yfX6Smd3bP+rVV1D7nC3nlfIzte6m3OE=";
    "linux-arm64"  = "sha256-3SezZDik/tFnDNKbrS/aanO2KLbaVUQ+XC9kf+btMo8=";
  };
in

assert platform != null
  || throw "claude-code prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${version}/${platform}/claude";
    hash = hashes.${platform};
  };

  dontUnpack = true;
  dontConfigure = true;

  # The bundled Bun runtime links glibc / libstdc++ dynamically on Linux.
  # Patch interpreter and rpath for Nix/NixOS instead of relying on host
  # /lib64 paths (same approach as cursor-agent).
  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # ~200MB の Bun 単体バイナリ。strip は時間がかかる上に壊す危険があるため
  # 無効化 (公式配布物をそのまま使う)。
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 $src $out/bin/claude

    # claude は in-place auto-updater を持ち /nix/store のバイナリを
    # 書き換えようとするため無効化。バージョンは Nix で固定し、
    # 更新は `make claude-update` または `make nix-update` で行う。
    wrapProgram $out/bin/claude --set DISABLE_AUTOUPDATER 1
    runHook postInstall
  '';

  meta = with lib; {
    description = "Anthropic Claude Code CLI — agentic coding assistant (prebuilt native binary)";
    homepage = "https://code.claude.com";
    license = licenses.unfree;
    mainProgram = "claude";
    platforms = builtins.attrNames platformMap;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
