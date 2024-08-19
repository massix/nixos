{ pkgs
, ...
}:
{
  my-modules = {
    coding = {
      enable = true;
      languages = {
        go = true;
        json = true;
        lua = true;
        nix = true;
        scripting = true;
        terraform = true;
        yaml = true;
        misc = true;
      };
    };

    fish = {
      enable = true;
    };

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      gui.enable = false;
    };

    git = {
      enable = true;
      workRepository = {
        enabled = true;
        workRoot = "~/Development/Work/";
        workEmail = "mgengarelli@questel.com";
      };
    };

    devops = {
      enable = true;
      k9s.enable = true;
      azure-cli.enable = false;
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = let home = "/home/massi"; in [
          "${home}/dev"
          "${home}/Development"
          "${home}/.config/nvim"
          "${home}/.config/nixos"
        ];
      };
    };

    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    just
  ];

  systemd.user.startServices = "sd-switch";
}
