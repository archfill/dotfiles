{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
}:

let
  version = "2.1.309";

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
    "darwin-arm64" = "sha256-Xq3AAJzc28DQblgRDXsrr4jO1giLHDOmCiEhf+QQYZw=";
    "darwin-x64"   = "sha256-IA4Nd1rlXAQNs7uNuN4+Iu/N29fgq/9atQ3RD2hTQl0=";
    "linux-x64"    = "sha256-TXBKiuy+A4r/owAPSYrhfBtPdTrdj6y4dkEgr/yZtlg=";
    "linux-arm64"  = "sha256-l5bdJomTN/aHc5oLOac1O2OfBio0Nqe5Qfzxmht1eps=";
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
  # /lib64 paths.
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
