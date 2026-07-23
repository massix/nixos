{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  pythonPackages = pkgs.python3Packages;
  onlyLinuxPkgs = {
    custom-kernel = callPackage ./kernel { };
  };
  commonPkgs = {
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
    mcp-atlassian = callPackage ./mcp-atlassian {
      inherit (pkgs) fetchFromGitHub fetchPypi;
      inherit (pythonPackages) buildPythonApplication;
      inherit (pythonPackages) anyio atlassian-python-api beautifulsoup4 cachetools click fakeredis fastmcp httpx keyring markdown markdownify mcp pydantic python-dateutil python-dotenv requests starlette thefuzz trio truststore types-python-dateutil unidecode urllib3 uvicorn hatchling setuptools uv-dynamic-versioning cattrs lxml orjson pymdown-extensions pyyaml;
    };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs) else commonPkgs
