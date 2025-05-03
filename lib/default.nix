{ home-manager
, nixpkgs
, homeage
, ...
}: {
  mkHome =
    { inputs, pkgs, stateVersion, username, system, extraModules ? [ ] }: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit stateVersion username system; };

      modules = [
        {
          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs})" ];
        }
        homeage.homeManagerModules.homeage
        ../home/modules/base
        ../home/modules/neovim
        ../home/modules/zellij
        ../home/modules/taskwarrior
        ../home/modules/fish.nix
        ../home/modules/fonts.nix
        ../home/modules/im.nix
        ../home/modules/git.nix
        ../home/modules/coding.nix
        ../home/modules/gaming.nix
        ../home/modules/devops.nix
        ../home/modules/zed.nix
        ../home/modules/kitty.nix
        ../home/modules/gleeter.nix
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

        # This also applies to all systems
        {
          programs.ssh.startAgent = true;
        }
      ] ++ extraModules;
    };
}
