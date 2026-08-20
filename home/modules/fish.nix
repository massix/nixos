{ config, lib, pkgs, ... }:
let
  cfg = config.massix.fish;
  inherit (lib) mkEnableOption mkOption mkIf types concatMapStrings;
in
{
  options.massix.fish = {
    enable = mkEnableOption "Enable fish handling";

    configuration.extraPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra paths to add to fish";
      example = [ "{$HOME}/bin" ];
    };

    configuration.extraShellAbbrs = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra abbreviations for fish";
    };

    configuration.extraShellAliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra shell aliases for fish";
    };

    configuration.extraInit = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra init options for fish";
      example = [ "source ~/file" "echo 'Hello World'" ];
    };
  };

  config = mkIf cfg.enable {
    programs.bash.enable = false;
    programs.zsh.enable = false;

    programs.broot = {
      enable = true;
      package = pkgs.broot;
      settings = {
        modal = true;
        special_paths = {
          "~/OneDrive" = { list = "never"; };
        };
      };
    };

    programs.fzf = {
      enable = true;
      package = pkgs.fzf;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableNushellIntegration = false;
      enableFishIntegration = true;
    };

    programs.fish = {
      enable = true;
      package = pkgs.fish;

      # Generic abbreviations for Nix handling
      shellAbbrs = {
        hm = "home-manager";
        nix-gc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
        nrs = "sudo nixos-rebuild switch";
        hms = "home-manager switch";
      } // cfg.configuration.extraShellAbbrs;

      plugins =
        let
          fromRepo = plugin: {
            inherit (pkgs.fishPlugins."${plugin}") src;
            name = plugin;
          };
        in
        map fromRepo [
          "grc"
          "z"
          "tide"
          "foreign-env"
          "fzf"
          "colored-man-pages"
          "puffer"
          "humantime-fish"
        ];

      shellAliases = {
        cat = "bat -pp --paging=never";
        grep = "rg";
        du = "dust";
        df = "duf";
        htop = "btop";
        dig = "dog";
        find = "fd";
        less = "moor";
        traceroute = "mtr";
        ps = "procs";
        ls = "eza --icons always";
        iftop = "bmon";
      } // cfg.configuration.extraShellAliases;

      interactiveShellInit = ''
        set fish_greeting
        ${builtins.concatStringsSep "\n" cfg.configuration.extraInit}

        if test -f ~/.gh-mcp-token
          set -gx GH_MCP_TOKEN (cat ~/.gh-mcp-token)
        end

        if test -f ~/.jira-mcp-token
          set -gx JIRA_MCP_TOKEN (cat ~/.jira-mcp-token)
        end
      '';

      shellInit = ''
        set -g fish_key_bindings fish_default_key_bindings
      '';
    };

    home.sessionVariables = {
      PAGER = "bat -pp --paging=always";
    };

    # A modern Linux experience
    home.packages = with pkgs; [
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

    # Some useful extra scripts
    xdg.configFile = {
      # Homebrew Integration
      "fish/conf.d/extra-001-brew.fish".text = ''
        if type -q /home/linuxbrew/.linuxbrew/bin/brew
          eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        end
      '';

      # Extra Paths
      "fish/conf.d/extra-999-extra-paths.fish".text = ''
        # Extra Paths
        ${concatMapStrings (x: "fish_add_path " + x + "\n") cfg.configuration.extraPaths}
      '';
    };
  };
}
