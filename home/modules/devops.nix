{ pkgs, lib, config, ... }:
let
  inherit (pkgs) fetchFromGitHub stdenvNoCC;
  inherit (lib) mkEnableOption mkOption mkIf types;
  yamlGenerator = lib.generators.toYAML { };
  iniGenerator = lib.generators.toINI { };

  cfg = config.massix.devops;

  k9sThemes = stdenvNoCC.mkDerivation {
    pname = "catppuccin-k9s-themes";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "k9s";
      rev = "590a762";
      hash = "sha256-EBDciL3F6xVFXvND+5duT+OiVDWKkFMWbOOSruQ0lus=";
    };

    dontBuild = true;
    dontCheck = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/k9s/skins
      cp dist/*.yaml $out/k9s/skins/
    '';
  };
in
{
  options.massix.devops = {
    enable = mkEnableOption "devops module";
    terraform = {
      enable = mkEnableOption "terraform";
      flavour = mkOption {
        type = types.enum [ "terraform" "opentofu" ];
        description = "Choose which flavor of Terraform to install";
        default = "opentofu";
        example = "terraform";
      };
    };
    ansible.enable = mkEnableOption "ansible";
    azure-cli = {
      enable = mkEnableOption "Azure CLI";
      extensions = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };
    };
    kubernetes = {
      enable = mkEnableOption "kubernetes tools";
      colored = mkEnableOption "kubecolor";
    };
    k9s = {
      enable = mkEnableOption "k9s";
      aliases = mkOption {
        type = types.attrs;
        description = "Aliases to configure for k9s";
        default = {
          dp = "deployments";
          sec = "v1/secrets";
          jo = "jobs";
          cr = "clusterroles";
          crb = "clusterrolebindings";
          ro = "roles";
          rb = "rolebindings";
          np = "networkpolicies";
        };
      };
    };
    tanzu.enable = mkEnableOption "tanzu";
    vault.enable = mkEnableOption "hashicorp vault";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      let
        orEmpty = bool: pkgs: if bool then pkgs else [ ];
        k9sPackages = orEmpty cfg.k9s.enable [ k9s ];
        azCliPackages = orEmpty cfg.azure-cli.enable [ (azure-cli.override { withExtensions = cfg.azure-cli.extensions; }) ];
        tanzuPackages = orEmpty cfg.tanzu.enable [
          tanzu
          ytt
          kapp
          vendir
          pinniped
          tridentctl
        ];
        terraformPackages = orEmpty cfg.terraform.enable [ (if cfg.terraform.flavour == "terraform" then terraform else opentofu) ];
        ansiblePackages = orEmpty cfg.ansible.enable [ ansible ];
        kubernetesPackages = orEmpty cfg.kubernetes.enable [
          kubectl
          # doCheck disabled: helm 4.2.0 moved test files to pkg/cmd/ but the
          # darwin preCheck still patches the old cmd/helm/ paths (nixpkgs#532255).
          (kubernetes-helm.overrideAttrs (_: { doCheck = false; }))
          fluxcd
          velero
          kustomize
          kubectx
          kubectl-node-shell
          kubectl-klock
          kubectl-ktop
          kubectl-cnpg
          kubectl-tree
          kubectl-neat
          kubectl-graph
          kubectl-df-pv
          kubectl-explore
          kubectl-validate
          kubectl-evict-pod
          kubectl-view-secret
          kubectl-view-allocations
        ] ++ (orEmpty cfg.kubernetes.colored [ kubecolor ]);
        vaultPackages = orEmpty cfg.vault.enable [ vault ];
      in
      k9sPackages ++
      azCliPackages ++
      tanzuPackages ++
      terraformPackages ++
      ansiblePackages ++
      kubernetesPackages ++
      vaultPackages;

    massix.fish.configuration.extraShellAbbrs =
      let
        orEmpty = bool: attrs: if bool then attrs else { };
        kubernetesAbbrs =
          orEmpty cfg.kubernetes.enable {
            k = "kubectl";
            kc = "kubectl config";
            kg = "kubectl get";
            kgp = "kubectl get pods";
            kgs = "kubectl get svc";
            kgn = "kubectl get nodes";
            kx = "kubectx";
            kn = "kubens";
            kkl = "kubectl klock";
            kns = "kubectl node-shell";
            kkt = "kubectl ktop";
          };
        terraformAbbrs =
          orEmpty cfg.terraform.enable {
            tf = if cfg.terraform.flavour == "terraform" then "terraform" else "tofu";
          };
        ansibleAbbrs =
          orEmpty cfg.ansible.enable {
            anp = "ansible-playbook";
            an = "ansible";
          };
        tanzuAbbrs =
          orEmpty cfg.tanzu.enable {
            tz = "tanzu";
            tc = "tridentctl";
          };
        k9sAbbrs =
          orEmpty cfg.k9s.enable {
            kk = "k9s --readonly";
            kkw = "k9s";
            kkc = "k9s --context";
          };
      in
      kubernetesAbbrs // tanzuAbbrs // k9sAbbrs // terraformAbbrs // ansibleAbbrs;

    massix.fish.configuration.extraShellAliases = mkIf cfg.kubernetes.colored {
      kubectl = "kubecolor";
    };

    home.file = {
      ".azure/config" = mkIf cfg.azure-cli.enable {
        text = iniGenerator {
          core = {
            output = "table";
            first_run = true;
            allow_broker = true;
            collect_telemetry = false;
          };
          cloud = {
            name = "AzureCloud";
          };
          extension = {
            use_dynamic_install = "yes_prompt";
            run_after_dynamic_install = true;
          };
          defaults = {
            location = "westeurope";
          };
          clients = {
            show_secrets_warning = true;
          };
        };

      };
    };

    xdg.configFile = {
      "k9s/config.yaml" = mkIf cfg.k9s.enable {
        text = yamlGenerator {
          k9s = {
            liveViewAutoRefresh = true;
            ui = {
              enableMouse = true;
              reactive = true;
              skin = "catppuccin-macchiato";
            };
            logger = {
              buffer = 5000;
              tail = 2000;
              sinceSeconds = 3600;
            };
          };
        };
      };

      "k9s/skins" = mkIf cfg.k9s.enable { source = "${k9sThemes}/k9s/skins"; };
    };
  };
}
