{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    llvm = pkgs.llvmPackages_latest;
  in {
    devShell.x86_64-linux = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ({ pkgs, ... }: {
          packages = [
            pkgs.unzip
            pkgs.dpkg
            pkgs.cmake
            pkgs.ninja
            pkgs.gdb
            pkgs.gcc
            pkgs.zlib
            pkgs.glib
            pkgs.libglibutil
            llvm.lldb
            pkgs.clang-tools
            llvm.clang
          ];

          dotenv.enable = true;
          env.QT_INSTALLER = "qt-unified-linux-x64-4.6.1-online.run";
          env.CVB_VERSION = "14.00.006";
          env.CVB_ARCH = "ubu2004-x86_64";
          env.CVB_URL = "https://ftp.commonvisionblox.com/webdavs/forum/setups/cvb/linux-x86_64/cvb-14.00.006-ubu2004-x86_64.zip";

          enterShell = ''
            function download_cvb {
              echo $CVB_URL
              echo "Downloading CVB"
              wget $CVB_URL
            }
            
            function install_cvb {
              echo "unzip CVB"
              unzip cvb-$CVB_VERSION-$CVB_ARCH.zip -d cvb
              # dpkg -x cvb/cvb-tools-dev-$CVB_VERSION-$CVB_ARCH.deb cvb/unpacked
              # dpkg -x cvb/cvb-tools-$CVB_VERSION-$CVB_ARCH.deb cvb/unpacked
              dpkg -x cvb/cvb-camerasuite-$CVB_VERSION-$CVB_ARCH.deb cvb/unpacked/
              dpkg -x cvb/cvb-camerasuite-dev-$CVB_VERSION-$CVB_ARCH.deb cvb/unpacked/
            }

            if [ ! -f cvb-$CVB_VERSION-$CVB_ARCH.zip ]; then
              download_cvb
            fi
            if [ ! -d $PWD/cvb/unpacked ]; then
              install_cvb
            fi
            export LD_LIBRARY_PATH="$PWD/cvb/unpacked/opt/cvb-$CVB_VERSION/lib/:$LD_LIBRARY_PATH"

            if [ -z "$QT_EMAIL" -o -z "$QT_PASS" -o -z "$QT_DIR" ]; then
              echo "Please set QT_* environment variables"
              exit 1
            fi
            if [ ! -f $QT_INSTALLER ]; then
              wget https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/$QT_INSTALLER
              chmod +x $QT_INSTALLER
            fi
            if [ ! -d $QT_DIR ]; then
              nix run \
                  --impure github:guibou/nixGL \
                  --override-input nixpkgs nixpkgs/nixos-unstable \
                  -- nix run github:thiagokokada/nix-alien \
                  -- -l libGL.so.1 -l libz.so.1 \
                  ./$QT_INSTALLER \
                  --email $QT_EMAIL \
                  --password $QT_PASS \
                  install \
                  --no-save-account \
                  --accept-messages \
                  --accept-licenses \
                  --accept-obligations \
                  --confirm-command \
                  --no-default-installations \
                  --no-force-installations \
                  --root $QT_DIR qt.qt5.51515.gcc_64
            fi

            echo "Qt installed at \"$QT_DIR\""
          '';
        })
      ];
    };
  };
}
