{ pkgs }:
let
  inherit (pkgs) stdenv fetchurl lib;
  version = "24.06.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "tridentctl";
  nativeBuildInputs = with pkgs; if pkgs.hostPlatform.isLinux then [
    stdenv.cc.cc.lib
    patchelf
    installShellFiles
  ] else [ installShellFiles ];

  dontBuild = true;
  dontConfigure = true;

  src = fetchurl {
    url = "https://github.com/NetApp/trident/releases/download/v${version}/trident-installer-${version}.tar.gz";
    hash = "sha256-Y4yc1zfX/SGyAkJ3zm+k2W3Jd+Dxq7Y5kJSUbM1wmc4=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/trident/

    ${if pkgs.hostPlatform.isLinux then ''
    install -m 0555 tridentctl $out/bin/tridentctl
    '' else ''
    install -m 0555 extras/macos/bin/tridentctl $out/bin/tridentctl
    ''}
    cp -R sample-input/* $out/share/trident/
    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd tridentctl \
      --bash <($out/bin/tridentctl completion bash) \
      --fish <($out/bin/tridentctl completion fish) \
      --zsh <($out/bin/tridentctl completion zsh)
  '';

  meta = with lib; {
    mainProgram = "tridentctl";
    maintainers = [ maintainers.massimogengarelli ];
    description = "CLI tool to handle Astra Trident installations on K8S clusters";
    license = licenses.asl20;
  };
}
