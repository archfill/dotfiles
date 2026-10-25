{ pkgs }:

# HTTP2Shell (CVE-2026-111497): brotli 1.2.0 の decoder に OOB write がある。
# nixpkgs の修正 (1.2.1) は staging 止まりで、overlay で上げると curl / freetype /
# nix / qtbase 以下 (rustc / ghc / ffmpeg / qemu 等) が全部再ビルドになるため、
# closure 内の brotli (out / lib) だけを graft で差し替える。
# NixOS / nix-darwin の system.replaceDependencies.replacements と
# flake.nix の agent-runtime で共有する。
# python brotli (USE_SYSTEM_BROTLI) や nodejs_24 (--shared-brotli) もこれで直る。
# nodejs_22 / nodejs_26 は nixpkgs 側でパッチ済みの別 brotli を使うので対象外。
# (nixpkgs の brotli が 1.2.1 以上になったら削除)
let
  brotliFixed = pkgs.brotli.overrideAttrs (_: {
    version = "1.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "brotli";
      tag = "v1.2.1";
      hash = "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=";
    };
  });
in
map (output: {
  oldDependency = pkgs.brotli.${output};
  newDependency = brotliFixed.${output};
}) [ "out" "lib" ]
