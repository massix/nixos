{ pkgs
, unstable
, ...
}:
let
  mypkgs = import ../../pkgs { inherit pkgs; };
in {
  my-modules = {
    fonts.enable = false;
    im.enable = false;
    fish = {
      enable = true;
      configuration.unstable = true;
    };

    helix = {
      enable = true;
      package = unstable.helix;
      configuration.unstable = true;
    };

    git = {
      enable = true;
      userEmail = "massimo.gengarelli@alten.com";
      configuration.unstable = true;
    };
  };

  programs.home-manager.enable = true;

  home.packages =
  let
    unstable-packages = with unstable; [
      kubectl
      kubernetes-helm
      k9s
      podman

      # Server is started with Ubuntu
      docker-client
    ];

    other-packages = with mypkgs; [ lombok jdtls ];
  in unstable-packages ++ other-packages;


  programs.helix.languages = {
    language = [
      {
        name = "java";
        indent.tab-width = 2;
        indent.unit = "  ";
        language-server = {
          command = "${mypkgs.jdtls}/bin/jdtls";
          args = ["--jvm-arg=-javaagent:${mypkgs.lombok}/lombok.jar"];
        };
      }
    ];
  };

  systemd.user.services = {
    "podman-unix" = {
      Unit.Description = "Start Podman socket";
      Service.ExecStart = "${unstable.podman}/bin/podman system service --time=0";
      Install.WantedBy = ["default.target"];
    };
  };
}
