{ unstable, ... }:
unstable.stdenvNoCC.mkDerivation rec {
  pname = "codeium-ls";
  version = "1.8.16";

  nativeBuildInputs = with unstable; [ autoPatchelfHook ];

  src = builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    sha256 = "sha256:0qfcmx5ymm20nq2dfw2g285pjw1bzkxyzn3wndgqqqlq23kyzggn";
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
