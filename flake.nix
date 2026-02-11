{
  description = "Nix flake to compile out-of-tree QMK firmwares";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    qmk_firmware = {
      url = "https://github.com/qmk/qmk_firmware";
      ref = "54e8fad959d6a6e53e08c62ac3a3c4d4bdc6c957";
      flake = false;
      type = "git";
      submodules = true;
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
        mkQmkFirmware = pkgs.callPackage (import ./nix/build.nix qmk_firmware) { };
        mkFlashQmkFirmware = pkgs.callPackage (import ./nix/flash.nix qmk_firmware) { };
        flashQmkFirmware =
          args:
          let
            firmware = mkQmkFirmware args;
          in
          {
            type = "app";
            program = "${mkFlashQmkFirmware (removeAttrs args [ "src" ] // { inherit firmware; })}/bin/flash";
          };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        lib = {
          inherit mkQmkFirmware flashQmkFirmware;
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
