let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  pkgs = import nixpkgs {};
  extra-platforms = "aarch64-linux";
  extra-sandbox-paths = "/usr/bin/qemu-user-aarch64";
in
pkgs.pkgsCross.aarch64-android.hello
