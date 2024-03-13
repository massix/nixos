{ unstable, ... }:
let
  inherit (unstable) stdenv;
  pkgs = unstable;
in
stdenv.mkDerivation rec {
  pname = "warp-terminal";
  version = "0.2024.03.05.08.02";

  src = pkgs.fetchurl {
    url = "https://releases.warp.dev/stable/v${version}.stable_01/warp-terminal_${version}.stable.01_amd64.deb";
    hash = "sha256-I2knl/WbZ3DkfiVqETOrrSdyFMzHVtVHu25chWNNnGo=";
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
