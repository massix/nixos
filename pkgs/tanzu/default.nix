{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tanzu";
  version = "1.4.1";

  src = builtins.fetchurl {
    url = "https://storage.googleapis.com/tanzu-cli-os-packages/apt/pool/main/t/tanzu-cli/tanzu-cli_${version}_linux_amd64.deb";
    sha256 = "sha256:0gjsvnn1cg0dq5h8nqmbnfkv7d99zd2ksac620vp8lpgmg603qzp";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    stdenv.cc.cc.lib
    installShellFiles
    autoPatchelfHook
  ];

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0555 usr/bin/tanzu $out/bin/tanzu
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
