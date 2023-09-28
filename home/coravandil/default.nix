{ pkgs
, unstable
, ...
}:
let
  mypkgs = import ../../pkgs { inherit pkgs; };
in
{
  my-modules = {
    fonts.enable = false;
    im.enable = false;
    fish = {
      enable = true;
      configuration.unstable = true;
    };

    helix = {
      enable = false;
      package = unstable.helix;
      configuration.unstable = true;
      configuration.theme = "onedark";
    };

    neovim = {
      enable = true;
      configuration.unstable = true;
      defaultEditor = true;
    };

    git = {
      enable = true;
      userEmail = "massimo.gengarelli@alten.com";
      configuration.unstable = true;
    };
  };

  programs.k9s = {
    enable = true;
    package = unstable.k9s;
    settings.k9s = {
      refreshRate = 5;
      maxConnRetry = 10;
      enableMouse = true;
      logger = {
        tail = 10000;
        buffer = 10000;
        textWrap = true;
      };
    };
  };

  xdg.configFile."fish/conf.d/alten-abbrs.fish".text = ''
    # Handle KubeConfigs
    abbr -a --set-cursor=MARKER skc -- set -x KUBECONFIG ~/.kube/kubeconfig-MARKER
    abbr -a skce -- set -u KUBECONFIG

    # Azure CLI
    abbr -a acct -- az account list -o table
    abbr -a --set-cursor=HERE accsw -- az account set --subscription "HERE"
    abbr -a akst -- az aks list -o table
  '';

  programs.home-manager.enable = true;

  home.packages =
    let
      stable-packages = with pkgs; [ azure-cli ];
      unstable-packages = with unstable; [
        kubectl
        kubernetes-helm
        podman
        terraform

        # Server is started with Ubuntu
        docker-client
      ];
      other-packages = [ ];
    in
    unstable-packages ++ other-packages ++ stable-packages;


  home.sessionVariables = {
      EDITOR = "nvim";
  };

  systemd.user.startServices = "sd-switch";

  systemd.user.services = {
    "podman-unix" = {
      Unit.Description = "Start Podman socket";
      Service.ExecStart = "${unstable.podman}/bin/podman system service --time=0";
      Service.RestartSec = "1min";
      Service.Restart = [ "on-failure" ];
      Service.ExecStopPost = "rm /run/user/1000/podman/podman.sock";
      Install.WantedBy = [ "default.target" ];
    };

    "clean-containers" = {
      Unit.Description = "Clean all containers";
      Service.ExecStart = [
        "${unstable.docker-client}/bin/docker system prune -af"
        "${unstable.podman}/bin/podman system prune -af"
      ];
      Service.Type = "oneshot";
      Install.WantedBy = [ "default.target" ];
    };
  };

  systemd.user.timers = {
    "clean-containers" = {
      Unit.Description = "Trigger cleaning of containers 5 minutes after boot, twice per day during week, every hour during weekend";
      Install.WantedBy = [ "default.target" ];
      Timer = {
        OnBootSec = "5min";
        OnCalendar = [
          "Mon-Fri *-*-* 09,18:30"
          "Sat,Sun *-*-* *:00:00"
        ];
      };
    };
  };
}
