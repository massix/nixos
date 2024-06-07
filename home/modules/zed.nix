{ pkgs
, lib
, config
, ...
}:
let
  cfg = config.my-modules.zed;
  inherit (lib) mkEnableOption mkOption mkIf types;
  jsonGenerator = lib.generators.toJSON { };
in
{
  options.my-modules.zed = {
    enable = mkEnableOption "zed editor";
    settings = {
      theme = mkOption { type = types.str; default = "Catppuccin Mocha"; };
      ui_font_size = mkOption { type = types.number; default = 15; };
      buffer_font_size = mkOption { type = types.number; default = 15; };
      buffer_font_family = mkOption { type = types.str; default = "Fira Code"; };
      active_pane_magnification = mkOption { type = types.number; default = 1.25; };
      vim_mode = mkOption { type = types.bool; default = true; };
      relative_line_numbers = mkOption { type = types.bool; default = true; };
      inlay_hints = {
        enabled = mkOption { type = types.bool; default = true; };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zed-editor
      tree-sitter-grammars.tree-sitter-hcl
    ];

    xdg.configFile."zed/settings_nix.json".text = jsonGenerator ({
      lsp = {
        vscode-json-language-server = {
          command = "vscode-json-language-server";
          arguments = [ "--stdio" ];
        };
      };
      languages = {
        JSON = { language_servers = [ "vscode-json-language-server" ]; };
        Terraform = { language_servers = [ "terraform-ls" ]; };
        Go = { language_servers = [ "gopls" ]; };
      };
    } // cfg.settings);
  };
}
