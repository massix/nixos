{ pkgs }:
let
  inherit (pkgs) lib stdenvNoCC;
  pname = "codeium-ls";
  version = "1.20.8";
  fetchCodeium = version: hash: path: builtins.fetchurl {
    url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/${path}";
    sha256 = hash;
  };
  commonMeta = with lib; {
    description = "Codeium Language Server";
    homepage = "https://github.com/Exafunction/codeium";
    license = licenses.unfree;
    maintainers = with maintainers; [ massimogengarelli ];
    mainProgram = "codeium-ls_server_linux_x64";
  };
  mkInstallPhase = binPath: ''
    runHook preInstall
    mkdir -p $out/bin
    gunzip -d -c -f $src > $out/bin/${binPath}
    chmod +x $out/bin/${binPath}
    runHook postInstall
  '';
  linuxPkg = stdenvNoCC.mkDerivation {
    inherit pname version;

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

    src = fetchCodeium version "sha256:084pmlwddr8cy5f5zdgpl1ia85vjxbsp807v2fgq1pd7d5447xlh" "language_server_linux_x64.gz";

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = mkInstallPhase "codeium-ls_server_linux_x64";

    meta = commonMeta // {
      mainProgram = "codeium-ls_server_linux_x64";
    };
  };
  macPkg = stdenvNoCC.mkDerivation {
    inherit pname version;
    src = fetchCodeium version "sha256:02vqfvkl604jp0zl61p8b2c4mlbjhyjh9xisrdhfnd215hnrf5mg" "language_server_macos_arm.gz";

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = mkInstallPhase "codeium-ls_server_macos_arm";

    meta = commonMeta // {
      mainProgram = "codeium-ls_server_macos_arm";
    };
  };
in
if stdenvNoCC.hostPlatform.isLinux then linuxPkg else macPkg
