{ pkgs }:
let
  inherit (pkgs) stdenv;
in
stdenv.mkDerivation {
  pname = "lombok";
  version = "1.18.34";

  src = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok.jar";
    hash = "sha256-c7awW2otNltwC6sI0w+U3p0zZJC8Cszlthgf70jL8Y4=";
  };

  dontBuild = true;
  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/lombok.jar
  '';
}
