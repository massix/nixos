{ unstable, ... }:
let
  inherit (unstable) lib stdenv;
  version = "3.5.0";

  src = unstable.fetchurl {
    url = "https://github.com/KRTirtho/spotube/releases/download/v${version}/spotube-linux-${version}-x86_64.tar.xz";
    name = "spotube-linux-${version}-x86_64.tar.xz";
    sha256 = "sha256-u0IAheA4Of3TtvY7d46dFcgRfLBGUrfsGIyY1K43KBo=";
  };

  buildInputs = with unstable; [
    atk
    cairo
    ffmpeg_4
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    jsoncpp
    libappindicator-gtk3
    libass
    libdbusmenu-gtk3
    libepoxy
    libnotify
    libsecret
    mpv
    pango
  ];
in
stdenv.mkDerivation {
  pname = "spotube";
  inherit version src buildInputs;

  nativeBuildInputs = with unstable; [
    makeWrapper
    patchelf
    stdenv.cc.cc.lib
    wrapGAppsHook
  ];

  unpackPhase = ''
    mkdir -p $out/dist
    tar -C $out/dist -xf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/spotube/

    install -Dm644 $out/dist/spotube.desktop $out/share/applications/
    install -Dm644 $out/dist/spotube-logo.png $out/share/icons/spotube/spotube-logo.png

    substituteInPlace $out/share/applications/spotube.desktop \
      --replace "Exec=/usr/bin/spotube" "Exec=$out/bin/spotube" \
      --replace "Icon=/usr/share/icons/spotube/spotube-logo.png" "Icon=$out/share/icons/spotube/spotube-logo.png"
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc ]} \
      $out/dist/spotube
    makeWrapper $out/dist/spotube $out/bin/spotube \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath buildInputs} \
      --suffix LD_LIBRARY_PATH : $out/dist/lib
  '';

  doCheck = false;
  dontBuild = true;
}
