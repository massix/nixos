{ pkgs, ... }:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "codeium-ls";
  version = "1.4.22";

  nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

  src = builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    sha256 = "sha256:0sqj00if3d3n4yni9rfllszhfzczawv1d0yxxfkf2jvidj49wfwr";
  };

  dontBuild = true;
  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    gunzip -d -c -f $src > $out/bin/codeium-ls_server_linux_x64
    chmod +x $out/bin/codeium-ls_server_linux_x64
  '';
}
