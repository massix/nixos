{ pkgs }:
let
  inherit (pkgs) lib stdenvNoCC;
  pname = "codeium-ls";
  version = "1.20.9";
  fetchCodeium = version: hash: path: builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/${path}";
    sha256 = hash;
  };
  meta = with lib; {
    description = "Codeium Language Server";
    homepage = "https://github.com/Exafunction/codeium";
    license = licenses.unfree;
    maintainers = with maintainers; [ massimogengarelli ];
    mainProgram = "codeium-ls";
  };
  mkInstallPhase = binPath: ''
    runHook preInstall
    mkdir -p $out/bin
    gunzip -d -c -f $src > $out/bin/${binPath}
    chmod +x $out/bin/${binPath}
    runHook postInstall
  '';
  linuxPkg = stdenvNoCC.mkDerivation {
    inherit pname version meta;

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

    src = fetchCodeium version "sha256:0wwqmnbbabl8xj8l9jh6cbaw323b6b0fqbz4zn11lfid8knlmqr1" "language_server_linux_x64.gz";

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = mkInstallPhase "codeium-ls";

  };
  macPkg = stdenvNoCC.mkDerivation {
    inherit pname version meta;
    src = fetchCodeium version "sha256:13v3k1i169cy6f1zmc6ma12pxdfq72l1gkqb1shhd63w9b8lfcyn" "language_server_macos_arm.gz";

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = mkInstallPhase "codeium-ls";
  };
in
if stdenvNoCC.hostPlatform.isLinux then linuxPkg else macPkg
