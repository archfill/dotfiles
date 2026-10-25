{ bun, fetchurl, stdenv }:

# nixpkgs の bun 1.4.2 を公式 prebuilt 1.4.4 に差し替える一時 pin。
# nixos-unstable の bun が 1.4.4 以上になったら、
# このディレクトリを消して利用側を pkgs.bun に戻す。
let
  version = "1.4.4";
  sources = {
    aarch64-darwin = {
      asset = "bun-darwin-aarch64";
      hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
    };
    x86_64-linux = {
      asset = "bun-linux-x64";
      hash = "sha256-v4zL+ysLgBWeD5ptFcVTF63YB3U028YTCj7bUvzLOVw=";
    };
    aarch64-linux = {
      asset = "bun-linux-aarch64";
      hash = "sha256-uqa7NvUdblhWHgK76oJQOKnfRU9nPW13bou/hvjHhQ4=";
    };
  };
  source = sources.${stdenv.hostPlatform.system}
    or (throw "bun ${version}: unsupported system ${stdenv.hostPlatform.system}");
in
bun.overrideAttrs (_: {
  inherit version;
  src = fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/${source.asset}.zip";
    inherit (source) hash;
  };
})
