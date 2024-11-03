let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  pkgs = import nixpkgs {};
in
pkgs.pkgsCross.aarch64-android.hello
