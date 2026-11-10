{ callPackage }:

# nixpkgs から brave が一時削除 (2026-11-03) され、master で再追加 (#584534,
# 2026-11-07) されたものが nixos-unstable に未到達の間の一時 vendor。
# make-brave.nix / brave.nix は nixpkgs master f9a6049 の
# pkgs/applications/networking/browsers/brave/ からそのままコピーしている。
# nixos-unstable に brave が戻ったら、このディレクトリを消して pkgs.brave に戻す。
callPackage ((import ./make-brave.nix) (import ./brave.nix // {
  optStem = "brave";
  fileStem = "brave-browser";
  appIdStem = "com.brave.Browser";
  darwinStem = "Brave Browser";
  changelogFile = "CHANGELOG_DESKTOP.md";
  homepage = "https://brave.com/";
  innerBinary = "brave";
})) { }
