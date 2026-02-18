qmk_firmware:
{
  lib,
  qmk,
  stdenv,
  python313,
  jq,
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
  name = "${qmk_args.keymapName}-compiledb";
  src = qmk_firmware;
  nativeBuildInputs = [ python313 ];
  buildInputs = [
    qmk
    jq
  ];

  postPatch = ''
    mkdir -p ${qmk_args.keymapDir}
    cp -r ${src}/* ${qmk_args.keymapDir}/
    patchShebangs util lib
  '';

  buildPhase = ''
    qmk compile \
        -j 4 \
        --compiledb \
        --env SKIP_GIT=true \
        --env QMK_HOME=$PWD \
        --env QMK_FIRMWARE=$PWD \
        --env BUILD_DIR=${qmk_args.buildDir} \
        --env TARGET=${qmk_args.targetName} \
        --keyboard ${qmk_args.keyboardVariant} \
        --keymap ${qmk_args.keymapName}
  '';

  installPhase = ''
    mkdir -p $out

    # Post-process compile_commands.json:
    # 1. Rewrite sandbox paths for keymap files to relative src/ paths
    # 2. Strip ARM cross-compilation flags that clangd can't handle
    jq '
      map(
        # Rewrite keymap source file paths to relative
        .file = (.file | gsub(".*/keyboards/${qmk_args.keyboard}/keymaps/${qmk_args.keymapName}/"; ""))
        |
        # Rewrite directory to current dir for keymap files
        .directory = "."
        |
        # Strip problematic ARM flags from command/arguments
        if .command then
          .command = (.command | gsub("-mno-thumb-interwork|-mthumb|-mcpu=[^ ]*|-march=[^ ]*|-mfloat-abi=[^ ]*|-mfpu=[^ ]*|--target=arm-none-eabi|-mno-unaligned-access|-fsingle-precision-constant|-specs=[^ ]*|--specs=[^ ]*|-mmcu=[^ ]*"; ""))
        else . end
        |
        if .arguments then
          .arguments = [.arguments[] | select(
            test("^-mno-thumb-interwork$|^-mthumb$|^-mcpu=|^-march=|^-mfloat-abi=|^-mfpu=|^--target=arm-none-eabi$|^-mno-unaligned-access$|^-fsingle-precision-constant$|^-specs=|^--specs=|^-mmcu=") | not
          )]
        else . end
      )
    ' compile_commands.json > $out/compile_commands.json
  '';

  dontFixup = true;
}
