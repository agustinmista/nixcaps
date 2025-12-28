{
  description = "QMK firmware builder for the Ergodox EZ keyboard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps/main";
    # Uncomment the next line if you want to use a specific revision of
    # qmk_firmware. Just make sure not to remove the submodules=1 part.
    # nixcaps.inputs.qmk_firmware.url = "git+https://github.com/qmk/qmk_firmware?submodules=1&rev=54e8fad959d6a6e53e08c62ac3a3c4d4bdc6c957";
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
