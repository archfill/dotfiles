{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  autoPatchelfHook,
}:

let
  # https://x.ai/cli/stable の stable ポインタを固定する。更新は
  # `make grok-build-update` (bin/grok-build-update.sh) で行い、CLI 自身の
  # in-place update は使わない。nixpkgs の grok-build も同様の構成だが
  # stable 追従の速さを優先して自前 pin する。
  platform = {
    "aarch64-darwin" = "macos-aarch64";
    "x86_64-linux" = "linux-x86_64";
    "aarch64-linux" = "linux-aarch64";
  };

  # Per-system pins: each host refreshes only its own entry with
  # `make grok-build-update`, so other systems may lag behind.
  sources = {
    "aarch64-darwin" = {
      version = "1.0.70";
      hash = "sha256-XIpoglG/YeNTcLgotqNTsKIPzD9kAA3oqR1CYDnynOw=";
    };
    "x86_64-linux" = {
      version = "1.0.67";
      hash = "sha256-zjOxop43kB9W/lmRbNp6EUnm/TdxGPkY6Q2J+au1KlE=";
    };
    "aarch64-linux" = {
      version = "1.0.62";
      hash = "sha256-C4CKIglyh4jS43w06hhG1GC0FSip/H7cdpi5597BL+E=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "grok-build prebuilt unavailable for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "grok-build";
  inherit (source) version;

  src = fetchurl {
    url = "https://x.ai/cli/grok-${source.version}-${platform.${stdenvNoCC.hostPlatform.system}}";
    inherit (source) hash;
  };

  dontUnpack = true;
  dontBuild = true;
  strictDeps = true;

  nativeBuildInputs = [ installShellFiles ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/grok"
    # canonical 名 `agent` は Grok Build 側が専有する (Cursor CLI とは共用しない)
    ln -s grok "$out/bin/agent"

    ${lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
      installShellCompletion --cmd grok \
        --bash <("$out/bin/grok" completions bash) \
        --fish <("$out/bin/grok" completions fish) \
        --zsh <("$out/bin/grok" completions zsh)
    ''}

    runHook postInstall
  '';

  meta = with lib; {
    description = "xAI Grok Build coding agent CLI";
    homepage = "https://docs.x.ai/build/overview";
    license = licenses.unfreeRedistributable;
    mainProgram = "grok";
    platforms = builtins.attrNames platform;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
