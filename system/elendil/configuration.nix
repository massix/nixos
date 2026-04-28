# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs
, stateVersion
, lib
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # NVD Diffing tool
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [pkgs.nix pkgs.nvd]}
    ${lib.getExe pkgs.nvd} diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking = {
    hostName = "elendil";
    nameservers = [ "1.1.1.1" "8.8.4.4" "8.8.8.8" ];
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };

    resolvconf.enable = true;
    firewall.enable = false;
  };

  services.resolved.enable = false;

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

  # Enable the KDE Desktop Environment
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

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
    settings.Login = {
      HandlePowerKey = "suspend-then-hibernate";
      HandleLidSwitch = "suspend-then-hibernate";
      HandleSuspendKey = "suspend-then-hibernate";
      HandleHibernateKey = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandleLidSwitchDocked = "ignore";
    };
  };

  systemd.sleep.settings.Sleep =
    let
      bool-value = b: if b then "yes" else "no";
    in
    {
      AllowSuspend = bool-value true;
      AllowHibernation = bool-value true;
      AllowSuspendThenHibernate = bool-value true;
      HibernateDelaySec = "30min";
      HibernateLocation = "/var/lib/swapfile";
      SuspendMode = "s2idle";
    };

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
      jq
      htop
      bat
      nil
      ripgrep
      file
      cntr
      fish
      cachix

      # KDE Specific Packages
      kdePackages.kcalc
      kdePackages.discover
      kdePackages.sddm-kcm
      kdePackages.isoimagewriter
      kdePackages.kcharselect
      kdePackages.kaccounts-integration
      kdePackages.kaccounts-providers

      # Dolphin Integrations
      kdePackages.kio
      kdePackages.kio-gdrive
      kdePackages.kio-admin
      kdePackages.kio-fuse

      # Online Accounts
      libsForQt5.qoauth
      libsForQt5.signond

      # Other stuff
      wayland-utils
      wl-clipboard
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GTK_IM_MODULE = "simple";
      QT_IM_MODULE = "simple";
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

    kdeconnect = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
    };

    kde-pim = {
      enable = true;
      kontact = true;
      kmail = false;
      merkuro = true;
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
  };

  system = { inherit stateVersion; };
}
