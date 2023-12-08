# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs
, stateVersion
, unstable
, ...
}:
let
  nameservers = [
    "94.140.14.15"
    "94.140.15.16"
  ];
in
{
  disabledModules = [
    "services/desktops/pipewire/pipewire.nix"
    "services/desktops/pipewire/wireplumber.nix"
  ];

  imports = [
    ./hardware-configuration.nix
    <nixos-unstable/nixos/modules/services/desktops/pipewire/pipewire.nix>
    <nixos-unstable/nixos/modules/services/desktops/pipewire/wireplumber.nix>
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
    };
  };

  # Enable networking
  networking = {
    hostName = "elendil";
    inherit nameservers;
    networkmanager = {
      enable = true;
      insertNameservers = nameservers;
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
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
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
    package = unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.massi = {
    isNormalUser = true;
    description = "Massimo Gengarelli";
    extraGroups = [ "networkmanager" "wheel" "docker" "surface-control" "video" ];
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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.zsh.enable = false;
  programs.fish.enable = true;
  programs.command-not-found.enable = false;

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

  virtualisation.docker = {
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

  system = { inherit stateVersion; };
}
