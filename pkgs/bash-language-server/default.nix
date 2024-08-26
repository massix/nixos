{ pkgs }:
let
  inherit (pkgs) lib fetchFromGitHub;
in
pkgs.stdenv.mkDerivation rec {
  pname = "bash-language-server";
  version = "5.4.0";
  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm_8.configHook
    makeBinaryWrapper
    versionCheckHook
  ];

  src = fetchFromGitHub {
    owner = "bash-lsp";
    repo = "bash-language-server";
    rev = "server-${version}";
    hash = "sha256-yJ81oGd9aNsWQMLvDSgMVVH1//Mw/SVFYFIPsJTQYzE=";
  };

  pnpmWorkspace = "bash-language-server";
  pnpmDeps = pkgs.pnpm_8.fetchDeps {
    inherit pname version src pnpmWorkspace;
    hash = "sha256-W25xehcxncBs9QgQBt17F5YHK0b+GDEmt27XzTkyYWg=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm compile server
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm --offline --frozen-lockfile --ignore-script --filter=bash-language-server deploy $out/lib/bash-language-server
    rm -r $out/lib/bash-language-server/src
    rm -r $out/lib/bash-language-server/node_modules/.bin

    makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/bash-language-server \
      --suffix PATH : ${lib.makeBinPath [ pkgs.shellcheck ]} \
      --inherit-argv0 \
      --add-flags $out/lib/bash-language-server/out/cli.js
  '';

  dontCheck = true;
}
