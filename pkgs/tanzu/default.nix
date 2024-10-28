{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tanzu";
  version = "1.5.1";

  src = builtins.fetchurl {
    url = "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v${version}/tanzu-cli-linux-amd64.tar.gz";
    sha256 = "sha256:144635rh8nqxxnivpn9801lyqiqzxv094vgp9n60s0xfgs0paxiy";
  };

  nativeBuildInputs = with pkgs; [
    stdenv.cc.cc.lib
    installShellFiles
    autoPatchelfHook
  ];

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0555 tanzu-cli-linux_amd64 $out/bin/tanzu
    runHook postInstall
  '';

  postInstall = ''
    # Need this, tanzu needs to create a temporary lock file in the home folder
    export HOME=$PWD
    installShellCompletion --cmd tanzu \
      --bash <($out/bin/tanzu completion bash) \
      --fish <($out/bin/tanzu completion fish) \
      --zsh <($out/bin/tanzu completion zsh)
  '';
}
