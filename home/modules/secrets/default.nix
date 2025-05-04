{ username
, pkgs
, ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
  privateKeys = import ./priv-keys.nix homeDirectory;
  workKeys = import ./work-keys.nix homeDirectory;
  optWork = s: if isDarwin then s else { };
in
{
  home.packages = with pkgs; [ age rage ];
  home.file = privateKeys.home.file // (optWork workKeys.home.file);
  homeage.file = privateKeys.homeage.file // (optWork workKeys.homeage.file);
}

