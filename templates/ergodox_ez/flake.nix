{
  description = "QMK firmware builder for the Ergodox EZ keyboard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps/main";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixcaps,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        compile = nixcaps.packages.${system}.compile;
      in
      {
        packages.default = compile {
          keyboard = "ergodox_ez";
          variant = "base";
          src = ./.;
          flash = fw: ''
            echo "Flashing ${fw}.hex ..."
            ${pkgs.teensy-loader-cli}/bin/teensy-loader-cli -mmcu=atmega32u4 -v -w ${fw}.hex
          '';
        };
      }
    );
}
