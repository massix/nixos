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
in
{
  massix.ghostty.package = null;

  # Custom darwin packages — the nixpkgs ones are installed from ./default.nix.
  home.packages = [
    load-ssh-key
    clusterctl
  ];
}
