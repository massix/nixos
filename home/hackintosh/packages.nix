{ pkgs
, ...
}:
let
  inherit (pkgs) stdenv stdenvNoCC;
  ghostty = assert stdenv.isDarwin;
    let
      fetch = version: sha: builtins.fetchurl {
        url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
        sha256 = sha;
      };
    in
    stdenvNoCC.mkDerivation rec {
      pname = "ghostty";
      version = "1.3.1";
      nativeBuildInputs = [ pkgs._7zz ];

      src = fetch "${version}" "sha256:0saziwxpkjqy5issl57jp902l9cah170dly7v7m0xsfflsqg5kqq";

      unpackPhase = ''
        7zz x -snld $src
      '';

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mkdir -p $out/Applications/
        cp -a *.app $out/Applications/
        ln -s $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin
        runHook postInstall
      '';
    };
in
{
  # Ghostty upstream dropped x86_64 macOS builds entirely (not just the flake
  # overlay — the project no longer publishes x86_64 binaries).  As a
  # workaround, fetch the last compatible pre-built .dmg and install the .app
  # bundle manually.  This derivation will stop working if Ghostty removes the
  # hosted .dmg.  The version here should be kept in sync with the Ghostty
  # overlay used on other machines when possible.
  massix.ghostty.package = ghostty;

  # Custom darwin packages — the nixpkgs ones are installed from ./default.nix.
  home.packages = [
  ];
}
