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
      stylua
      gcc
      wl-clipboard

      # Some common language servers I don't want to install through devShells
      lua-language-server
      yaml-language-server
      nodePackages.vscode-json-languageserver-bin
      nixd-nightly
      nil
    ];

    # Link needed files, we cannot link the whole directory or lazyVim won't work
    home.file =
      let
        nvimHome = ".config/nvim";
        plugins = "${nvimHome}/lua/plugins";
      in
      {
        "${nvimHome}/lua/util/nix.lua".text = ''
          -- Some variables that are injected automatically by nix
          return {
            nvimHome = "${nvimHome}"
          }
        '';

        "${nvimHome}/lua/util/defaults.lua".source = ./files/util_defaults.lua;

        "${nvimHome}/init.lua".source = ./files/init.lua;
        "${nvimHome}/lua/config/options.lua".source = ./files/config_options.lua;
        "${nvimHome}/lua/config/keymaps.lua".source = ./files/config_keymaps.lua;

        "${plugins}/colorscheme.lua".source = ./files/plugins_colorscheme.lua;
        "${plugins}/editor.lua".source = ./files/plugins_editor.lua;
        "${plugins}/git.lua".source = ./files/plugins_git.lua;
      };

    home.sessionVariables = mkIf cfg.defaultEditor {
      EMACS = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "nvim";
    };
  };
}
