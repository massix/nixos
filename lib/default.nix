{ home-manager
, nixpkgs
, homeage
, ...
}: {
  mkHome =
    { inputs, pkgs, stateVersion, username, system, extraModules ? [ ] }: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit stateVersion username system; };

      modules =
        let
          inherit (pkgs.stdenv) isDarwin;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
        in
        [
          # The following is true for all users
          ({ config, ... }: {
            nix = {
              nixPath = [ "nixpkgs=${inputs.nixpkgs})" ];
              settings = {
                experimental-features = [ "nix-command" "flakes" ];
                keep-outputs = true;
                keep-derivations = true;
                warn-dirty = true;
              };
              registry = {
                nixpkgs = {
                  from = {
                    id = "nixpkgs";
                    type = "indirect";
                  };
                  to = {
                    owner = "nixos";
                    repo = "nixpkgs";
                    type = "github";
                  };
                };
              };

              package = pkgs.nix;
            };
            home = {
              inherit username homeDirectory stateVersion;
              activation.report-changes = config.lib.dag.entryAnywhere ''
                ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
              '';
            };

            homeage = {
              pkg = pkgs.rage;
              identityPaths = [ "${homeDirectory}/.age/key.txt" ];
              mount = if isDarwin then "${homeDirectory}/secrets" else "/run/user/$UID/secrets";
              installationType = if isDarwin then "activation" else "systemd";
            };
          })
          homeage.homeManagerModules.homeage
          ../home/modules/secrets
          ../home/modules/neovim
          ../home/modules/zellij
          ../home/modules/taskwarrior
          ../home/modules/fish.nix
          ../home/modules/fonts.nix
          ../home/modules/im.nix
          ../home/modules/git.nix
          ../home/modules/gaming.nix
          ../home/modules/devops.nix
          ../home/modules/kitty.nix
          ../home/modules/gleeter.nix
          ../home/modules/firefox.nix
          ../home/modules/ghostty.nix
          ../home/modules/opencode.nix
        ] ++ extraModules;
    };

  mkSystem =
    { pkgs, stateVersion, system, extraModules ? [ ] }:
    nixpkgs.lib.nixosSystem {
      inherit pkgs system;
      specialArgs = { inherit stateVersion; };
      modules = [
        # This nix configuration applies to all systems
        {
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
              trusted-users = [ "root" "massi" "mgengarelli" ];
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
        }
      ] ++ extraModules;
    };
}
