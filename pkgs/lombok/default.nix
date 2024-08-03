{ pkgs }:
let
  inherit (pkgs) stdenv;
in
stdenv.mkDerivation {
  pname = "lombok";
  version = "1.18.34";

  src = pkgs.fetchurl {
    url = "https://projectlombok.org/downloads/lombok.jar";
    hash = "sha256-wn1rKv9WJB0bB/y8xrGDcJ5rQyyA9zdO6x2CPobUuBo=";
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
