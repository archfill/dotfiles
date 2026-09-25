{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
}:

# Time Machine から依存ディレクトリ (node_modules / target / .venv 等) を除外する。
# 実行時に macOS 標準の mdfind / tmutil / BSD stat 等を PATH から呼ぶ。
# wrapProgram で包むと `asimov doctor` が wrapper と実体を別 install と誤認するため
# 包まず、launchd 側 (hosts/*/home.nix) で PATH を明示する。
stdenvNoCC.mkDerivation {
  pname = "asimov";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "AsimovMac";
    repo = "asimov";
    tag = "v0.12.0";
    hash = "sha256-w3mmSu56vtiqoet6P2OFWcUVCdME2ckMTj3k7PRzw8I=";
  };

  # patchShebangs が #!/usr/bin/env bash を Nix の bash に置き換えるため。
  buildInputs = [ bash ];

  # upstream scripts/install.sh と同じレイアウト。bin/asimov は
  # <prefix>/libexec/asimov と <prefix>/share/asimov を自動検出する。
  installPhase = ''
    runHook preInstall
    install -Dm555 bin/asimov "$out/bin/asimov"
    mkdir -p "$out/libexec/asimov" "$out/share/asimov"
    cp -a lib/asimov/. "$out/libexec/asimov/"
    cp -a data/. "$out/share/asimov/"
    runHook postInstall
  '';

  dontConfigure = true;
  dontBuild = true;

  meta = with lib; {
    description = "Exclude development dependencies from Apple Time Machine backups";
    homepage = "https://github.com/AsimovMac/asimov";
    license = licenses.mit;
    mainProgram = "asimov";
    platforms = platforms.darwin;
  };
}
