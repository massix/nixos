{ pkgs }:
let
  inherit (pkgs) lib stdenv;
  version = "3.4.0";

  src = pkgs.fetchurl {
    url = "https://github.com/KRTirtho/spotube/releases/download/v3.4.0/spotube-linux-${version}-x86_64.tar.xz";
    name = "spotube-linux-${version}-x86_64.tar.xz";
    sha256 = "sha256-vTK3aWM1Aly3yCNEpQS0y+4dHTjsn2VWJAI9Sk518rg=";
  };
in
stdenv.mkDerivation {
  pname = "spotube";
  inherit version src;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    patchelf
    wrapGAppsHook
  ];

  buildInputs = with pkgs; [
    mpv-unwrapped
    libappindicator-gtk3
    libsecret
    jsoncpp
    libnotify
    libass
    gtk3
    glib
    cairo
    pango
    ffmpeg_4
    harfbuzz
    atk
    libepoxy
    gdk-pixbuf
    libdbusmenu-gtk3
    fontconfig
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
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/dist/spotube
    makeWrapper $out/dist/spotube $out/bin/spotube \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [
        pkgs.jsoncpp
        pkgs.libnotify
        pkgs.libass
        pkgs.pango
        pkgs.cairo
        pkgs.mpv-unwrapped
        pkgs.glib
        pkgs.gtk3
        pkgs.ffmpeg_4
        pkgs.libsecret
        pkgs.libappindicator-gtk3
        pkgs.harfbuzz
        pkgs.atk
        pkgs.libepoxy
        pkgs.gdk-pixbuf
        pkgs.libdbusmenu-gtk3
        pkgs.fontconfig
      ]} \
      --suffix LD_LIBRARY_PATH : "$out/dist/lib" \
      --prefix LD_LIBRARY_PATH : "${stdenv.cc.cc.lib}/lib"
  '';

  doCheck = false;
}

