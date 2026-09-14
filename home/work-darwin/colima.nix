{ lib
, pkgs
, config
}:
{ enable ? true
, numCpus ? 8
, memory ? 8
, vmType ? "vz"
, maxCpu ? false
, diskSize ? 100
, mount ? true
, arch
, profileName
}: {
  inherit enable;
  config = {
    ProgramArguments = [
      "${lib.getExe pkgs.colima}"
      "start"
      "--foreground"
      "--cpu=${toString numCpus}"
      "--memory=${toString memory}"
      "--arch=${arch}"
      "--vm-type=${vmType}"
      "--profile=${profileName}"
      "--disk=${toString diskSize}"
    ]
    ++ lib.optionals mount [
      "--mount=${config.home.homeDirectory}/.certs/dockerregistry.prd.questel.fr:/etc/docker/certs.d/dockerregistry.prd.questel.fr:ro"
      "--mount=${config.home.homeDirectory}:w"
      "--mount=/tmp/colima:w"
    ]
    ++ lib.optional (vmType == "vz") "--vz-rosetta"
    ++ lib.optional maxCpu "--cpu-type=max";

    Label = "massix.colima.${profileName}";

    RunAtLoad = true;
    KeepAlive = true;

    EnvironmentVariables = {
      PATH = "${pkgs.colima}/bin:${pkgs.docker}/bin:/usr/bin/:/bin:/usr/sbin:/sbin";
    };
  };
}
