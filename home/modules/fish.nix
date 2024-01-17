{ config, lib, pkgs, unstable, ... }:
let
  cfg = config.my-modules.fish;
  inherit (lib) mkEnableOption mkOption mkIf types concatMapStrings;
  inherit (pkgs) fetchFromGitHub;
in
{
  options.my-modules.fish = {
    enable = mkEnableOption "Enable fish handling";
    configuration.unstable = mkEnableOption "Install from the unstable channel";

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
  };

  config =
    let
      channel = if cfg.configuration.unstable then unstable else pkgs;
    in
    mkIf cfg.enable {
      programs.bash.enable = true;
      programs.zsh.enable = false;

      programs.broot = {
        enable = true;
        package = channel.broot;
        settings.modal = true;
      };

      programs.fzf = {
        enable = true;
        # package = channel.fzf;
        enableBashIntegration = false;
        enableZshIntegration = false;
        enableFishIntegration = true;
      };

      programs.fish = {
        enable = true;
        package = channel.fish;

        # Generic abbreviations for Nix handling
        shellAbbrs = {
          hm = "home-manager";
          nix-gc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
          nrs = "sudo nixos-rebuild switch";
          hms = "home-manager switch";
        } // cfg.configuration.extraShellAbbrs;

        plugins = [
          {
            name = "puffer-fish";
            src = fetchFromGitHub {
              repo = "puffer-fish";
              owner = "nickeb96";
              rev = "5d3cb25e0d63356c3342fb3101810799bb651b64";
              hash = "sha256-aPxEHSXfiJJXosIm7b3Pd+yFnyz43W3GXyUB5BFAF54=";
            };
          }
          {
            name = "z";
            src = fetchFromGitHub {
              repo = "z";
              owner = "jethrokuan";
              rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
              hash = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
            };
          }
          {
            name = "tide";
            src = fetchFromGitHub {
              repo = "tide";
              owner = "ilancosman";
              rev = "v6.1.1";
              hash = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
            };
          }
          {
            name = "foreign-env";
            src = fetchFromGitHub {
              repo = "plugin-foreign-env";
              owner = "oh-my-fish";
              rev = "7f0cf099ae1e1e4ab38f46350ed6757d54471de7";
              hash = "sha256-4+k5rSoxkTtYFh/lEjhRkVYa2S4KEzJ/IJbyJl+rJjQ=";
            };
          }
        ];

        shellAliases = {
          cat = "bat -pp --paging=never";
          grep = "rg";
          du = "dust";
          df = "duf";
          htop = "btop";
          diff = "difftastic";
          dig = "dog";
          find = "fd";
          jq = "jiq";
          ping = "gping";
          less = "moar";
          traceroute = "mtr";
          ps = "procs";
          ls = "eza --icons";
          iftop = "bmon";
        };
      };

      home.sessionVariables = {
        PAGER = "bat -pp --paging=always";
      };

      # A modern Linux experience
      home.packages = with channel; [
        asciinema # Terminal recorder
        bmon # Modern Unix `iftop`
        bat # Modern Unix `cat`
        btop # Modern Unix `htop`
        # butler # Terminal Itch.io API client
        chafa # Terminal image viewer
        cheat # Modern Unix `man`
        chroma # Code syntax highlighter
        curlie # Terminal HTTP client
        dconf2nix # Nix code from Dconf files
        difftastic # Modern Unix `diff`
        dogdns # Modern Unix `dig`
        dua # Modern Unix `du`
        duf # Modern Unix `df`
        du-dust # Modern Unix `du`
        entr # Modern Unix `watch`
        eza # Modern Unix `ls`
        fast-cli # Terminal fast.com
        fd # Modern Unix `find`
        glow # Terminal Markdown renderer
        gping # Modern Unix `ping`
        hexyl # Modern Unix `hexedit`
        httpie # Terminal HTTP client
        hyperfine # Terminal benchmarking
        iperf3 # Terminal network benchmarking
        iw # Terminal WiFi info
        jpegoptim # Terminal JPEG optimizer
        jiq # Modern Unix `jq`
        lazygit # Terminal Git client
        libva-utils # Terminal VAAPI info
        lurk # Modern Unix `strace`
        mdp # Terminal Markdown presenter
        moar # Modern Unix `less`
        mtr # Modern Unix `traceroute`
        ncdu # Modern Unix `du`
        netdiscover # Modern Unix `arp`
        nethogs # Modern Unix `iftop`
        nixpkgs-review # Nix code review
        nurl # Nix URL fetcher
        nyancat # Terminal rainbow spewing feline
        speedtest-go # Terminal speedtest.net
        optipng # Terminal PNG optimizer
        procs # Modern Unix `ps`
        quilt # Terminal patch manager
        ranger # Terminal file manager
        ripgrep # Modern Unix `grep`
        shellcheck # Code lint Shell
        shfmt # Code format Shell
        thefuck # Correct last command
        tldr # Modern Unix `man`
        tokei # Modern Unix `wc` for code
        wavemon # Terminal WiFi monitor
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

        "fish/functions/fuck.fish".text = ''
          function fuck -d "Correct your previous console command"
            set -l fucked_up_command $history[1]
            env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
            if [ "$unfucked_command" != "" ]
              eval $unfucked_command
              builtin history delete --exact --case-sensitive -- $fucked_up_command
              builtin history merge
            end
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
