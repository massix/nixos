{ pkgs }:
let
  inherit (pkgs) callPackage stdenv;
  pythonPackages = pkgs.python3Packages;

  # Recent nixpkgs versions ship mcp 2.x and mark fastmcp-slim broken, because
  # fastmcp 3.4.x is not compatible with mcp 2.  nixpkgs keeps the 1.x line as
  # `mcp_1`; force both fastmcp and mcp-atlassian onto it so the closure
  # contains only one `mcp`.
  mcpCompat =
    pythonPackages.mcp_1 or (
      if pkgs.lib.versionOlder pythonPackages.mcp.version "2" then
        pythonPackages.mcp
      else
        throw "mcp-atlassian needs mcp < 2, but this nixpkgs has no mcp_1"
    );

  fastmcpCompat =
    if pythonPackages ? fastmcp-slim then
      pythonPackages.fastmcp.override
        {
          fastmcp-slim = pythonPackages.fastmcp-slim.override { mcp = mcpCompat; };
        }
    else
      pythonPackages.fastmcp;

  onlyLinuxPkgs = {
    custom-kernel = callPackage ./kernel { };
  };
  commonPkgs = {
    lumo-tamer = callPackage ./lumo-tamer { };
    tanzu = callPackage ./tanzu { };
    tridentctl = callPackage ./tridentctl { };
  };
  # mcp-atlassian's dependency tree (arrow-cpp) is broken on x86_64-darwin in
  # the pinned nixpkgs.  The hackintosh config overrides the opencode module's
  # mcp-atlassian-package option with a stub; exclude it from the flake packages
  # output so `nix flake check` does not trip over the broken dependency.
  atlassianPkgs = pkgs.lib.optionalAttrs (stdenv.system != "x86_64-darwin") {
    mcp-atlassian = callPackage ./mcp-atlassian {
      inherit (pkgs) fetchFromGitHub fetchPypi;
      inherit (pythonPackages) buildPythonApplication;
      inherit (pythonPackages) anyio atlassian-python-api beautifulsoup4 cachetools click fakeredis httpx keyring markdown markdownify pydantic python-dateutil python-dotenv requests starlette thefuzz trio truststore types-python-dateutil unidecode urllib3 uvicorn hatchling setuptools uv-dynamic-versioning cattrs lxml orjson pymdown-extensions pyyaml;
      fastmcp = fastmcpCompat;
      mcp = mcpCompat;
    };
  };
in
if stdenv.hostPlatform.isLinux then (onlyLinuxPkgs // commonPkgs // atlassianPkgs) else (commonPkgs // atlassianPkgs)
