{
  description = "install_qt.run-nix-ld";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/85f1ba3e51676fa8cc604a3d863d729026a6b8eb";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    rec {
      defaultPackage.${system} =
        let
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
            zlib.out
          ];
        in
        pkgs.writeShellScriptBin "install_qt.run" ''
          export NIX_LD_LIBRARY_PATH='${NIX_LD_LIBRARY_PATH}'${"\${NIX_LD_LIBRARY_PATH:+':'}$NIX_LD_LIBRARY_PATH"}
          export NIX_LD="$(cat ${stdenv.cc}/nix-support/dynamic-linker)"
          /home/przemek/Projects/qt_flake/qt_ld/../install_qt.run "$@"
        '';

      defaultApp.${system} = {
        type = "app";
        program = "${defaultPackage.${system}}/bin/install_qt.run";
      };
    };
}
