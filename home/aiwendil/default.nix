{ pkgs
, username
, ...
}:
let
  load-ssh-key = pkgs.writeScriptBin "load-ssh-key" ''
    #!${pkgs.bash}/bin/bash

    RESCUE_PASSPHRASE="$(cat /home/${username}/.ssh/rescuep)"

    ${pkgs.expect}/bin/expect <<EOF
      spawn ssh-add /home/${username}/.ssh/rescue
      expect "Enter passphrase"
      send "$RESCUE_PASSPHRASE\r"
      expect eof
    EOF
  '';
in
{
  my-modules = {
    fonts = {
      enable = true;
      typefonts = false;
    };

    gleeter.enable = true;

    kitty = {
      enable = true;
      font = {
        name = "Comic Mono";
        size = 15;
        italic = "0xProto Italic";
        packages = with pkgs; [
          comic-mono
          _0xproto
          noto-fonts-emoji
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
      vault.enable = true;
      azure-cli.enable = false;
      ansible.enable = true;
      terraform = {
        enable = true;
        flavour = "terraform";
      };
      kubernetes = {
        enable = true;
        colored = true;
      };
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

    # No configuration needed since I use this only to Multiplex from Windows
    wezterm.enable = true;

    home-manager.enable = true;
  };

  homeage.file.avp = {
    source = ./secrets/avp.age;
    symlinks = [ "/home/${username}/.ansible-vault-password" ];
  };

  home.packages = with pkgs; [
    just
    xdg-utils
    load-ssh-key
  ];

  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      vault_password_file = /home/${username}/.ansible-vault-password
      host_key_checking = false

      [inventory]
      enable_plugins = vmware_vm_inventory, yaml
    '';
  };

  home.sessionVariables = {
    ANSIBLE_CONFIG = "/home/${username}/.ansible.cfg";
    ANSIBLE_VAULT_PASSWORD_FILE = "/home/${username}/.ansible-vault-password";
    GITLAB_VIM_URL = "https://git.questel.com";
  };

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
