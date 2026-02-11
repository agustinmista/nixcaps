qmk_firmware:
{
  lib,
  qmk,
  writeShellScriptBin,
  ...
}:
{
  firmware,
  keyboard,
  variant ? null,
  target ? null,
}:
let
  qmk_args = (import ./qmk-args.nix { inherit lib; }) { inherit keyboard variant target; };

  firmwareDir = "${firmware}/bin";
  targetBase = qmk_args.targetName;
in
writeShellScriptBin "flash" ''
  set -euo pipefail

  export QMK_HOME="${qmk_firmware}"

  dir="${firmwareDir}"
  base="${targetBase}"
  kb="${qmk_args.keyboardVariant}"

  pick_fw() {
    if [ -f "$dir/$base.bin" ]; then echo "$dir/$base.bin"
    elif [ -f "$dir/$base.uf2" ]; then echo "$dir/$base.uf2"
    elif [ -f "$dir/$base.hex" ]; then echo "$dir/$base.hex"
    else
      echo "No firmware artifact found for '$base' in '$dir' (.uf2/.hex/.bin)." >&2
      exit 1
    fi
  }

  on_exit() {
    code=$?
    if [ $code -eq 0 ]; then
      echo "✓ Flash complete!"
    elif [ $code -eq 130 ]; then
      # 130 is the standard exit code for Ctrl+C
      echo "✗ Flash aborted by user"
    else
      echo "✗ Flash failed (exit code $code)"
    fi
  }
  trap on_exit EXIT

  fw="$(pick_fw)"
  echo "Using firmware: $fw"
  echo "Waiting for keyboard in bootloader mode..."
  echo "(Press your reset button now)"

  # Let QMK handle the actual flashing once we select the right artifact.
  "${qmk}/bin/qmk" flash "$fw" --keyboard "${qmk_args.keyboardVariant}"
''
