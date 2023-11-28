{
  description = "Install Qt on NixOS";


  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixgl.url = "github:guibou/nixGL";
  };

  outputs = { self, nixpkgs, flake-utils, nix-alien, nixgl }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nixgl.overlay ];
        };
        qt = builtins.fetchurl {
          url = "https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-unified-linux-x64-4.6.1-online.run";
          sha256 = "1jxw5fgm8lfhm5pyp0x25sy4vsf18ffhw1c0mnvq7liig8qfky0i";
        };
        llvm = pkgs.llvmPackages_latest;
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
            pkgs.nixgl.nixGLIntel
          ];

          dontUnpack = true;
          dontCheck = true;
          configurePhase = ''
            cp $qt ./install_qt.run
            chmod +x ./install_qt.run
            ls -lh
          '';

          buildPhase = ''
            export HOME=$(pwd)
            mkdir -p $out
            cp ./install_qt.run $out
            echo "Building qt"
            mkdir cache

            # arg: `-c i` is an ugly hack to make nix-alien auto select the right library candidate
            nix-alien -l libGL.so.1 -l libz.so.1 \
                  -c i \
                  --destination nix_alien_config \
                  ./install_qt.run \
                  --help \
                  --email <EMAIL> \
                  --password <PASSWORD> \
                  install \
                  --cp cache \
                  --no-save-account \
                  --accept-messages \
                  --accept-licenses \
                  --accept-obligations \
                  --confirm-command \
                  --no-default-installations \
                  --no-force-installations \
                  --root ./Qt5 qt.qt5.51515.gcc_64
          '';

          dontInstall = true;
        };
    });
}
