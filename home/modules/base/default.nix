{ stateVersion
, username
, unstable
, config
, ...
}: {
  home = {
    inherit stateVersion username;
    homeDirectory = "/home/${username}";
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${unstable.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';

    packages = [ unstable.age ];
  };

  homeage = {
    # This is true for all users, the file must exist
    identityPaths = [ "~/.age/key.txt" ];
    installationType = "systemd";
    pkg = unstable.rage;

    file = {
      "idrsa" = {
        source = ./secrets/id_rsa.age;
        symlinks = [ "/home/${username}/.ssh/id_rsa" ];
      };

      "sshconfig" = {
        source = ./secrets/ssh_config.age;
        symlinks = [ "/home/${username}/.ssh/config" ];
      };
    };
  };

  home.file = {
    ".ssh/id_rsa.pub".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgacv9J7WxKJS8mXZ9DwycMFWnuwOP7y9Nsf7ncrD9ZlZxAY3NDBgi+UdAgSnnWNXCX4aVeT1RtMmU3KQq0x6iscS/DLirIjyUPmeDvBTnCaQJ+9do3VXDg1z6N2Pua7E3dfDRV+y26YbHrPW2rBSox2Zbohrx6GQruuw0eHEoZ5ZBfc4yHONXohq0oGV0ttCbEAZejEakAFu+V2EIYTfhi039d9qTUIVrAlsTfEM8rIgU+ctFPub8jA4KoZJ4OTjwaQOYFohsTfioU5B1RgI6/lmWHdgPygWjG+Z0414PDmdQ/CnZCQ1yJ2Pt1M6chIfSCs2ighTQ9GnpIflkIodx massi
    '';
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = true;
    };

    package = unstable.nix;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

}
