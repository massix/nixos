{ unstable, ... }:
let
  inherit (unstable) lib;
  version = "1.8.30";
  fetchCodeium = version: hash: builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    sha256 = hash;
  };
in
unstable.stdenvNoCC.mkDerivation {
  pname = "codeium-ls";
  inherit version;

  nativeBuildInputs = with unstable; [ autoPatchelfHook ];

  src = fetchCodeium version "sha256:08li0a4fdsq7z3ar9yw45ffp6h1qxq7dbpmdyw9rnsr9c6gk01hq";

  dontBuild = true;
  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gunzip -d -c -f $src > $out/bin/codeium-ls_server_linux_x64
    chmod +x $out/bin/codeium-ls_server_linux_x64
    runHook postInstall
  '';

  meta = with lib; {
    description = "Codeium Language Server";
    homepage = "https://github.com/Exafunction/codeium";
    license = licenses.unfree;
    maintainers = with maintainers; [ massimogengarelli ];
    mainProgram = "codeium-ls_server_linux_x64";
  };
}

