homeDirectory:
{
  home.file = {
    ".ssh/rescue.pub".text = ''
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5weLK941EgKVWPQQP6ZjloJrndc28/pKOhGPft5yqs";
    '';
    ".ssh/tanzu.pub".text = ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQQgtOgvxqH0ov0E+YNVLL/jlcWnJu/7I22SRLySFRfNaMRDaAI3PTnG9Vfzdn45w9H4q7zfmDQ6817kmAS+ojciSitoL7ePsQj/Ja8SfnaV5trT6WhakI1Ouu3TO/p53i6Z7YCsc7/nxRQ9eNW7o3aunDOZajF9qQfjabbKT1DOQfIRFbKOuDJgl8qYkq
      xksAkevmJzNh4fj+9pXCHO7uDaJoISU3BhPOeJiFc9SxqNo1oX7izQnKXDmyCKUqZdbqpgafUVhWIWT6fExVKPxUIir9F/v/yxrrbjMSKpL6lXDI45wWtgKEhNz2obh8TnE7ripOzMMNhIogiH5c/+ni2maVv+vQ6j51nxNluT9ywFyqsPR+IBeIZUCg7jiNXwwrz4r4y19PJtj82FfOcOHglpoGYLu2wT1K
      OTJnj+ihESpaTCVLQzrhCO3CDCI70PFUk0dhly4Y/6AxLH+4G4zWggcD07+1GSTeVXhmyrxT7poenjQ+XauiLNKf7Vo1W1TiunsprAscuz6dgGadyWLoiGuhw+oFv8PpQBGH4ROpbzsQ5AduxUcR4sOp5fkPvdFSEBddm4rRuPBSuBuWNc+Po/xSEOipYepfgf3qv+yKmSUPP16+UeWA9icJCzopIEygVOJa
      VsanZc5LKdiLJ2i/xPZje8ovhGrroUpaoSHAYQ==
    '';
    ".ssh/mgengarelli.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPXHh+tZRsY6tE0cmLntMofkWQrbx7sStJzjlQbbrLTv mgengarelli@aiwendil
    '';
  };

  homeage.file = {
    "rescue" = {
      source = ./secrets/rescue.age;
      symlinks = [ "${homeDirectory}/.ssh/rescue" ];
    };

    "rescuep" = {
      source = ./secrets/rescuep.age;
      symlinks = [ "${homeDirectory}/.ssh/rescuep" ];
    };

    "tanzu" = {
      source = ./secrets/tanzu.age;
      symlinks = [ "${homeDirectory}/.ssh/tanzu" ];
    };

    "mgengarelli" = {
      source = ./secrets/mgengarelli.age;
      symlinks = [ "${homeDirectory}/.ssh/mgengarelli" ];
    };
  };
}
