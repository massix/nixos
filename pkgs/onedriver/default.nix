{ pkgs
, wrapperDir ? "/run/wrappers/bin"
}:
let
  inherit (pkgs) buildGoModule fetchFromGitHub;
  version = "v0.15.0";
  pname = "onedriver";
in
buildGoModule {
  inherit version pname;
  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "jstaf";
    repo = pname;
    rev = "${version}";
    hash = "sha256-DCxF52CtA9KAP+yz5Rgzc/nUAXtZwfYAVU7oHREJlRY=";
  };

  vendorHash = "sha256-Ifcmf9AtZnrjgTPQnof/ap0TY19zHVftm5N4JgvbAgs=";

  preBuild = ''
    substituteInPlace cmd/common/common.go \
      --replace-fail "/usr/share/icons/onedriver/onedriver.png" "$out/share/icons/onedriver/onedriver.png"
  '';

  nativeBuildInputs = with pkgs; [
    pkg-config
    git
    installShellFiles
    wrapGAppsHook3
  ];

  buildInputs = with pkgs; [ webkitgtk_4_1 glib fuse gtk3 glib-networking ];

  ldflags = [ "-X github.com/jstaf/onedriver/cmd/common.commit=${version}" ];

  subPackages = [
    "cmd/onedriver"
    "cmd/onedriver-launcher"
  ];

  postInstall = ''
    install -Dm644 ./pkg/resources/onedriver.svg $out/share/icons/onedriver/onedriver.svg
    install -Dm644 ./pkg/resources/onedriver.png $out/share/icons/onedriver/onedriver.png
    install -Dm644 ./pkg/resources/onedriver-128.png $out/share/icons/onedriver/onedriver-128.png

    install -Dm644 ./pkg/resources/onedriver-launcher.desktop $out/share/applications/onedriver-launcher.desktop
    install -Dm644 ./pkg/resources/onedriver@.service $out/lib/systemd/user/onedriver@.service

    mkdir -p $out/share/man/man1
    installManPage ./pkg/resources/onedriver.1

    substituteInPlace $out/share/applications/onedriver-launcher.desktop \
      --replace-fail "/usr/bin/onedriver-launcher" "$out/bin/onedriver-launcher" \
      --replace-fail "/usr/share/icons" "$out/share/icons"

    substituteInPlace $out/lib/systemd/user/onedriver@.service \
      --replace-fail "/usr/bin/onedriver" "$out/bin/onedriver" \
      --replace-fail "/usr/bin/fusermount" "${wrapperDir}/fusermount"
  '';

  doCheck = false;
}
