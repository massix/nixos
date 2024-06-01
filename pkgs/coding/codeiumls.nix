{ pkgs }:
let
  inherit (pkgs) lib;
  version = "1.8.45";
  fetchCodeium = version: hash: builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
    sha256 = hash;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "codeium-ls";
  inherit version;

  nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

  src = fetchCodeium version "sha256:0m3y4zm2pl126kz2iqf7fslv1z9qkcdv6jkr012kgdjvdmhyyjp3";

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

