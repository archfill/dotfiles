{ pkgs }:

# nixpkgs の replaceDependencies を darwin で使える形にしたもの。
# ストアパスを書き換えると Mach-O の署名が壊れ、arm64 では起動時に kill される
# (exit 137)。replaceDirectDependencies の書き換えのあとに、署名が壊れた
# Mach-O だけを identifier / entitlements などを保ったまま ad-hoc 署名し直す。
# /usr/bin/codesign を使うため、Nix の sandbox が無効な環境 (Determinate Nix の
# darwin 既定) が前提。
let
  replaceDirectDependencies = { drv, replacements ? [ ] }:
    if replacements == [ ] then drv else
    (pkgs.replaceDirectDependencies { inherit drv replacements; }).overrideAttrs (old: {
      buildCommand = old.buildCommand + ''
        find "$out" -type f -print0 | while IFS= read -r -d "" f; do
          case "$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')" in
            cffaedfe|cafebabe) ;;
            *) continue ;;
          esac
          # 元から署名の無いもの (dSYM など) は触らない
          if ! err=$(/usr/bin/codesign -v "$f" 2>&1) \
            && [[ "$err" != *"not signed at all"* ]]; then
            chmod u+w "$f" "$(dirname "$f")"
            /usr/bin/codesign -f -s - \
              --preserve-metadata=identifier,entitlements,flags,runtime "$f"
          fi
        done
      '';
    });
in
pkgs.replaceDependencies.override { inherit replaceDirectDependencies; }
