{ lib, ... }:
{
  keyboard,
  variant ? null,
  target ? null,
}:
let
  keyboardVariant = if variant == null then "${keyboard}" else "${keyboard}/${variant}";
  keyboardName = lib.last (lib.splitString "/" keyboard);
  keymapName = "${keyboardName}-default";
in
{
  inherit
    keyboard
    variant
    keyboardVariant
    keyboardName
    keymapName
    ;
  buildDir = "build";
  keyboardDir = "keyboards/${keyboard}";
  keymapDir = "keyboards/${keyboard}/keymaps/${keymapName}";
  targetName = if target == null then "${keymapName}" else target;
}
