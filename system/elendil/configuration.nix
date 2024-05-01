# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs
, stateVersion
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Basic Nix configuration
  nix = {
    gc.automatic = true;
    gc.options = "--delete-older-than 10d";
    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = true;
      trusted-users = [ "root" "massi" ];
    };
  };

  # Enable networking
  networking = {
    hostName = "elendil";
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
    };

    resolvconf.enable = false;
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  services.keyd = {
    enable = true;
    keyboards = {
      gaming = {
        ids = [ "1ea7:0907" ];
        settings = {
          main = {
            leftcontrol = "overload(control, esc)";
          };
        };
      };
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };

  services.fwupd = {
    enable = true;
    package = pkgs.fwupd;
    daemonSettings = {
      EspLocation = "/boot";
      TestDevices = false;
      OnlyTrusted = false;
    };
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    package = pkgs.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      StrictModes = false;
      AllowUsers = [ "massi" ];
    };
    banner = ''
      You are now on the NixOS box. Be careful!
    '';
    allowSFTP = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.massi = {
    isNormalUser = true;
    description = "Massimo Gengarelli";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "surface-control"
      "video"
      "vboxusers"
    ];
    shell = pkgs.fish;
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      curl
      helix
      jq
      htop
      bat
      nil
      ripgrep
      file
      cntr
      fish
      cachix
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    shells = with pkgs; [
      bash
      zsh
      fish
    ];
  };

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = _: with pkgs; [ hidapi ];
      };
    };

    dconf.enable = true;
    zsh.enable = false;
    fish.enable = true;
    command-not-found.enable = false;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
  ];

  virtualisation = {
    docker = {
      enable = true;
      listenOptions = [ "unix:///var/run/docker.sock" "tcp://0.0.0.0:2375" ];
      daemon.settings = {
        bip = "172.29.0.1/24";
        default-address-pools = [
          { base = "172.30.0.0/16"; size = 24; }
          { base = "172.31.0.0/16"; size = 24; }
        ];
      };
    };

    virtualbox.host = {
      enable = true;
      enableKvm = true;
      enableExtensionPack = true;
      enableHardening = false;
      addNetworkInterface = false;
    };
  };

  system = { inherit stateVersion; };
}
