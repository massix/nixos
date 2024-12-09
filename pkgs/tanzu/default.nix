{ pkgs, ... }:
let
  systemsMap = {
    x86-64_linux = "linux-amd64";
    aarch64-darwin = "darwin-arm64";
  };
  fetchPkg = version: system: hash:
    let
      s = systemsMap.${system};
      tarball = "tanzu-cli-${s}.tar.gz";
    in
    builtins.fetchurl {
      url = "https://github.com/vmware-tanzu/tanzu-cli/releases/download/v${version}/${tarball}";
      sha256 = hash;
    };
  pname = "tanzu";
  version = "1.5.1";
  src =
    if pkgs.hostPlatform.isLinux then
      (fetchPkg version "x86-64_linux" "sha256:144635rh8nqxxnivpn9801lyqiqzxv094vgp9n60s0xfgs0paxiy")
    else
      (fetchPkg version "aarch64-darwin" "sha256:1y043xmzn99nd0z991ykmii2k94byn7vigvlsz9q96ih8i06bslf");
in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = with pkgs; if pkgs.hostPlatform.isLinux then [
    stdenv.cc.cc.lib
    installShellFiles
    autoPatchelfHook
  ] else [ installShellFiles ];

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0555 tanzu-cli-* $out/bin/tanzu
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
