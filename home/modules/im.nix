{ pkgs, config, lib, ... }:
let
  cfg = config.my-modules.im;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.my-modules.im = {
    enable = mkEnableOption "Activate IM module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      webcord
      zapzap /* whatsapp client */
      telegram-desktop
    ];
  };
}
