{ pkgs }:
let
  inherit (pkgs) stdenv lib;
in
stdenv.mkDerivation rec {
  pname = "warp-terminal";
  version = "0.2024.06.25.08.02";

  # https://releases.warp.dev/stable/v0.2024.06.25.08.02.stable_01/warp-terminal_0.2024.06.25.08.02.stable.01_amd64.deb
  src = pkgs.fetchurl {
    url = "https://releases.warp.dev/stable/v${version}.stable_01/warp-terminal_${version}.stable.01_amd64.deb";
    hash = "sha256-bNKDSiGHwogtbiroG61EO9cAKLJ+RFnXDTzI7eJkapQ=";
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
    curl
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
