{ pkgs }:
let
  inherit (pkgs) stdenv;
in
stdenv.mkDerivation {
  pname = "jdtls-helix-fixed";
  version = "0.0.1";

  src = pkgs.fetchurl {
    url = "https://github.com/theli-ua/eclipse.jdt.ls/releases/download/java.apply.WorkspaceEdit/jdtls-helix.tar.xz";
    hash = "sha256-LRej0qCefaMmkm1CtfOZEw+IOpjYheTezdwr9ax41TM=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  unpackPhase = ''
    mkdir -p ./jdtls
    tar -xf $src -C ./jdtls
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ./jdtls $out/jdtls
    mkdir -p $out/bin
    makeWrapper ${pkgs.python3Minimal}/bin/python $out/bin/jdtls \
      --prefix PATH : ${pkgs.jdk}/bin \
      --set JAVA_HOME ${pkgs.jdk} \
      --add-flags $out/jdtls/bin/jdtls
  '';
}
