{ config, lib, pkgs, ... }:
let
  cfg = config.my-modules.git;
  inherit (lib) mkEnableOption mkOption mkIf;
in
{
  options.my-modules.git = {
    enable = mkEnableOption "Activate Git module";
    userName = mkOption {
      type = lib.types.str;
      default = "Massimo Gengarelli";
      description = "User name";
    };
    userEmail = mkOption {
      type = lib.types.str;
      default = "massimo.gengarelli@proton.me";
      description = "User email";
    };
    workRepository = {
      enabled = mkEnableOption "Work repository";
      workEmail = mkOption { type = lib.types.str; description = "Work email"; };
      workRoot = mkOption { type = lib.types.str; description = "Work root"; };
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      inherit (cfg) enable userName userEmail;
      package = pkgs.git;

      delta = {
        enable = true;
        package = pkgs.delta;

        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };
      };

      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lgnc = "log --oneline --graph --all";
      };

      includes = mkIf cfg.workRepository.enabled [{
        condition = "gitdir:${cfg.workRepository.workRoot}";
        contents.user.email = cfg.workRepository.workEmail;
      }];

      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
      };

      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };

    my-modules.fish.configuration.extraShellAbbrs = mkIf config.my-modules.fish.enable {
      g = "git";
      gco = "git checkout";
      gcl = "git clone";
      gclgh = "git clone git@github.com:";
      gcm = "git commit -m";
      ga = "git add";
      gd = "git diff";
      gs = "git status";
    };
  };
}
