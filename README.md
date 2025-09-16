# nixcaps

**Nix flake to compile out-of-tree QMK firmwares**

The goal of this project is to provide a simple Nix derivation to build QMK-based firmware for your favorite programmable keyboards.

## Usage

### Compiling

`compile :: { src, keyboard, variant ? null, target ? "fw", flash ? null  }`

Inputs:

- `src` (`Path`): the path to the directory containing your QMK config files
- `keyboard` (`String`): the path inside `keyboards` in the `qmk_firmare` repo that where your keyboard model is defined (e.g., `preonic`, `zsa/moonlander`)
- `variant` (`String` | `Null`): the concrete variant of your keyboard, in case more than one exists (e.g., the `rev3_drop` variant of `preonic`, or the `base` variant of `ergodox_ez`).
- `target` (`String` | `Null`): the basename of the compiled firmware file (i.e., without any extension)
- `flash` (`String -> String` | `Null`): a function that takes the resolved basename of the compiled firmware and returns a (possibly multiline) script that flashes it into your keyboard. When provided, this will generate a `flash` executable in the derivation's output path.

## Example

Here is a minimal example showing how to use `nixcaps` as an input to your flakes and invoke the firmware builder for a given keyboard model/variant (original Ergodox EZ with ATmega32U4).

**flake.nix**:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixcaps.url = "github:agustinmista/nixcaps";
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
```

This example is also packaged as a template you can try locally by running:

```bash
$ nix flake new nixcaps --template github:agustinmista/nixcaps#ergodox_ez
$ cd nixcaps
$ nix build
$ sudo ./result/bin/flash
```

## Notes

- Under the hood, this derivation first copies the files in `src` into `keyboards/<keyboard>/keymaps/nixcaps` inside the `qmk_firmare`, and then executes `qmk compile --keyboard <keyboard>[/<variant>] --keymap nixcaps`.

- While it should be possible to flash the compiled firmwares using `qmk flash`, this command is only available while inside the `qmk_firmware` repo. So, it is not enough to provide such a derivation with just the compiled firmware, and one would have to copy the entire (or a large part of) the `qmk_firmware` as well. If you know how to implement this in an efficient way, let me know!

- To ensure reproducibily, this builder calls `qmk compile` with the `SKIP_GIT=true` env var. This avoids some of the issues [others have observed](https://discourse.nixos.org/t/fetchgit-hash-mismatch-with-qmk-firmware-submodules/49667) while trying work with `qmk_firmware` in Nix. If your keyboard config relies on `qmk compile` using git for any reason, this probably won't work!
