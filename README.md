# nixcaps

[![CI](https://github.com/agustinmista/nixcaps/actions/workflows/build.yml/badge.svg)](https://github.com/agustinmista/nixcaps/actions/workflows/build.yml)

**Nix flake to compile out-of-tree QMK firmwares**

The goal of this project is to provide a simple Nix derivation to build QMK-based firmwares for your favorite programmable keyboards.

## Features

- Build QMK firmwares reproducibly with Nix
- Flash firmwares directly via `nix run`
- Full `clangd` LSP support via `compile_commands.json` generation

## Usage

### API

nixcaps exposes the following functions via `nixcaps.lib.${system}`:

- `mkQmkFirmware { src, keyboard, variant? }` - Builds the QMK firmware
- `flashQmkFirmware { src, keyboard, variant? }` - Returns a flake app that flashes the firmware
- `mkCompileDb { src, keyboard, variant? }` - Generates `compile_commands.json` for `clangd` LSP support

Parameters:

- `src` (`Path`): the path to the directory containing your QMK keymap files
- `keyboard` (`String`): the path inside `keyboards` in the `qmk_firmware` repo where your keyboard model is defined (e.g., `preonic`, `zsa/moonlander`)
- `variant` (`String`, optional): the concrete variant of your keyboard, in case more than one exists (e.g., the `rev3_drop` variant of `preonic`, or the `base` variant of `ergodox_ez`)

## Examples

### Single Keyboard

Here is a minimal example showing how to use `nixcaps` for the Ergodox EZ keyboard:

**flake.nix**:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps";
  };

  outputs =
    inputs@{
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixcaps = inputs.nixcaps.lib.${system};
        ergodox_ez = {
          src = ./.;
          keyboard = "ergodox_ez";
          variant = "base";
        };
      in
      {
        packages.default = nixcaps.mkQmkFirmware ergodox_ez;
        apps.default = nixcaps.flashQmkFirmware ergodox_ez;
        devShells.default = pkgs.mkShell {
          QMK_HOME = "${nixcaps.inputs.qmk_firmware}";
          packages = [ pkgs.qmk ];
          shellHook = ''
            ln -sf "${nixcaps.mkCompileDb ergodox_ez}/compile_commands.json" ./compile_commands.json
          '';
        };
      }
    );
}
```

This example is also packaged as a template you can try locally by running:

```bash
$ nix flake new my-keyboard --template github:agustinmista/nixcaps#ergodox_ez
$ cd my-keyboard
$ nix build        # compile the firmware
$ nix run          # flash the firmware
$ nix develop      # enter dev shell with LSP support
```

### Multiple Keyboards

For projects with multiple keyboards, you can define separate configurations:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps";
  };

  outputs =
    inputs@{
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixcaps = inputs.nixcaps.lib.${system};
        moonlander = {
          src = ./moonlander;
          keyboard = "zsa/moonlander";
        };
        thekey = {
          src = ./thekey;
          keyboard = "drop/thekey/v2";
        };
      in
      {
        packages = {
          moonlander = nixcaps.mkQmkFirmware moonlander;
          thekey = nixcaps.mkQmkFirmware thekey;
        };
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
```

Build and flash specific keyboards:

```bash
$ nix build .#moonlander   # build moonlander firmware
$ nix run .#thekey         # flash thekey firmware
```

This example is available as a template:

```bash
$ nix flake new my-keyboards --template github:agustinmista/nixcaps#multiple_keyboards
```

## LSP Support

nixcaps provides full `clangd` LSP support for your keymap files. The `mkCompileDb` function generates a `compile_commands.json` file that `clangd` uses for code intelligence features like:

- Go to definition
- Find references
- Autocompletion
- Diagnostics

To enable LSP support, add a dev shell to your flake that symlinks the generated `compile_commands.json` (see examples above), then run `nix develop` (or use `direnv`) before opening your editor.

## Notes

- You can change the version of `qmk_firmware` used by nixcaps by overriding its `qmk_firmware` flake input as follows:

  ```nix
  nixcaps.inputs.qmk_firmware.url = "github:qmk/qmk_firmware?rev=<COMMIT_SHA_OR_GIT_TAG>";
  ```

- Under the hood, this derivation first copies the files in `src` into `keyboards/<keyboard>/keymaps/nixcaps` inside an internal copy of the `qmk_firmware` repo, and then executes `qmk compile --keyboard <keyboard>[/<variant>] --keymap nixcaps`.

- While it should be possible to flash the compiled firmwares using `qmk flash`, this command is only available while inside the `qmk_firmware` repo. So, it is not enough to provide such a derivation with just the compiled firmware, and one would have to copy the entire (or a large part of) the `qmk_firmware` repo as well. If you know how to implement this in an efficient way, let me know!

- To ensure reproducibility, this builder calls `qmk compile` with the `SKIP_GIT=true` env var. This avoids some of the issues [others have observed](https://discourse.nixos.org/t/fetchgit-hash-mismatch-with-qmk-firmware-submodules/49667) while trying work with `qmk_firmware` in Nix. If your keyboard config relies on `qmk compile` using git for any reason, this probably won't work!
