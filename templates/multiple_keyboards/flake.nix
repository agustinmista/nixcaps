{
  description = "QMK firmware builder for multiple keyboards";

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
        moonlander = {
          src = ./moonlander;
          # path within the qmk_firmware tree
          # to the keyboard's directory,
          # relative to the top-level `keyboards/`
          # directory
          keyboard = "zsa/moonlander";
          # keyboard variant, if any;
          # this is relative to the keyboard directory
          # and should contain a `keyboard.json` file
          # variant = "...";
        };
        thekey = {
          src = ./thekey;
          keyboard = "drop/thekey/v2";
        };
      in
      {
        # Build with `nix build .#moonlander` or `nix build .#thekey`
        packages = {
          moonlander = nixcaps.mkQmkFirmware moonlander;
          thekey = nixcaps.mkQmkFirmware thekey;
        };
        # Flash with `nix run .#moonlander` or `nix run .#thekey`
        apps = {
          moonlander = nixcaps.flashQmkFirmware moonlander;
          thekey = nixcaps.flashQmkFirmware thekey;
        };
        devShells.default = pkgs.mkShell {
          QMK_HOME = "${nixcaps.inputs.qmk_firmware}";
          packages = [ pkgs.qmk ];
          shellHook = ''
            ln -sf "${nixcaps.mkCompileDb moonlander}/compile_commands.json" ./moonlander/compile_commands.json
            ln -sf "${nixcaps.mkCompileDb thekey}/compile_commands.json" ./thekey/compile_commands.json
          '';
        };
      }
    );
}
