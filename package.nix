{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, glibc
}:

let
  version = "0.7.15303877";

  platformHashes = {
    "x86_64-linux" = "sha256-y4woDP/5fqc6C6U50jXaOqiDBZzzENZSbHUCTt2zKic=";
    "aarch64-darwin" = "sha256-N70ts4oIEp2vYzxPqnqi30lW/+UUGT/bucO6nHs8jUY=";
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
