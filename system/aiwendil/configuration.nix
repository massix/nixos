{ pkgs, wsl, stateVersion, ... }:
{

  # Basic Nix configuration
  # TODO: put this into a shared module
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

  time.timeZone = "Europe/Paris";
  system.stateVersion = stateVersion;

  environment.systemPackages = with pkgs; [ git fish ];
  programs.fish.enable = true;

  users.users.massi = {
    shell = pkgs.fish;
    extraGroups = [
      "docker"
    ];
  };

  virtualisation.docker.enable = true;

  wsl =
    let
      user = "massi";
    in
    {
      enable = true;
      defaultUser = user;

      wslConf = {
        network.hostname = "aiwendil";
        user.default = user;
      };
    };

}
