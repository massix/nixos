{ pkgs
, config
, username
, ...
}:
let
  inherit (pkgs) lib stdenv stdenvNoCC;
  inherit (config.home) homeDirectory;
  load-ssh-key = pkgs.writeScriptBin "load-ssh-key" ''
    #!${lib.getExe pkgs.bash}

    RESCUE_PASSPHRASE="$(cat ${homeDirectory}/.ssh/rescuep)"

    ${lib.getExe pkgs.expect} <<EOF
        spawn ssh-add ${homeDirectory}/.ssh/rescue
        expect "Enter passphrase"
        send "$RESCUE_PASSPHRASE\r"
        expect eof
    EOF

    ssh-add ${homeDirectory}/.ssh/mgengarelli
  '';
  macpass = assert stdenv.isDarwin && stdenv.isAarch64;
    stdenvNoCC.mkDerivation rec {
      pname = "macpass";
      version = "0.8.1";

      nativeBuildInputs = [ pkgs.unzip ];

      src = builtins.fetchurl {
        url = "https://github.com/MacPass/MacPass/releases/download/${version}/MacPass-${version}.zip";
        sha256 = "sha256:0wxifcl4klvkdllalmpwixv5z6wnwmsfpcbrzv0w0hjvjkf3n39d";
      };

      sourceRoot = ".";
      dontBuild = true;
      doCheck = false;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications/
        cp -a *.app "$out/Applications/"

        runHook postInstall
      '';
    };
  tana = assert stdenv.isDarwin;
    stdenvNoCC.mkDerivation rec {
      pname = "tana";
      version = "1.0.24";
      nativeBuildInputs = [ pkgs.undmg ];

      src = builtins.fetchurl {
        url = "https://github.com/tanainc/tana-desktop-releases/releases/download/v${version}/Tana-${version}-universal.dmg";
        sha256 = "sha256:0jnm0drjpyj3mwd4yznvddvad5x80jjk1lgzv6np15i1f916mhfm";
      };

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/
        cp -a *.app $out/Applications/
        runHook postInstall
      '';
    };
  ghostty = assert stdenv.isDarwin;
    stdenvNoCC.mkDerivation rec {
      pname = "ghostty";
      version = "1.1.3";
      nativeBuildInputs = [ pkgs._7zz ];

      src = builtins.fetchurl {
        url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
        sha256 = "sha256:0ir69yhqia8yj2i750g2aklk7wr9vzwbdp6ncvqri5aliwc19rb4";
      };

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/
        cp -a *.app $out/Applications/
        runHook postInstall
      '';
    };
in
{
  my-modules = {
    firefox = {
      enable = true;
      extraExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
      ];
      extraEngines = {
        Jira = {
          urls = [{ template = "https://jira.questel.com/browse/{searchTerms}"; }];
          definedAliases = [ "@jira" ];
        };
      };
    };
    fonts = {
      enable = true;
    };
    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };
    ghostty =
      let
        add-plus = l: builtins.map (x: "+${x}") l;
        to-font-feature = l: builtins.concatStringsSep "," (add-plus l);
      in
      {
        enable = true;
        package = ghostty;
        extraSettings = {
          font-family = "Maple Mono";
          font-size = "12";
          font-feature = to-font-feature [
            "calt" # ligatures
            "cv03" # alternative i
            "cv05" # alternative g
            "cv64" # alternative &
            "ss03" # [INFO] and other arbitrary tags
            "ss08" # >>= ligature
            "ss09" # alternative ~=
            "ss10" # alternative =~
            "ss11" # alternative |=
          ];
          window-height = "65";
          window-width = "190";
        };
        extraPackages = with pkgs; [
          _0xproto
          noto-fonts-emoji
          maple-mono.truetype
        ];
      };
    kitty = {
      enable = true;
      font = {
        name = "0xProto";
        italic = "auto";
        bold = "auto";
        size = 12;
        packages = with pkgs; [
          _0xproto
          noto-fonts-emoji
        ];
      };
      extraSettings = {
        macos_option_as_alt = "left";
        macos_quit_when_last_window_closed = true;
        macos_traditional_fullscreen = false;
        background_blur = 64;
        initial_window_width = "190c";
        initial_window_height = "65c";
      };
    };
    fish = {
      enable = true;
      configuration.extraShellAbbrs = {
        tp = "task rc.data.location=~/OneDrive/TaskWarrior";
        j = "just";
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
    gleeter.enable = true;
    taskwarrior = {
      enable = true;
      withJira = true;
      withFish = true;
      dataLocation = "~/OneDrive - QUESTEL/TaskWarrior";
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

        whitelist.prefix = [
          "${homeDirectory}/dev"
          "${homeDirectory}/Development"
          "${homeDirectory}/.config/nvim"
          "${homeDirectory}/.config/nixos"
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
      symlinks = [ "${homeDirectory}/.ansible-vault-password" ];
    };
  };

  home.packages = with pkgs; [
    # This does not come installed by default on MacOS
    gcc
    load-ssh-key
    gleeter
    docker
    lima
    colima
    macpass
    tana
  ];

  home.sessionVariables = {
    K9S_CONFIG_DIR = "${homeDirectory}/.config/k9s";
    ANSIBLE_CONFIG = "${homeDirectory}/.ansible.cfg";
    ANSIBLE_VAULT_PASSWORD_FILE = "${homeDirectory}/.ansible-vault-password";
  };

  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      vault_password_file = ${homeDirectory}/.ansible-vault-password
      host_key_checking = false

      [inventory]
      enable_plugins = vmware_vm_inventory, yaml
    '';
  };

  launchd.enable = true;
  launchd.agents =
    let
      binPath = lib.getExe pkgs.colima;
      inherit (lib) optional;
      mkColimaAgent =
        { enable ? true
        , numCpus ? 8
        , memory ? 8
        , vmType ? "vz"
        , maxCpu ? false
        , arch
        , profileName
        }: {
          inherit enable;
          config = {
            ProgramArguments = [
              "${binPath}"
              "start"
              "--foreground"
              "--cpu=${builtins.toString numCpus}"
              "--memory=${builtins.toString memory}"
              "--arch=${arch}"
              "--vm-type=${vmType}"
              "--profile=${profileName}"
            ]
            ++ optional (vmType == "vz") "--vz-rosetta"
            ++ optional maxCpu "--cpu-type=max";

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
        enable = false;
        arch = "aarch64";
        memory = 4;
        numCpus = 2;
        profileName = "aarch64";
      };
      "colima-x86_64" = mkColimaAgent {
        enable = true;
        arch = "x86_64";
        memory = 14;
        numCpus = 8;
        maxCpu = true;
        profileName = "x86_64";
      };
    };

  nix = {
    gc.automatic = true;
    gc.options = "--delete-older-than 10d";
    settings = {
      auto-optimise-store = false;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = true;
      trusted-users = [ "root" username ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "surface-zen.cachix.org-1:8OXCpyGHk4UL+BDkgJYW1bGf/ULbNGKLiBjaTELJwaQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://surface-zen.cachix.org"
        "https://cache.nixos.org"
      ];
    };
  };

  xdg.configFile."fish/functions/kcon.fish".source = ./files/kcon.fish;
}
