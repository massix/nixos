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

  # Enable networking
  networking = {
    hostName = "elendil";
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      plugins = with pkgs; [
        networkmanager-openconnect
      ];
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

  # Enable the COSMIC Desktop Environment.
  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;
  services.flatpak.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      tapping = true;
      clickMethod = "clickfinger";
      accelProfile = "adaptive";
      sendEventsMode = "enabled";
    };
  };

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

  services.logind = {
    powerKey = "suspend-then-hibernate";
    lidSwitch = "suspend-then-hibernate";
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=${builtins.toString (3600 * 4)}
    HibernateLocation=/var/lib/swapfile
  '';

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplipWithPlugin ];
  };

  services.avahi.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

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
      MaxAuthTries = 3;
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
      "scanner"
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

    # Make disable-while-typing work again
    etc."libinput/local-overrides.quirks".text = ''
      [keyd]
      MatchUdevType=keyboard
      MatchVendor=0xFAC
      AttrKeyboardIntegration=internal

      [Microsoft Surface Laptop Studio Touchpad]
      MatchVendor=0x045E
      MatchProduct=0x09AF
      MatchUdevType=touchpad
      AttrPressureRange=25:10
      AttrPalmPressureThreshold=500
    '';
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
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
  };

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
      enableKvm = false;
      enableExtensionPack = true;
      enableHardening = false;
      addNetworkInterface = false;
    };
  };

  system = { inherit stateVersion; };
}
