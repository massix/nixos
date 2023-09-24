{ config, lib, pkgs, unstable, ... }:
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
      default = "massimo.gengarelli@gmail.com";
      description = "User email";
    };
    configuration.unstable = mkEnableOption "Use unstable channel";
  };

  config =
    let
      channel = if cfg.configuration.unstable then unstable else pkgs;
    in
    mkIf cfg.enable {
      programs.git = {
        inherit (cfg) enable userName userEmail;
        package = channel.git;

        delta.enable = true;
        delta.package = channel.delta;

        delta.options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };

        aliases = {
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };

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
    };
}
