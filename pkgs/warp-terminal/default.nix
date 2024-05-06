{ pkgs }:
let
  inherit (pkgs) stdenv;
in
stdenv.mkDerivation rec {
  pname = "warp-terminal";
  version = "0.2024.04.09.08.01";

  src = pkgs.fetchurl {
    url = "https://releases.warp.dev/stable/v${version}.stable_01/warp-terminal_${version}.stable.01_amd64.deb";
    hash = "sha256-8fgHxM1FRrNiDhoUCeMP+NZZ0fcaGroFLGN+19W6gEU=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    curl
    fontconfig
    zlib
  ] ++ [ stdenv.cc.cc.lib ];

  runtimeDependencies = with pkgs; [
    mesa
    libglvnd
    libxkbcommon
    vulkan-loader
    xdg-utils
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
  ] ++ [ stdenv.cc.libc ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp opt/warpdotdev/warp-terminal/* $out/bin
    cp -r usr/* $out/
    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/dev.warp.Warp.desktop \
      --replace "Exec=warp-terminal" "Exec=$out/bin/warp"
  '';
}
