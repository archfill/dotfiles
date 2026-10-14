{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  autoPatchelfHook,
}:

let
  version = "1.0.52";

  # https://x.ai/cli/stable の stable ポインタを固定する。更新は
  # `make grok-build-update` (bin/grok-build-update.sh) で行い、CLI 自身の
  # in-place update は使わない。nixpkgs の grok-build も同様の構成だが
  # stable 追従の速さを優先して自前 pin する。
  platform = {
    "aarch64-darwin" = "macos-aarch64";
    "x86_64-linux" = "linux-x86_64";
    "aarch64-linux" = "linux-aarch64";
  };

  hashes = {
    "aarch64-darwin" = "sha256-wsqpiV3XYyl6dej7YHfhddnFMExTkD5Sz/iJGhOEu7k=";
    "x86_64-linux" = "sha256-FmhBSwR+EFCpbSX+F9/D7+YxkPv2bYzBw96GM8r1DRE=";
    "aarch64-linux" = "sha256-/DJBC2iDwVo5ufM+wEpr+30HCzg+XbrX77xIx4flBQ0=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "grok-build";
  inherit version;

  src = fetchurl {
    url = "https://x.ai/cli/grok-${version}-${platform.${stdenvNoCC.hostPlatform.system} or (throw "grok-build prebuilt unavailable for ${stdenvNoCC.hostPlatform.system}")}";
    hash = hashes.${stdenvNoCC.hostPlatform.system};
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
