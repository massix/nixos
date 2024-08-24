{ pkgs, stateVersion, ... }:
{
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
      useWindowsDriver = true;

      wslConf = {
        network.hostname = "aiwendil";
        user.default = user;
      };
    };

}
