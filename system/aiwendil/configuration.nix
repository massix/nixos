{ pkgs, stateVersion, ... }:
{
  time.timeZone = "Europe/Paris";
  system.stateVersion = stateVersion;

  environment.systemPackages = with pkgs; [ git fish ];
  programs.fish.enable = true;
  programs.ssh.startAgent = true;

  users.mutableUsers = false;
  users.users.massi = {
    shell = pkgs.fish;
    extraGroups = [ "docker" ];
    hashedPassword = "$y$j9T$Usa07KG1XNs7krJp28.X2/$auAn/IOZjlCsxh.U2MJjL8ubqDk9UQjGUtVP5aDt.R.";
    isNormalUser = true;
  };

  virtualisation.docker.enable = true;

  services.openssh = {
    enable = true;
    package = pkgs.openssh;
    listenAddresses = [
      { addr = "0.0.0.0"; port = 4222; }
    ];
    authorizedKeysInHomedir = true;
    banner = ''
                 Welcome to
                                              _     _
              _                              ( ) _ (_ )
        _ _ (_) _   _   _    __    ___     _| |(_) | |
      /'_` )| |( ) ( ) ( ) /'__`\/' _ `\ /'_` || | | |
      ( (_| || || \_/ \_/ |(  ___/| ( ) |( (_| || | | |
      `\__,_)(_)`\___x___/'`\____)(_) (_)`\__,_)(_)(___)

                      WSL2 NixOS Box - github:massix/nixos
    '';
  };

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
