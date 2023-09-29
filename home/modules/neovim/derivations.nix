{ stdenv, pkgs, lib }:
let
  inherit (lib) stdenvNoCC;
in {
  codeiumls = stdenvNoCC.mkDerivation rec {
    pname = "codeium-ls";
    version = "1.2.90";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    src = builtins.fetchurl {
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
      sha256 = "sha256:0mb1b9jflzhr40n2zhmd4d1s9n1siq89bghn295arhl7grk41mwy";
    };

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      gunzip -d -c -f $src > $out/bin/language_server_linux_x64
      chmod +x $out/bin/language_server_linux_x64
    '';
  };
}
