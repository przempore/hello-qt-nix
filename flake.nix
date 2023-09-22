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

          enterShell = ''
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
