{
  description = "Install Qt on NixOS";


  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    qt_ld.url = "./qt_ld";
  };

  outputs = { self, nixpkgs, flake-utils, nix-alien, qt_ld, ... }: 
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
            qt_ld
          ];

          dontUnpack = true;
          dontCheck = true;
          configurePhase = ''
            cp $qt ./install_qt.run
            chmod +x ./install_qt.run
          '';

          buildPhase = ''
            export HOME=$(pwd)
            mkdir -p $out
            cp ./install_qt.run $out
            echo "Building qt"
            mkdir cache

            ./install_qt.run \
            -l libGL.so.1 -l libz.so.1 \
            install \
            --cp cache \
            --no-save-account \
            --accept-messages \
            --accept-licenses \
            --accept-obligations \
            --confirm-command \
            --email <E-MAIL> \
            --password <PASSWORD> \
            --no-default-installations \
            --no-force-installations \
            --root ./Qt5 qt.qt5.51515.gcc_64
                  
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
