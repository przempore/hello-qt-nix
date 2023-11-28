{
  description = "Istall CVB on NixOS";


  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs { inherit system; };
        cvb = builtins.fetchurl {
          url = "https://ftp.commonvisionblox.com/webdavs/forum/setups/cvb/linux-x86_64/cvb-14.00.006-ubu2004-x86_64.zip";
          sha256 = "1g9m59kn0gy8ghm5n154lf45hv4jjg75hd653dmlm2knm4jxywc7";
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "cvb";
          src = cvb;
          nativeBuildInputs = [ pkgs.unzip pkgs.dpkg pkgs.tree ];
          unpackPhase = ''
            mkdir -p $out
            unzip -o $src
            ls -la
          '';
          # buildPhase = ''
          #   cat install_cvb.sh
          #   # ./install_cvb.sh
          # '';
          installPhase = ''
            dpkg -x cvb-camerasuite-14.00.006-ubu2004-x86_64.deb .
            dpkg -x cvb-camerasuite-dev-14.00.006-ubu2004-x86_64.deb .
            tree -a
            cp -r opt/cvb-14.00.006/* $out
          '';
        };
    });
}
