{ pkgs }:
let
  inherit (pkgs) stdenv lib;
  version = "25.10.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "tridentctl";
  nativeBuildInputs = with pkgs; if stdenv.hostPlatform.isLinux then [
    stdenv.cc.cc.lib
    patchelf
    installShellFiles
  ] else [ installShellFiles ];

  dontBuild = true;
  dontConfigure = true;

  src = builtins.fetchurl {
    url = "https://github.com/NetApp/trident/releases/download/v${version}/trident-installer-${version}.tar.gz";
    sha256 = "sha256:0sksk7sygnm1rh714y66rw1zhskz500asgc546s9y6x8bh48ms0g";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/trident/

    ${if stdenv.hostPlatform.isLinux then ''
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
