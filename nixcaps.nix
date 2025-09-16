{
  qmk,
  fetchFromGitHub,
  stdenv,
  lib,
}:
rec {
  qmk_firmware = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = "0.30.3";
    sha256 = "sha256-lM5B9xl7sSxGhI/fbS0ys22t5oVUp8aMLI4pzICEKHk=";
    fetchSubmodules = true;
  };
  compile =
    {
      keyboard,
      src,
      variant ? null,
      flash ? null,
      target ? "fw",
      ...
    }:
    let
      buildDir = "build";
      keyboardDir = "keyboards/${keyboard}";
      keyboardVariant = if builtins.isNull variant then "${keyboard}" else "${keyboard}/${variant}";
      keymapName = "nixcaps";
      keymapDir = "${keyboardDir}/keymaps/${keymapName}";
    in
    stdenv.mkDerivation {
      name = "nixcaps-compile";
      src = qmk_firmware;
      buildInputs = [ qmk ];
      postPatch = ''
        mkdir -p ${keymapDir}
        cp -r ${src}/* ${keymapDir}/
      '';
      buildPhase = ''
        qmk compile \
          --env SKIP_GIT=true \
          --env BUILD_DIR=${buildDir} \
          --env TARGET=${target} \
          --keyboard ${keyboardVariant} \
          --keymap ${keymapName}
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp ${buildDir}/*.{hex,bin,elf,dfu,uf2,eep} $out/bin

        ${lib.optionalString (!builtins.isNull flash) ''
          cat > $out/bin/flash <<EOF
          #!/bin/sh
          set -e
          ${flash (placeholder "out" + "/bin/${target}")}
          EOF
          chmod +x $out/bin/flash
        ''}
      '';
      dontFixup = true;
    };
}
