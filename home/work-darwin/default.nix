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
        cp -a "MacPass.app" "$out/Applications/"

        runHook postInstall
      '';
    };
  windsurf = assert stdenv.isDarwin && stdenv.isAarch64;
    stdenvNoCC.mkDerivation rec {
      pname = "windsurf";
      version = "1.0.7";

      nativeBuildInputs = [ pkgs.undmg ];

      src = builtins.fetchurl {
        url = "https://windsurf-stable.codeiumdata.com/darwin-arm64-dmg/stable/bf4345439764c543a1e5ff3517bbce5a22128bca/Windsurf-darwin-arm64-${version}.dmg";
        sha256 = "sha256:1n5m3avmprvb1lyggdahbqgmwkqxiffjl5gqxg49p6f0rdnv0z49";
      };

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications/
        cp -a "Windsurf.app" $out/Applications/

        mkdir -p $out/bin
        ln -s "$out/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf" "$out/bin/windsurf"

        runHook postInstall
      '';

      # The code from Windsurf is signed, so we cannot manipulate it
      dontFixup = true;

      meta = with lib; {
        description = "Windsurf IDE by Codeium";
        homepage = "https://www.codeium.com/";
        platforms = [ "aarch64-darwin" ];
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        license = licenses.unfree;
      };
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
in
{
  my-modules = {
    fonts = {
      enable = true;
    };
    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };
    kitty = {
      enable = true;
      font = {
        name = "Recursive Mono Casual Static";
        italic = "auto";
        bold = "auto";
        size = 12;
        packages = with pkgs; [
          comic-mono
          _0xproto
          noto-fonts-emoji
          recursive
          (google-fonts.override {
            fonts = [
              "SyneMono"
              "JetBrainsMono"
              "NovaMono"
            ];
          })
        ];
      };
      extraSettings = {
        macos_option_as_alt = "left";
        macos_quit_when_last_window_closed = true;
        macos_traditional_fullscreen = false;
        background_blur = 64;
      };
    };
    fish = {
      enable = true;
    };
    coding = {
      enable = true;
      languages = {
        ansible = true;
        gleam = true;
        go = true;
        haskell = true;
        javascript = true;
        json = true;
        lua = true;
        misc = true;
        nix = true;
        purescript = true;
        scripting = true;
        terraform = true;
        yaml = true;
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
    zed-editor = {
      enable = true;
      extraPackages = with pkgs; [
        gitlab-ci-ls
        terraform-ls
        ansible-language-server
        nixd
        docker-ls
        gleam
        helm-ls
        nginx-language-server
      ];
      extensions = [
        "ansible"
        "catppuccin"
        "catppuccin-blur"
        "catppuccin-blur-plus"
        "catppuccin-icons"
        "dockerfile"
        "fish"
        "gitlab-ci-ls"
        "gleam"
        "helm"
        "jinja2"
        "lua"
        "make"
        "nginx"
        "nix"
        "terraform"
      ];
      userSettings = {
        ui_font_size = 14;
        buffer_font_size = 13;
        buffer_font_family = "Rec Mono Casual";
        buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];
        autosave = "on_window_change";
        theme = "Catppuccin Macchiato (Blue Blur+)";
        terminal = {
          font_size = 12;
          font_family = "0xProto";
          font_fallbacks = [ "Symbols Nerd Font Mono" ];
        };
        file_types = {
          Jinja2 = [
            "*.j2"
            "**.j2"
          ];
          Ansible = [
            "**.ansible.yml"
            "**/defaults/**.yml"
            "**/defaults/**.yaml"
            "**/meta/**.yml"
            "**/meta/**.yaml"
            "**/tasks/**.yml"
            "**/tasks/*.yml"
            "**/tasks/*.yaml"
            "**/handlers/*.yml"
            "**/handlers/*.yaml"
            "**/group_vars/**.yml"
            "**/group_vars/**.yaml"
            "**playbook*.yaml"
            "**playbook*.yml"
          ];
        };
        languages = {
          Nix = {
            language_servers = [ "nixd" ];
            enable_language_server = true;
            formatter = {
              external.command = "nixpkgs-fmt";
            };
          };
        };
        lsp = {
          ansible-language-server = {
            settings = {
              ansible.path = "ansible";
              executionEnvironment.enabled = false;
              python.interpreterPath = "python3";
              validation = {
                enabled = true;
                lint.enabled = true;
                lint.path = "ansible-lint";
              };
            };
          };
        };
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
    windsurf
    spotify
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
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://surface-zen.cachix.org"
        "https://cache.nixos.org"
        "https://cosmic.cachix.org/"
      ];
    };
  };
}
