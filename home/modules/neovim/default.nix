{ config, lib, pkgs, unstable, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.my-modules.neovim = {
    enable = mkEnableOption "Enable neovim handling";
    defaultEditor = mkEnableOption "Use nvim as default editor";
    configuration.unstable = mkEnableOption "Install from the unstable channel";
  };

  config = {
    programs.neovim = mkIf cfg.enable {
      inherit (cfg) enable defaultEditor;

      viAlias = true;
      vimAlias = true;
      package = if cfg.configuration.unstable then unstable.neovim-unwrapped else pkgs.neovim-unwrapped;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

    home.packages = with unstable; [
      gcc # Needed for treesitter
      wl-clipboard # To interact with the clipboard
    ];

    # Link needed files, we cannot link the whole directory or lazyVim won't work
    home.file =
      let
        nvimHome = ".config/nvim";
        plugins = "${nvimHome}/lua/plugins";
        config = "${nvimHome}/lua/config";
        util = "${nvimHome}/lua/util";
      in
      {
        # Misc files
        "${util}/nix.lua".text = ''
          -- Some variables that are injected automatically by nix
          return {
            nvimHome = "${nvimHome}"
          }
        '';

        "${util}/defaults.lua".source = ./files/util/defaults.lua;

        # Init and start-up options 
        "${nvimHome}/init.lua".source = ./files/init.lua;
        "${config}/options.lua".source = ./files/config/options.lua;
        "${config}/keymaps.lua".source = ./files/config/keymaps.lua;

        # Plugins configurations
        "${plugins}/colorscheme.lua".source = ./files/plugins/colorscheme.lua;
        "${plugins}/editor.lua".source = ./files/plugins/editor.lua;
        "${plugins}/git.lua".source = ./files/plugins/git.lua;
        "${plugins}/coding.lua".source = ./files/plugins/coding.lua;
      };

    home.sessionVariables = mkIf cfg.defaultEditor {
      EMACS = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "nvim";
    };
  };
}
