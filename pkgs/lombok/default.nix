{ unstable, ... }:
let
  inherit (unstable) stdenv;
in
stdenv.mkDerivation {
  pname = "lombok";
  version = "1.18.30";

  src = unstable.fetchurl {
    url = "https://projectlombok.org/downloads/lombok.jar";
    hash = "sha256-1+4SLu4erutFGCqJ/zb8LdCGhY0bL1S2Fcb+97odYBI=";
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
