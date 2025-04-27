{
  description = "Project developed using Gleam";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, self }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib stdenv;
      in
      {
        devShells.default = with pkgs; mkShell {
          packages = [
            gleam
            rebar3
            erlang
          ];

          shellHook = ''
            echo "Gleam development shell activated with following tools:"
            ${lib.getExe gleam} --version
            ${lib.getExe rebar3} --version
            ${erlang}/bin/erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell
          '';
        };

        packages.default =
          let
            pname = "package-name";
            version = "1.0.0";
            dependencies = stdenv.mkDerivation {
              pname = "${pname}-gleam-dependencies";
              inherit version;

              nativeBuildInputs = [ pkgs.gleam ];
              src = builtins.filterSource (path: _: builtins.elem (baseNameOf path) [ "manifest.toml" "gleam.toml" ]) ./.;

              buildPhase = ''
                mkdir -p $out
                HOME=$PWD gleam deps download
                grep -v '\[packages\]' build/packages/packages.toml | sort > packages.toml
                echo -e "[packages]\n" > build/packages/packages.toml
                cat packages.toml >> build/packages/packages.toml
                rm packages.toml
              '';

              installPhase = ''
                mkdir -p $out/build/
                cp --recursive build/packages $out/build/
              '';

              outputHashAlgo = "sha256";
              outputHashMode = "recursive";
              outputHash = lib.fakeHash;
            };
          in
          stdenv.mkDerivation {
            inherit pname version;
            src = builtins.filterSource
              (path: _: ! builtins.elem (baseNameOf path) [ "build" ".git" ".direnv" ".envrc" ])
              ./.;

            nativeBuildInputs = with pkgs; [ gleam rebar3 which dependencies ];
            buildInputs = with pkgs; [ erlang_27 ];

            doCheck = true;

            configurePhase = ''
              cp -r ${dependencies}/build build
              chmod -R 0755 build
            '';

            checkPhase = ''
              HOME=$PWD make test
            '';

            buildPhase = ''
              runHook preBuildHook
              HOME=$PWD make package
              runHook postBuildHook
            '';

            installPhase = ''
              runHook preInstallHook
              mkdir -p $out/opt/gleeter/
              mkdir -p $out/bin/
              cp -r build/erlang-shipment/* $out/opt/gleeter/
              substituteInPlace $out/opt/gleeter/entrypoint.sh \
                --replace erl ${pkgs.erlang_27}/bin/erl
              cp scripts/gleeter $out/bin/gleeter
              substituteInPlace $out/bin/gleeter \
                --replace /opt/gleeter $out/opt/gleeter
              runHook postInstallHook
            '';

            meta = with pkgs.lib; {
              description = "Package description here";
              mainProgram = pname;
              homepage = "https://github.com/massix/nixos.git";
              license = licenses.mit;
            };
          };

        app.default = self.packages.default;
      });
}
