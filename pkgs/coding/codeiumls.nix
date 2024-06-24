{ pkgs }:
let
  inherit (pkgs) lib;
  version = "1.8.62";
  fetchCodeium = version: hash: builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    sha256 = hash;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "codeium-ls";
  inherit version;

  nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

  src = fetchCodeium version "sha256:01lbka0rbxjsdj11x652y8x5n3d9f66sgjsisrym2kw9nawx8spv";

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

