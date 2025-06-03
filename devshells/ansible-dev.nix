# INFO: This shell is used to test the community.general Ansible Collection, but may be used
# as a generic shell for other collections too.
{ pkgs }:
with pkgs;
mkShell {
  packages =
    let
      inherit (pkgs.python3Packages) buildPythonPackage;
      dependency_groups = buildPythonPackage rec {
        pname = "dependency_groups";
        version = "1.3.1";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          owner = "sirosen";
          repo = "dependency-groups";
          tag = version;
          hash = "sha256-suuSx3zf0Y45FJdH8Cb6N7hcvPnzleREpHhtdiG2CLg=";
        };

        build-system = [ pkgs.python3Packages.flit-core ];

        dependencies = with pkgs.python3Packages; [
          packaging
        ];

        doCheck = true;
      };
      new-nox = buildPythonPackage rec {
        pname = "nox";
        version = "2025.02.09";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          owner = "wntrblm";
          repo = "nox";
          tag = version;
          hash = "sha256-aLY90bSIQLKo+ige4Hw4GX8Tl4ObKqkHzOIgsHXLBwA=";
        };

        build-system = [ pkgs.python3Packages.hatchling ];

        dependencies = with pkgs.python3Packages; [
          argcomplete
          colorlog
          packaging
          virtualenv
          attrs
          dependency_groups
        ];

        doCheck = false;
      };
      antsibull-fileutils = buildPythonPackage rec {
        pname = "antsibull-fileutils";
        version = "1.2.0";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          repo = "antsibull-fileutils";
          owner = "ansible-community";
          tag = version;
          hash = "sha256-Rc4fmXhfhsT9u/5SW0sfwE1k7od785mFC/D0O1TRdsg=";
        };

        build-system = [ pkgs.python3Packages.hatchling ];
        dependencies = with pkgs.python3Packages; [
          aiofiles
          pyyaml
        ];

        doCheck = false;
      };
      antsibull-nox = buildPythonPackage {
        pname = "antsibull-nox";
        version = "2025-06-02-unstable";
        pyproject = true;

        src = pkgs.fetchFromGitHub {
          repo = "antsibull-nox";
          owner = "ansible-community";
          rev = "3845a7a";
          hash = "sha256-lfIfgLUK5zq2VMkQP+o+LDQHit3/QQH/WPoGkQyKHIA=";
        };

        build-system = [ pkgs.python3Packages.hatchling ];
        dependencies = with pkgs.python3Packages; [
          antsibull-fileutils
          packaging
          new-nox
          pydantic
          pyyaml
          semantic-version
        ];

        doCheck = false;
      };
      # INFO: these packages will be overridden during unit tests by nox, but they
      # are still useful for LSP and quick testing so I am keeping them here.
      pythonPackages = with pkgs.python312Packages; [
        ansible
        ansible-core
        python-gitlab
        requests
        pytest
        httmock
        new-nox
        redis
        python-memcached
        linode
        linode-api
        PyGithub
        lxml
        semantic-version
        datadog
        elastic-apm
        dnspython
        passlib
        proxmoxer
        paramiko
        python-nomad
        python-jenkins
        jsonpatch
      ];
    in
    [ python312 antsibull-nox ] ++ pythonPackages;
}
