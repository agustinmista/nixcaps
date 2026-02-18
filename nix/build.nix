qmk_firmware:
{
  lib,
  qmk,
  stdenv,
  python313,
  ...
}:
{
  src,
  keyboard,
  variant ? null,
  target ? null,
}:
let
  qmk_args = (import ./qmk-args.nix { inherit lib; }) { inherit keyboard variant target; };
in
stdenv.mkDerivation {
  name = "${qmk_args.keymapName}-firmware";
  src = qmk_firmware;
  nativeBuildInputs = [ python313 ];
  buildInputs = [ qmk ];

  postPatch = ''
    mkdir -p ${qmk_args.keymapDir}
    cp -r ${src}/* ${qmk_args.keymapDir}/
    patchShebangs util lib
  '';

  buildPhase = ''
    qmk compile \
        -j 4 \
        --env SKIP_GIT=true \
        --env QMK_HOME=$PWD \
        --env QMK_FIRMWARE=$PWD \
        --env BUILD_DIR=${qmk_args.buildDir} \
        --env TARGET=${qmk_args.targetName} \
        --keyboard ${qmk_args.keyboardVariant} \
        --keymap ${qmk_args.keymapName}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${qmk_args.buildDir}/*.{hex,bin,elf,dfu,uf2,eep} $out/bin 2>/dev/null || true
  '';

  dontFixup = true;
}
