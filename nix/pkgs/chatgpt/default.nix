{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  graphite2,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  vulkan-loader,
  xz,
}:

let
  pname = "chatgpt";
  version = "26.917.61114";

  # OpenAI publishes the official Linux app as a Debian package. Keep the
  # latest artifact pinned so Nix can verify the mutable upstream URL.
  archives = {
    x86_64-linux = {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-e+ou/0pGq+DyjjnsZetublHJe7za2J0lq+W+xDGJVck=";
    };
    aarch64-linux = {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_arm64.deb";
      hash = "sha256-ZCHxeSNlgQcSHZ/hpj3qps1tnQZr4v2rlyuHTA3Vqxs=";
    };
  };

  archive =
    if builtins.hasAttr stdenv.hostPlatform.system archives then
      archives.${stdenv.hostPlatform.system}
    else
      throw "chatgpt: unsupported platform ${stdenv.hostPlatform.system}";

  runtimeDeps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libGL
    libnotify
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    systemd
    vulkan-loader
    xz
    libx11
    libx11.dev
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl { inherit (archive) url hash; };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = runtimeDeps;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  # autoPatchelfHook moves PT_INTERP beyond detect-libc's 2 KiB scan range.
  # Its process.report fallback then trips Electron's CFI and causes SIGILL.
  # Force @parcel/watcher to use its glibc backend on the patched binary.
  postPatch = ''
    grep -aFq 'const family = familySync();' usr/lib/chatgpt/resources/app.asar
    sed -i "s|const family = familySync();|const family = 'glibc'     ;|" \
      usr/lib/chatgpt/resources/app.asar
  '';

  dontBuild = true;
  dontConfigure = true;

  autoPatchelfIgnoreMissingDeps = [
    # Optional native modules for the upstream musl build. The glibc variants
    # shipped in the application bundle are used on NixOS.
    "libc.musl-x86_64.so.1"
    # Optional KDE integration loaded only when KDE is detected. Resolving
    # both Qt generations at once causes nixpkgs' Qt setup hooks to conflict.
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share/applications $out/share/pixmaps
    cp -r usr/lib/chatgpt $out/lib/

    ln -s $out/lib/chatgpt/ChatGPT $out/bin/chatgpt

    install -Dm644 usr/share/pixmaps/chatgpt.png $out/share/pixmaps/chatgpt.png
    install -Dm644 usr/share/applications/chatgpt.desktop $out/share/applications/chatgpt.desktop
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Official ChatGPT desktop app by OpenAI (Linux preview)";
    homepage = "https://chatgpt.com/download/";
    license = licenses.unfree;
    mainProgram = "chatgpt";
    platforms = builtins.attrNames archives;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
