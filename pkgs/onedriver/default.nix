{ pkgs }:
let
  inherit (pkgs) buildGoModule fetchFromGitHub lib;
in
buildGoModule rec {
  pname = "onedriver";
  version = "0.14.1";
  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "jstaf";
    repo = "onedriver";
    rev = "v${version}";
    hash = "sha256-mA5otgqXQAw2UYUOJaC1zyJuzEu2OS/pxmjJnWsVdxs=";
  };

  vendorHash = "sha256-OOiiKtKb+BiFkoSBUQQfqm4dMfDW3Is+30Kwcdg8LNA=";

  meta = with lib; {
    description = "Onedriver is a network filesystem for Linux";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.gpl3;
    maintainers = [
      {
        handle = "Massimo Gengarelli";
        email = "massimo.gengarelli@gmail.com";
        github = "massix";
      }
    ];
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    git
    installShellFiles
  ];

  buildInputs = with pkgs; [
    webkitgtk_4_1
    glib
    fuse
  ];

  ldflags = [ "-X github.com/jstaf/onedriver/cmd/common.commit=v${version}" ];

  subPackages = [
    "cmd/onedriver"
    "cmd/onedriver-launcher"
  ];

  postInstall = ''
    echo "Running postInstall"
    install -Dm644 ./pkg/resources/onedriver.svg $out/share/icons/onedriver/onedriver.svg
    install -Dm644 ./pkg/resources/onedriver.png $out/share/icons/onedriver/onedriver.png
    install -Dm644 ./pkg/resources/onedriver-128.png $out/share/icons/onedriver/onedriver-128.png

    install -Dm644 ./pkg/resources/onedriver.desktop $out/share/applications/onedriver.desktop
    install -Dm644 ./pkg/resources/onedriver@.service $out/lib/systemd/user/onedriver@.service

    mkdir -p $out/share/man/man1
    installManPage ./pkg/resources/onedriver.1

    substituteInPlace $out/share/applications/onedriver.desktop \
      --replace "/usr/bin/onedriver-launcher" "$out/bin/onedriver-launcher" \
      --replace "/usr/share/icons" "$out/share/icons"

    substituteInPlace $out/lib/systemd/user/onedriver@.service \
      --replace "/usr/bin/onedriver" "$out/bin/onedriver" \
      --replace "/usr/bin/fusermount" "${pkgs.fuse3}/bin/fusermount"
  '';

  doCheck = false;
}
