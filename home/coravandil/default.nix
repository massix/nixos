{ pkgs
, unstable
, ...
}: {
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

  home.packages = with unstable; [
    kubectl
    kubernetes-helm
    k9s
    podman

    # Server is started with Ubuntu
    docker-client
  ];

  systemd.user.services = {
    "podman-unix" = {
      Unit.Description = "Start Podman socket";
      Service.ExecStart = "${unstable.podman}/bin/podman system service --time=0";
      Install.WantedBy = ["default.target"];
    };
  };
}
