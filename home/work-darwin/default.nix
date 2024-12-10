{ pkgs
, username
, ...
}:
let
  inherit (pkgs) lib;
  load-ssh-key = pkgs.writeScriptBin "load-ssh-key" ''
    #!${lib.getExe pkgs.bash}

    RESCUE_PASSPHRASE="$(cat /Users/${username}/.ssh/rescuep)"

    ${lib.getExe pkgs.expect} <<EOF
        spawn ssh-add /Users/${username}/.ssh/rescue
        expect "Enter passphrase"
        send "$RESCUE_PASSPHRASE\r"
        expect eof
    EOF

    ssh-add /Users/${username}/.ssh/mgengarelli
  '';
in
{
  my-modules = {
    fonts = {
      enable = false;
    };
    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };
    kitty = {
      enable = true;
      font = {
        name = "Comic Mono";
        size = 13;
        italic = "0xProto Italic";
        packages = with pkgs; [
          comic-mono
          _0xproto
          noto-fonts-emoji
        ];
      };
      extraSettings = {
        macos_option_as_alt = "left";
        macos_quit_when_last_window_closed = true;
        background_blur = 64;
      };
    };
    fish = {
      enable = true;
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
      ansible.enable = true;
      tanzu.enable = true;
      vault.enable = true;
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
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = let home = "/Users/mgengarelli"; in [
          "${home}/dev"
          "${home}/Development"
          "${home}/.config/nvim"
          "${home}/.config/nixos"
        ];
      };
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };

  };

  homeage.file = {
    avp = {
      source = ./secrets/avp.age;
      symlinks = [ "/Users/${username}/.ansible-vault-password" ];
    };
  };

  home.packages = with pkgs; [
    # This does not come installed by default on MacOS
    gcc
    load-ssh-key
    gleeter
    docker
    colima
  ];

  home.sessionVariables = {
    K9S_CONFIG_DIR = "/Users/${username}/.config/k9s";
    ANSIBLE_CONFIG = "/Users/${username}/.ansible.cfg";
    ANSIBLE_VAULT_PASSWORD_FILE = "/Users/${username}/.ansible-vault-password";
  };

  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      vault_password_file = /Users/${username}/.ansible-vault-password
      host_key_checking = false

      [inventory]
      enable_plugins = vmware_vm_inventory, yaml
    '';
  };

  launchd.enable = true;
  launchd.agents =
    let
      binPath = lib.getExe pkgs.colima;
      mkColimaAgent =
        { enable ? true
        , numCpus ? 8
        , memory ? 8
        , arch ? "x86_64"
        , vmType ? "vz"
        , vzRosetta ? false
        , profileName
        }: {
          inherit enable;
          config = {
            ProgramArguments = [
              "${binPath}"
              "start"
              "--foreground"
              "--cpu"
              "${builtins.toString numCpus}"
              "--memory"
              "${builtins.toString memory}"
              "--arch"
              "${arch}"
              "--vm-type"
              "${vmType}"
              "--profile"
              "${profileName}"
            ] ++ (if vzRosetta then [ "--vz-rosetta" ] else [ ]);

            Label = "massix.colima.${profileName}";

            RunAtLoad = true;
            KeepAlive = true;

            EnvironmentVariables = {
              PATH = "${pkgs.colima}/bin:${pkgs.docker}/bin:/usr/bin/:/bin:/usr/sbin:/sbin";
            };
          };
        };
    in
    {
      "colima-aarch64" = mkColimaAgent {
        enable = true;
        arch = "aarch64";
        vzRosetta = false;
        memory = 4;
        numCpus = 2;
        profileName = "aarch64";
      };
      "colima-x86_64" = mkColimaAgent {
        enable = true;
        arch = "x86_64";
        vzRosetta = true;
        memory = 8;
        numCpus = 4;
        profileName = "x86_64";
      };
    };
}


