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
  gtk3,
  libdrm,
  libGL,
  libcap_ng,
  libnotify,
  libseccomp,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  util-linux,
  vulkan-loader,
}:

let
  pname = "claude-desktop";
  version = "5.11492.2";

  # Anthropic publishes the official Linux app through an apt repository. The
  # versioned pool URLs are immutable, so pin them directly.
  archives = {
    x86_64-linux = {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_5.11492.2_amd64.deb";
      hash = "sha256-0QlE+lZjuZdADPZsXHc4/WrPZU+KrqyluZTrFHqms18=";
    };
    aarch64-linux = {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_5.11492.2_arm64.deb";
      hash = "sha256-IItjfpUfU9RiHW7cFZjCG9pmRgLtQJrTe2c1AhvphA4=";
    };
  };

  archive =
    if builtins.hasAttr stdenv.hostPlatform.system archives then
      archives.${stdenv.hostPlatform.system}
    else
      throw "claude-desktop: unsupported platform ${stdenv.hostPlatform.system}";

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
    gtk3
    libdrm
    libGL
    libcap_ng # bundled virtiofsd
    libnotify
    libseccomp # bundled virtiofsd
    libsecret
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    util-linux.lib # libuuid
    vulkan-loader
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
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

  # Chromium dlopen()s these (EGL/GL/Vulkan, libsecret, notifications) instead
  # of linking them, so autoPatchelf must add them to the RPATH explicitly.
  runtimeDependencies = [
    (lib.getLib libGL)
    (lib.getLib vulkan-loader)
    (lib.getLib libsecret)
    (lib.getLib libnotify)
    (lib.getLib systemd)
    (lib.getLib pipewire)
  ];

  unpackPhase = ''
    runHook preUnpack
    # chrome-sandbox is setuid in the .deb, which the Nix sandbox cannot apply
    # (and a store path could never keep anyway), so extract without modes.
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share/applications $out/share/mime/packages
    cp -r usr/lib/claude-desktop $out/lib/

    ln -s $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop

    cp -r usr/share/icons $out/share/icons

    install -Dm644 usr/share/applications/com.anthropic.Claude.desktop \
      $out/share/applications/com.anthropic.Claude.desktop
    substituteInPlace $out/share/applications/com.anthropic.Claude.desktop \
      --replace-fail 'Exec=claude-desktop' "Exec=$out/bin/claude-desktop"

    install -Dm644 usr/lib/claude-desktop/resources/linux-mime/com.anthropic.Claude.xml \
      $out/share/mime/packages/com.anthropic.Claude.xml

    # The upstream postinst also wires up the GNOME search provider, an
    # AppArmor profile and apt settings. None of that applies to NixOS, so it
    # is intentionally not reproduced here.

    runHook postInstall
  '';

  meta = with lib; {
    description = "Official Claude desktop app by Anthropic (Linux beta)";
    homepage = "https://claude.com/download";
    license = licenses.unfree;
    mainProgram = "claude-desktop";
    platforms = builtins.attrNames archives;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
