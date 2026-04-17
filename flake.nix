{
  description = "Google Android CLI - command-line interface for Android development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        android-cli = final.callPackage ./package.nix {};
      };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
      in {
        packages = {
          android-cli = pkgs.android-cli;
          default = pkgs.android-cli;
        };

        apps.default = {
          type = "app";
          program = "${pkgs.android-cli}/bin/android";
        };
      }
    ) // {
      overlays.default = overlay;
    };
}
