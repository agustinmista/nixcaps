{
  description = "Nix flake to compile out-of-tree QMK firmwares";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    qmk_firmware = {
      url = "git+https://github.com/qmk/qmk_firmware?submodules=1&rev=54e8fad959d6a6e53e08c62ac3a3c4d4bdc6c957";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      qmk_firmware,
      ...
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixcaps = pkgs.callPackage ./nixcaps.nix { inherit qmk_firmware; };
      in
      {
        packages = { inherit (nixcaps) compile; };
        formatter = pkgs.nixfmt-rfc-style;
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
