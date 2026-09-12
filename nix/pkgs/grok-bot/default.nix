{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeShellWrapper,
  wrapGAppsHook3,

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
  libgbm,
  libGL,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
}:

let
  version = "0.47.0";
  buildId = "c1e7d7a46549956d25f53e9c0b9f59666e03aa3a";
  downloadBase = "https://downloads.cursor.com/grokbot/stable";

  # Shared libraries loaded with dlopen() by the bundled Chromium runtime.
  runtimeLibs = [
    libglvnd
    libGL
    libgbm
    libdrm
    vulkan-loader
    wayland
    libxkbcommon
    libpulseaudio
    libsecret
    libnotify
    (lib.getLib systemd)
  ];
in

assert stdenv.hostPlatform.system == "x86_64-linux"
  || throw "grok-bot prebuilt unavailable for ${stdenv.hostPlatform.system}";

stdenv.mkDerivation (finalAttrs: {
  pname = "grok-bot";
  inherit version;

  # The Linux stable feed advertises an AppImage zsync URL, while the
  # corresponding official .deb is available from the same build namespace.
  debFile = "grok-bot_${finalAttrs.version}_amd64.deb";

  src = fetchurl {
    url = "${downloadBase}/${buildId}/linux/x64/${finalAttrs.debFile}";
    hash = "sha256-EcoPUaU1uXr1GjUq35wPns0uGwQwpprpRRtoinoGWAg=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
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
    libuuid
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
  ] ++ runtimeLibs;

  # Keep dlopen()ed libraries reachable via RPATH.
  runtimeDependencies = runtimeLibs;

  # Preserve the vendor-shipped Electron and native modules.
  dontStrip = true;

  # The wrapper below needs to combine GApps arguments with the Electron
  # flags, so do not let wrapGAppsHook3 replace it automatically.
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/grok-bot"
    cp -r "opt/Grok Bot/." "$out/share/grok-bot/"

    # chrome-sandbox needs setuid root, which the Nix store cannot express.
    # The wrapper below also disables the broken sandboxed webview in the
    # current upstream Electron build (see the Nix packaging notes).
    rm -f "$out/share/grok-bot/chrome-sandbox"

    found_icon=""
    for extension in png svg; do
      for icon in usr/share/icons/hicolor/*/apps/{grok-bot,sand}."$extension"; do
        [ -f "$icon" ] || continue
        relative_icon="''${icon#usr/share/icons/hicolor/}"
        icon_size="''${relative_icon%%/*}"
        install -Dm644 "$icon" \
          "$out/share/icons/hicolor/$icon_size/apps/grok-bot.$extension"
        found_icon=1
      done
    done
    if [ -z "$found_icon" ]; then
      echo "error: no Grok Bot icon found in the .deb" >&2
      exit 1
    fi

    if [ -f usr/share/applications/grok-bot.desktop ]; then
      desktop=usr/share/applications/grok-bot.desktop
    else
      desktop=usr/share/applications/sand.desktop
    fi
    install -Dm644 "$desktop" "$out/share/applications/grok-bot.desktop"
    sed -i \
      -e "s#^Exec=.*#Exec=$out/bin/grok-bot %U#" \
      -e 's/^Icon=.*/Icon=grok-bot/' \
      "$out/share/applications/grok-bot.desktop"

    runHook postInstall
  '';

  preFixup = ''
    if [ -x "$out/share/grok-bot/grok-bot" ]; then
      upstreamExecutable="$out/share/grok-bot/grok-bot"
    elif [ -x "$out/share/grok-bot/sand" ]; then
      upstreamExecutable="$out/share/grok-bot/sand"
    else
      echo "error: Grok Bot executable not found" >&2
      exit 1
    fi

    makeShellWrapper "$upstreamExecutable" "$out/bin/grok-bot" \
      "''${gappsWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --set-default CHROME_DESKTOP grok-bot.desktop \
      --add-flags "--no-sandbox" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    # Keep the compatibility name used by older releases and sand:// URLs.
    ln -s "$out/bin/grok-bot" "$out/bin/sand"
  '';

  passthru.updateScript = ../../../bin/grok-bot-update.sh;

  meta = {
    description = "Grok Bot desktop agent";
    homepage = "https://x.ai/bot";
    downloadPage = "https://x.ai/bot";
    license = lib.licenses.unfree;
    mainProgram = "grok-bot";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
