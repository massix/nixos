{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.massix.cli-tools;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.massix.cli-tools = {
    enable = mkEnableOption "CLI tools and the shared shell catalogue";

    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        asciinema # Terminal recorder
        bmon # Modern Unix `iftop`
        bat # Modern Unix `cat`
        btop # Modern Unix `htop`
        chafa # Terminal image viewer
        cheat # Modern Unix `man`
        curlie # Terminal HTTP client
        difftastic # Modern Unix `diff`
        doggo # Modern Unix `dig`
        dua # Modern Unix `du`
        duf # Modern Unix `df`
        dust # Modern Unix `du`
        entr # Modern Unix `watch`
        eza # Modern Unix `ls`
        fd # Modern Unix `find`
        fzf # Fuzzy finder
        glow # Terminal Markdown renderer
        gping # Modern Unix `ping`
        grc # Needed for colored man pages
        hexyl # Modern Unix `hexedit`
        httpie # Terminal HTTP client
        hyperfine # Terminal benchmarking
        iperf3 # Terminal network benchmarking
        jpegoptim # Terminal JPEG optimizer
        jiq # Modern Unix `jq`
        just # Terminal command runner
        lazygit # Terminal Git client
        mdp # Terminal Markdown presenter
        moor # Modern Unix `less`
        mtr # Modern Unix `traceroute`
        ncdu # Modern Unix `du`
        netdiscover # Modern Unix `arp`
        nixpkgs-review # Nix code review
        nurl # Nix URL fetcher
        nyancat # Terminal rainbow spewing feline
        speedtest-go # Terminal speedtest.net
        optipng # Terminal PNG optimizer
        procs # Modern Unix `ps`
        quilt # Terminal patch manager
        ripgrep # Modern Unix `grep`
        tldr # Modern Unix `man`
        tokei # Modern Unix `wc` for code
        yq-go # Terminal `jq` for YAML
      ];
      description = "CLI tools to install for every shell";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Shell aliases shared by all shells";
    };

    abbreviations = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Shell abbreviations shared by all shells";
    };

    extraPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra paths to add to the shells";
      example = [ "$HOME/bin" ];
    };

    environment = {
      variables = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Environment variables exported to the shells";
      };

      secretFiles = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              name = mkOption {
                type = types.str;
                description = "Name of the environment variable";
              };
              file = mkOption {
                type = types.str;
                description = "File holding the secret";
              };
            };
          }
        );
        default = [ ];
        description = "Secret files to export as environment variables";
      };
    };
  };

  config = mkIf cfg.enable {
    massix.cli-tools.aliases = {
      cat = "bat -pp --paging=never";
      grep = "rg";
      du = "dust";
      df = "duf";
      htop = "btop";
      dig = "doggo";
      find = "fd";
      less = "moor";
      traceroute = "mtr";
      ps = "procs";
      ls = "eza --icons always";
      iftop = "bmon";
    };

    massix.cli-tools.abbreviations = {
      hm = "home-manager";
      nix-gc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nrs = "sudo nixos-rebuild switch";
      hms = "home-manager switch";
    };

    massix.cli-tools.environment.variables = {
      PAGER = "bat -pp --paging=always";
    };

    massix.cli-tools.environment.secretFiles = [
      {
        name = "GH_MCP_TOKEN";
        file = "~/.gh-mcp-token";
      }
      {
        name = "JIRA_MCP_TOKEN";
        file = "~/.jira-mcp-token";
      }
    ];

    home.packages = cfg.packages;

    programs.fzf = {
      enable = true;
      package = pkgs.fzf;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableNushellIntegration = false;
    };

    programs.broot = {
      enable = true;
      package = pkgs.broot;
      settings = {
        modal = true;
        special_paths = {
          "~/OneDrive" = {
            list = "never";
          };
        };
      };
    };

    home.sessionVariables = cfg.environment.variables;
  };
}
