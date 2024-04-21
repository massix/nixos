{ home-manager
, nixpkgs
, homeage
, ...
}: {
  mkHome =
    { pkgs, stable, master, stateVersion, username, extraModules ? [ ] }: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit stable master stateVersion username; };

      modules = [
        homeage.homeManagerModules.homeage
        ../home/modules/base
        ../home/modules/neovim
        ../home/modules/zellij
        ../home/modules/helix.nix
        ../home/modules/fish.nix
        ../home/modules/fonts.nix
        ../home/modules/im.nix
        ../home/modules/git.nix
        ../home/modules/coding.nix
        ../home/modules/gaming.nix
        ../home/modules/devops.nix
      ] ++ extraModules;
    };

  mkSystem =
    { pkgs, stable, stateVersion, system, extraModules ? [ ] }:
    nixpkgs.lib.nixosSystem {
      inherit pkgs system;
      specialArgs = { inherit stable stateVersion; };
      modules = extraModules;
    };
}
