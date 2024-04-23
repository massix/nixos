{ unstable, ... }:
let
  inherit (unstable) buildNpmPackage;
in
buildNpmPackage rec {
  pname = "vscode-js-debug";
  version = "1.88.0";

  nativeBuildInputs = with unstable; [
    nodePackages.gulp-cli
    python311
    pkg-config
  ];

  buildInputs = with unstable; [ libsecret ];

  patches = [ ./patches/patch-packages-json.patch ];

  src = unstable.fetchFromGitHub {
    owner = "microsoft";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gmeuRUcdz/4+FtPOblNj5DX3otXNRjHJjhPcCRuWXAY=";
  };

  npmDepsHash = "sha256-M4h2p8GLVjBDla0ile1jKWF6wPSdgcumx2GKm9KGmlw=";
  npmInstallFlags = "--omit=dev";
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild
    gulp clean compile vsDebugServerBundle:webpack-bundle
    runHook postBuild
  '';

  installPhase = ''
    mkdir $out
    mv dist $out/${pname}
  '';
}
