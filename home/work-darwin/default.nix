{ pkgs
, config
, username
, ...
}:
let
  inherit (pkgs) lib;
  inherit (config.home) homeDirectory;
in
{
  imports = [ ./packages.nix ];

  massix = {
    firefox = {
      enable = true;
      extraExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
      ];
      extraEngines = {
        Jira = {
          urls = [{ template = "https://jira.questel.com/browse/{searchTerms}"; }];
          definedAliases = [ "@jira" ];
        };
      };
    };
    fonts = {
      enable = true;
      # afdko is broken on aarch64-darwin; macOS provides its own UI font and Apple Color Emoji.
      families.exclude = with pkgs; [
        noto-fonts-color-emoji
      ];
    };
    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };
    ghostty =
      let
        to-font-feature = l: builtins.concatStringsSep "," (map (x: "+${x}") l);
      in
      {
        enable = true;
        theme = "TokyoNight";
        extraPackages = with pkgs; [
          monaspace
        ];
        extraSettings = {
          font-family = "Monaspace Krypton";
          font-size = "13";
          window-height = "65";
          window-width = "190";
          font-feature = to-font-feature [
            "calt"
            "liga"
            "ss01" # !=, ===
            "ss02" # <=, >=
            "ss03" # ->, ~>
            "ss04" # </, />
            "ss05" # |>
            "ss06" # &&, ##, ++, __, ==
            "ss07" # ::
            "ss09" # <=>, >>, <<, =<<
            "ss10" # #[ #(
          ];
        };
      };
    fish = {
      enable = true;
      configuration.extraShellAbbrs = {
        j = "just";
        drs = "sudo darwin-rebuild switch --flake ~/.config/nixos#work-darwin";
      };
      configuration.extraInit = [
        "test -f ~/.gitlab-token; and set -gx GITLAB_TOKEN (cat ~/.gitlab-token)"
      ];
    };
    git = {
      enable = true;
      workRepository = {
        enabled = true;
        workRoot = "~/Development/Work/";
        workEmail = "mgengarelli@questel.com";
      };
    };
    devops = {
      enable = true;
      k9s.enable = true;
      ansible.enable = true;
      tanzu.enable = true;
      vault.enable = true;
      terraform = {
        enable = true;
        flavour = "terraform";
      };
      kubernetes = {
        enable = true;
        colored = true;
      };
    };
    opencode = {
      enable = true;
      theme = "tokyonight";
      mcps = [
        "github"
        "context7"
        "gh-grep"
        "jira"
        "gitlab"
        "coros"
      ];
    };
    claude-code = {
      enable = true;
      mcps = [
        "github"
        "context7"
        "gh-grep"
        "jira"
        "gitlab"
        "coros"
        "strava"
      ];
    };
  };
  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = [
          "${homeDirectory}/dev"
          "${homeDirectory}/Development"
          "${homeDirectory}/.config/nvim"
          "${homeDirectory}/.config/nixos"
        ];
      };
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };
  };

  homeage.file = {
    avp = {
      source = ./secrets/avp.age;
      symlinks = [ "${homeDirectory}/.ansible-vault-password" ];
    };
    zerotrust-root = {
      source = ./secrets/zerotrust/zerotrust-root.crt.age;
      copies = [ "${homeDirectory}/.certs/dockerregistry.prd.questel.fr/zerotrust-root.crt" ];
    };
    zerotrust-intermediate = {
      source = ./secrets/zerotrust/zerotrust-intermediate.crt.age;
      copies = [ "${homeDirectory}/.certs/dockerregistry.prd.questel.fr/zerotrust-intermediate.crt" ];
    };
    gitlab-token = {
      source = ../modules/opencode/secrets/gitlab-token.age;
      symlinks = [ "${homeDirectory}/.gitlab-token" ];
    };
  };

  # Packages from nixpkgs — custom darwin derivations live in ./packages.nix.
  home.packages =
    let
      limaWithGuests = pkgs.lima.override {
        withAdditionalGuestAgents = true;
      };
    in
    with pkgs; [
      # This does not come installed by default on MacOS
      gcc
      docker
      limaWithGuests
      colima
    ];

  home.sessionVariables = {
    K9S_CONFIG_DIR = "${homeDirectory}/.config/k9s";
    ANSIBLE_CONFIG = "${homeDirectory}/.ansible.cfg";
    ANSIBLE_VAULT_PASSWORD_FILE = "${homeDirectory}/.ansible-vault-password";
    GITLAB_INSTANCE_URL = "https://git.questel.com";
  };

  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      vault_password_file = ${homeDirectory}/.ansible-vault-password
      host_key_checking = false

      [inventory]
      enable_plugins = vmware_vm_inventory, yaml
    '';
  };

  launchd.enable = true;
  launchd.agents =
    let
      binPath = lib.getExe pkgs.colima;
      inherit (lib) optional;
      mkColimaAgent =
        { enable ? true
        , numCpus ? 8
        , memory ? 8
        , vmType ? "vz"
        , maxCpu ? false
        , diskSize ? 100
        , mount ? true
        , arch
        , profileName
        }: {
          inherit enable;
          config = {
            ProgramArguments = [
              "${binPath}"
              "start"
              "--foreground"
              "--cpu=${toString numCpus}"
              "--memory=${toString memory}"
              "--arch=${arch}"
              "--vm-type=${vmType}"
              "--profile=${profileName}"
              "--disk=${toString diskSize}"
            ]
            ++ optional mount "--mount=${homeDirectory}/.certs/dockerregistry.prd.questel.fr:/etc/docker/certs.d/dockerregistry.prd.questel.fr:ro"
            ++ optional (vmType == "vz") "--vz-rosetta"
            ++ optional maxCpu "--cpu-type=max";

            Label = "massix.colima.${profileName}";

            RunAtLoad = true;
            KeepAlive = true;

            EnvironmentVariables = {
              PATH = "${pkgs.colima}/bin:${pkgs.docker}/bin:/usr/bin/:/bin:/usr/sbin:/sbin";
            };
          };
        };
    in
    {
      colima-aarch64 = mkColimaAgent {
        enable = true;
        arch = "aarch64";
        memory = 14;
        numCpus = 8;
        profileName = "aarch64";
        diskSize = 250;
      };
      colima-x86_64 = mkColimaAgent {
        enable = true;
        arch = "x86_64";
        memory = 14;
        numCpus = 8;
        maxCpu = true;
        profileName = "x86_64";
        diskSize = 250;
      };
    };

  nix = {
    gc.automatic = true;
    gc.options = "--delete-older-than 10d";
    settings = {
      auto-optimise-store = false;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = true;
      trusted-users = [ "root" username ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "surface-zen.cachix.org-1:8OXCpyGHk4UL+BDkgJYW1bGf/ULbNGKLiBjaTELJwaQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://surface-zen.cachix.org"
        "https://cache.nixos.org"
      ];
    };
    registry = {
      nix-darwin = {
        from = {
          id = "nix-darwin";
          type = "indirect";
        };
        to = {
          owner = "nix-darwin";
          repo = "nix-darwin";
          type = "github";
        };
      };
    };
  };

  xdg.configFile."fish/functions/kcon.fish".source = ./files/kcon.fish;
  xdg.configFile."fish/conf.d/rapid-log.fish".source = ./files/rapid-log.fish;
}
