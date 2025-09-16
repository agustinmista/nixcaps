{
  description = "Nix flake to compile out-of-tree QMK firmwares";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixcaps = pkgs.callPackage ./nixcaps.nix { };
      in
      {
        packages = {
          inherit (nixcaps)
            compile
            qmk_firmware
            ;
        };
      }
    ))
    // {
      templates = rec {
        default = ergodox_ez;
        ergodox_ez = {
          path = ./templates/ergodox_ez;
          description = "A simple flake to build a firmware for the Ergodox EZ keyboard";
        };
      };
    };
}
