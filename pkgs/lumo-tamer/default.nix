{ lib
, stdenv
, buildNpmPackage
, buildGoModule
, fetchFromGitHub
, pkg-config
, cairo
, giflib
, libjpeg
, librsvg
, libsecret
, pango
,
}:

let
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "ZeroTricks";
    repo = "lumo-tamer";
    rev = "refs/tags/v${version}";
    hash = "sha256-/B6AZ9C3k23tSadjcumV+y3TmZwEDgVHvOAOEQ68w1E=";
  };

  # The `tamer auth` flow shells out to a Go helper.  Building it separately
  # keeps Go out of the npm derivation and makes the binary deterministic.
  proton-auth = buildGoModule {
    pname = "proton-auth";
    inherit version src;
    sourceRoot = "source/src/auth/login/go";
    proxyVendor = true;
    vendorHash = "sha256-1n5o5Tf4vvIBWWZ5Xo8cAB/8+g0lIFz0gF8U9BKP4bs=";
    ldflags = [
      "-s"
      "-w"
    ];
    meta = {
      description = "Proton authentication helper for lumo-tamer";
      homepage = "https://github.com/ZeroTricks/lumo-tamer";
      license = lib.licenses.gpl3Only;
      mainProgram = "proton-auth";
    };
  };
in
buildNpmPackage {
  pname = "lumo-tamer";
  inherit version src;

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-GMplGK+9LzhXjvxGh9S7f0OLqhZNfYhK4IEAhE+SKaA=";

  # Upstream resolves config.yaml, the auth vault, logs and the IndexedDB DB
  # against the project root, which is the read-only store here.  Repoint the
  # mutable paths at $LUMO_STATE_DIR (default ~/.local/share/lumo-tamer) while
  # keeping bundled assets (config.defaults.yaml, the proton-auth binary) in the
  # store.  See state-dir.patch.
  patches = [ ./state-dir.patch ];

  # `canvas` and `keytar` are native modules without usable prebuilts in the
  # sandbox, so node-gyp builds them from source: canvas needs the cairo/pango
  # stack on every platform, keytar needs libsecret on Linux.
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    cairo
    giflib
    libjpeg
    librsvg
    pango
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [ libsecret ];

  # keytar pins node-addon-api 4.3.0, whose out-of-range enum sentinel is a hard
  # error on clang 16+.  Defer the native rebuild out of the patch phase so the
  # header can be fixed first (upstream dropped the sentinel in 7.x).
  npmRebuildFlags = [ "--ignore-scripts" ];

  preBuild = ''
    substituteInPlace node_modules/node-addon-api/napi.h \
      --replace-fail \
      'static_cast<napi_typedarray_type>(-1)' \
      'static_cast<napi_typedarray_type>(napi_biguint64_array + 1)'
    npm rebuild
  '';

  postInstall = ''
    install -m755 ${proton-auth}/bin/proton-auth \
      "$out/lib/node_modules/lumo-tamer/dist/proton-auth"
  '';

  meta = {
    description = "Use Proton's Lumo AI through an OpenAI-compatible API and CLI";
    homepage = "https://github.com/ZeroTricks/lumo-tamer";
    license = lib.licenses.gpl3Only;
    mainProgram = "tamer";
  };
}
