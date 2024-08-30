{ pkgs
, ...
}:
{
  my-modules = {
    fonts = {
      enable = true;
      typefonts = false;
    };

    kitty = {
      enable = true;
      font = {
        name = "Comic Mono";
        size = 15;
        italic = "0xProto Italic";
        packages = [
          pkgs.comic-mono
          pkgs._0xproto
        ];
      };
    };

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
        ansible = true;
      };
    };

    fish = {
      enable = true;
      configuration = {
        extraShellAbbrs = {
          j = "just";
          mk = "make";
        };
      };
    };

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      gui.enable = false;
    };

    zellij.enable = true;

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
      tanzu.enable = true;
      azure-cli.enable = false;
      ansible.enable = true;
      terraform = {
        enable = true;
        flavour = "terraform";
      };
      kubernetes.enable = true;
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

  home.packages = with pkgs; [ just xdg-utils gleeter ];

  systemd.user.startServices = "sd-switch";

  systemd.user.services.unisond = {
    Unit.Description = "Automatically synchronize org folder";

    Service = {
      ExecStart = "${pkgs.unison}/bin/unison -repeat watch -batch \${HOME}/org \${HOME}/org_onedrive";
      Restart = "on-abnormal";
      RestartSec = "3";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
