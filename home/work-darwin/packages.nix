{ pkgs
, config
, ...
}:
let
  inherit (pkgs) lib stdenv stdenvNoCC;
  inherit (config.home) homeDirectory;
  load-ssh-key = pkgs.writeScriptBin "load-ssh-key" ''
    #!${lib.getExe pkgs.bash}

    RESCUE_PASSPHRASE="$(cat ${homeDirectory}/.ssh/rescuep)"

    ${lib.getExe pkgs.expect} <<EOF
        spawn ssh-add ${homeDirectory}/.ssh/rescue
        expect "Enter passphrase"
        send "$RESCUE_PASSPHRASE\r"
        expect eof
    EOF

    ssh-add ${homeDirectory}/.ssh/mgengarelli
  '';
  macpass = assert stdenv.isDarwin && stdenv.isAarch64;
    stdenvNoCC.mkDerivation rec {
      pname = "macpass";
      version = "0.8.1";

      nativeBuildInputs = [ pkgs.unzip ];

      src = builtins.fetchurl {
        url = "https://github.com/MacPass/MacPass/releases/download/${version}/MacPass-${version}.zip";
        sha256 = "sha256:0wxifcl4klvkdllalmpwixv5z6wnwmsfpcbrzv0w0hjvjkf3n39d";
      };

      sourceRoot = ".";
      dontBuild = true;
      doCheck = false;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications/
        cp -a *.app "$out/Applications/"

        runHook postInstall
      '';
    };
  tana = assert stdenv.isDarwin;
    stdenvNoCC.mkDerivation rec {
      pname = "tana";
      version = "1.515.0";
      nativeBuildInputs = [ pkgs.undmg ];

      src = builtins.fetchurl {
        url = "https://github.com/tanainc/tana-desktop-releases/releases/download/v${version}/Tana-${version}-universal.dmg";
        sha256 = "sha256:0nqar71fsv3zns6ih5z1baix8hkh26fcp2zm97ivskids122s47w";
      };

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/
        cp -a *.app $out/Applications/
        runHook postInstall
      '';
    };
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
  clusterctl = assert stdenv.isDarwin;
    stdenvNoCC.mkDerivation rec {
      pname = "clusterctl";
      version = "1.10.8";

      src = builtins.fetchurl {
        url = "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${version}/clusterctl-darwin-arm64";
        sha256 = "sha256:0wzmkh1fwqxg6q6wa2wg8zhzki4r2ha1brmlllg4i694hz56q1pw";
      };

      sourceRoot = ".";

      dontUnpack = true;
      dontConfigure = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        install -m 0755 $src $out/bin/clusterctl
        runHook postInstall
      '';
    };
  stickyshot = assert stdenv.isDarwin;
    stdenvNoCC.mkDerivation rec {
      pname = "StickyShot";
      version = "1.2.0";
      nativeBuildInputs = [ pkgs._7zz pkgs.darwin.xattr ];

      unpackPhase = ''
        7zz x -snld $src
      '';

      src = builtins.fetchurl {
        url = "https://github.com/rgcr/stickyshot/releases/download/v${version}/StickyShot-${version}-macos.dmg";
        sha256 = "sha256:03vayihsbq3hg0r1jpv1mv1cnj9d64dmx93f4j7yxibvmsfabkhj";
      };

      dontConfigure = true;

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/
        cp -a *.app $out/Applications/
        xattr -cr $out/Applications/*.app
        runHook postInstall
      '';
    };
in
{
  # Custom darwin ghostty .app bundle; the rest of massix.ghostty (theme, fonts,
  # extraSettings, ...) is configured in ./default.nix and merged by the module
  # system.
  massix.ghostty.package = ghostty;

  # Custom darwin packages — the nixpkgs ones are installed from ./default.nix.
  home.packages = [
    load-ssh-key
    macpass
    tana
    clusterctl
    stickyshot
  ];
}
