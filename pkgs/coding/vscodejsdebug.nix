{ unstable, ... }:
let
  inherit (unstable) buildNpmPackage;
in
buildNpmPackage rec {
  pname = "vscode-js-debug";
  version = "1.85.0";

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
    hash = "sha256-mBXH3tqoiu3HIo1oZdQCD7Mq8Tvkt2DXfcoXb7KEgXE=";
  };

  npmDepsHash = "sha256-O2P+sHDjQm9bef4oUNBab0khTdR/nUDyhalSoxj0JL0=";

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild
    gulp clean compile vsDebugServerBundle:webpack-bundle
    runHook postBuild
  '';

  npmInstallFlags = "--omit=dev";

  installPhase = ''
    mkdir $out
    mv dist $out/${pname}
  '';
}
