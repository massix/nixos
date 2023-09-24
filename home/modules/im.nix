{ pkgs, unstable, config, lib, ... }:
let
  cfg = config.my-modules.im;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.my-modules.im = {
    enable = mkEnableOption "Activate IM module";
    configuration.unstable = mkEnableOption "Use unstable channel";
  };

  config = mkIf cfg.enable {
    home.packages =
      let
        channel = if cfg.configuration.unstable then unstable else pkgs;
      in
      with channel; [
        telegram-desktop
        whatsapp-for-linux
        webcord
      ];
  };
}
