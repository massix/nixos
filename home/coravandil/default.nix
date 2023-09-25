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
      configuration.theme = "onedark";
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
    other-packages = with mypkgs; [ lombok jdtls ];
  in unstable-packages ++ other-packages ++ stable-packages;


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
