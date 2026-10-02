{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
}:
let
  # Upstream shells out to grim + slurp (wlroots only); on macOS the patch swaps
  # that pipeline for this NSColorSampler helper.
  colorSampler = stdenv.mkDerivation {
    name = "vicinae-color-sampler";
    src = ./color-sampler.m;
    dontUnpack = true;
    buildPhase = ''
      $CC -fobjc-arc -framework AppKit -o color-sampler $src
    '';
    installPhase = ''
      install -Dm755 color-sampler $out/bin/color-sampler
    '';
  };
in
buildNpmPackage {
  name = "color-picker";

  src = fetchFromGitHub {
    owner = "psampir";
    repo = "vicinae-color-picker";
    rev = "caf75355e9c96a97c8b289118d10e2ba7ac87d66";
    hash = "sha256-Ru5a0imeZ+I3GxIXXEHZxoNJ+Ki9KSx8X1HSfWLAhLI=";
  };

  npmDepsHash = "sha256-TaSs/q4MqbnXdh8YvaBGw/rBhFICIB8AfkSEt8LMLeM=";

  patches = lib.optional stdenv.hostPlatform.isDarwin ./macos.patch;

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src/pick-color.tsx \
      --replace-fail @colorSampler@ ${colorSampler}/bin/color-sampler
  '';

  buildPhase = ''
    runHook preBuild
    HOME=$TMPDIR npx vici build -o $out
    runHook postBuild
  '';

  dontNpmInstall = true;
  installPhase = "true";
}
