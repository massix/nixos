homeDirectory:
let
  publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgacv9J7WxKJS8mXZ9DwycMFWnuwOP7y9Nsf7ncrD9ZlZxAY3NDBgi+UdAgSnnWNXCX4aVeT1RtMmU3KQq0x6iscS/DLirIjyUPmeDvBTnCaQJ+9do3VXDg1z6N2Pua7E3dfDRV+y26YbHrPW2rBSox2Zbohrx6GQruuw0eHEoZ5ZBfc4yHONXohq0oGV0ttCbEAZejEakAFu+V2EIYTfhi039d9qTUIVrAlsTfEM8rIgU+ctFPub8jA4KoZJ4OTjwaQOYFohsTfioU5B1RgI6/lmWHdgPygWjG+Z0414PDmdQ/CnZCQ1yJ2Pt1M6chIfSCs2ighTQ9GnpIflkIodx massi";
in
{
  home.file = {
    ".ssh/id_rsa.pub".text = ''
      ${publicKey}
    '';
    ".ssh/authorized_keys".text = ''
      ${publicKey}
    '';
  };

  homeage.file = {
    "idrsa" = {
      source = ./secrets/id_rsa.age;
      symlinks = [ "${homeDirectory}/.ssh/id_rsa" ];
    };

    "sshconfig" = {
      source = ./secrets/ssh_config.age;
      symlinks = [ "${homeDirectory}/.ssh/config" ];
    };
  };
}
