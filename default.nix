let
  #nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  pkgs = import nixpkgs {
    crossSystem = "riscv64-linux";
  };
in pkgs.pkgsCross.riscv64.stdenv
