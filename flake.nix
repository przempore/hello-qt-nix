{
  description = "Install Qt on NixOS";


  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = { self, nixpkgs, flake-utils, nix-alien, ... }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs { inherit system; };
        qt = builtins.fetchurl {
          url = "https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-unified-linux-x64-4.6.1-online.run";
          sha256 = "1jxw5fgm8lfhm5pyp0x25sy4vsf18ffhw1c0mnvq7liig8qfky0i";
        };
        llvm = pkgs.llvmPackages_latest;
        inherit (pkgs) lib stdenv;
        NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
          bzip2_1_1.out
          dbus.lib
          fontconfig.lib
          libgcc.lib
          libxkbcommon.out
          primusLib.out
          vivictpp.out
          xorg.libX11.out
          xorg.libXext.out
          xorg.libxcb.out
          xorg.xcbutilimage.out
          xorg.xcbutilkeysyms.out
          xorg.xcbutilrenderutil.out
          xorg.xcbutilwm.out
          xz.out
        ];
        # install_qt = pkgs.writeShellScriptBin "install_qt.run" ''
        #   export NIX_LD_LIBRARY_PATH='${NIX_LD_LIBRARY_PATH}'${"\${NIX_LD_LIBRARY_PATH:+':'}$NIX_LD_LIBRARY_PATH"}
        #   export NIX_LD="$(cat ${stdenv.cc}/nix-support/dynamic-linker)"
        #   /nix/store/vbyswf67a5qb9zf0pc1ihb0glyqa82wz-qt/install_qt.run "$@"
        # '';
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          inherit qt;
          name = "qt";
          src = ./.;
          nativeBuildInputs = with pkgs; with llvm; [
            unzip
            dpkg
            cmake
            ninja
            gdb
            gcc
            zlib
            glib
            libglibutil
            clang-tools
            boost
            fzf
            lldb
            clang
            nix-alien.packages.${system}.nix-alien
            nix-index
            tree
            unixtools.script
            libGL
            libz
          ];

          dontUnpack = true;
          dontCheck = true;
          configurePhase = ''
            cp $qt ./install_qt.run
            chmod +x ./install_qt.run

            mkdir -p $out
            cp ./install_qt.run $out/
            ls -lah
          '';

          buildPhase = ''
            echo "Building qt"
            export HOME=$(pwd)
            # mkdir -p $out
            # cp ./install_qt.run $out/
            mkdir cache
            ls -lah

            export NIX_LD_LIBRARY_PATH='${NIX_LD_LIBRARY_PATH}'${"\${NIX_LD_LIBRARY_PATH:+':'}$NIX_LD_LIBRARY_PATH"}
            export NIX_LD="$(cat ${stdenv.cc}/nix-support/dynamic-linker)"

            if [ -e ./install_qt.run ]; then
              echo "install_qt.run exists"
              ./install_qt.run
            else
              echo "install_qt.run does not exist"
            fi

            # nix-alien-ld ./install_qt.run \
            # -l libGL.so.1 -l libz.so.1 \
            # --recreate \
            # --flake \
            # --destination cache \
            # -c i \
            # install \
            # --cp cache \
            # --no-save-account \
            # --accept-messages \
            # --accept-licenses \
            # --accept-obligations \
            # --confirm-command \
            # --email <E-MAIL> \
            # --password <PASSWORD> \
            # --no-default-installations \
            # --no-force-installations \
            # --root ./Qt5 qt.qt5.51515.gcc_64

            cp -r cache $out/
            ls -lah
          '';
          dontInstall = true;
        };


        devShell = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; with llvm; [
            unzip
            dpkg
            cmake
            ninja
            gdb
            gcc
            zlib
            glib
            libglibutil
            clang-tools
            boost
            fzf
            lldb
            clang
            nix-alien.packages.${system}.nix-alien
            nix-index
            tree
            libGL
            libz
            unixtools.script
          ];
        };
    });
}
