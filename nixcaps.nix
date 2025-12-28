{
  qmk,
  fetchFromGitHub,
  stdenv,
  writeShellScriptBin,
  symlinkJoin,
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
      buildDrv = stdenv.mkDerivation {
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
        '';
        dontFixup = true;
      };

      flashText = flash "${buildDrv}/bin/${target}";
      flashDrv = (writeShellScriptBin "flash" flashText).overrideAttrs (_: {
        name = "nixcaps-flash-script";
      });
    in
    symlinkJoin {
      name = "nixcaps-output";
      paths = lib.flatten [
        buildDrv
        (lib.optional (!isNull flash) flashDrv)
      ];
    };
}
