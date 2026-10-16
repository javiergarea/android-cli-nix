{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, glibc
}:

let
  version = "1.0.16625370";

  platformHashes = {
    "x86_64-linux" = "sha256-yPiLFKoA5EpULdNZfL3LAV5VUR4zwt1pkg9B9bCG4ig=";
    "aarch64-darwin" = "sha256-qWAQAPrg9A2UKLBbV/8R8QFChYHsDlS56149r4wEkso=";
  };

  platformUrls = {
    "x86_64-linux" = "linux_x86_64";
    "aarch64-darwin" = "darwin_arm64";
  };

  urlPlatform = platformUrls.${stdenv.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  hash = platformHashes.${stdenv.hostPlatform.system}
    or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "android-cli";
  inherit version;

  src = fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/android/cli/${version}/${urlPlatform}/android";
    inherit hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glibc
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/android
    chmod +x $out/bin/android
  '';

  meta = with lib; {
    description = "Google Android CLI for terminal-based Android development";
    homepage = "https://developer.android.com/tools/agents/android-cli";
    license = licenses.unfree;
    platforms = builtins.attrNames platformHashes;
    mainProgram = "android";
  };
}
