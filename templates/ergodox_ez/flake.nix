{
  description = "QMK firmware builder for the Ergodox EZ keyboard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps";
    # Uncomment the next line if you want to use a specific revision of
    # qmk_firmware.
    # nixcaps.inputs.qmk_firmware.ref = "54e8fad959d6a6e53e08c62ac3a3c4d4bdc6c957";
  };

  outputs =
    inputs@{ flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixcaps = inputs.nixcaps.lib.${system};
        ergodoz_ez = {
          src = ./.;
          # path within the qmk_firmware tree
          # to the keyboard's directory,
          # relative to the top-level `keyboards/`
          # directory
          keyboard = "ergodox_ez";
          # keyboard variant, if any;
          # this is relative to the keyboard directory
          # and should contain a `keyboard.json` file
          variant = "base";
        };
      in
      {
        # Build with `nix build`
        packages.default = nixcaps.mkQmkFirmware ergodoz_ez;
        # Flash with `nix run`
        apps.default = nixcaps.flashQmkFirmware ergodoz_ez;
        devShells.default = pkgs.mkShell {
          QMK_HOME = "${nixcaps.inputs.qmk_firmware}";
          packages = [ pkgs.qmk ];
          shellHook =
            let
              compile_db = nixcaps.mkCompileDb ergodoz_ez;
            in
            ''
              ln -sf "${compile_db}/compile_commands.json" ./compile_commands.json
            '';
        };
      }
    );
}
