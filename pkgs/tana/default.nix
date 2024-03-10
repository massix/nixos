{ stable, unstable }:
let
  inherit (unstable) stdenv xorg lib;
  xorgLibs = with xorg; [
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
  ];
  glLibs = [
    stable.mesa
    unstable.libglvnd
  ];
  libs = with unstable; [
    alsa-lib
    at-spi2-atk
    atkmm
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
  ];
  buildInputs = xorgLibs ++ glLibs ++ libs;
  version = "1.0.15";
  pname = "tana";
in
stdenv.mkDerivation {
  inherit version buildInputs pname;

  src = stable.fetchurl {
    url = "https://github.com/tanainc/tana-desktop-releases/releases/download/v${version}/tana_${version}_amd64.deb";
    hash = "sha256-94AyAwNFN5FCol97US1Pv8IN1+WMRA3St9kL2w+9FJU=";
  };

  nativeBuildInputs = with stable; [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  # Needed for zygote
  runtimeDependencies = [
    stable.systemd
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out
    rm $out/bin/tana
    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/tana.desktop \
      --replace "Exec=tana" "Exec=$out/bin/tana" \
      --replace "Name=tana" "Name=Tana"
    makeWrapper $out/lib/tana/Tana $out/bin/tana \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath glLibs} \
      --suffix LD_LIBRARY_PATH : $out/lib/tana
  '';

  meta.mainProgram = pname;
}
