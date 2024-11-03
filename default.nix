let
  # host packages, in case we need to build something not available in target packages
  host_nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  host_pkgs = import target_nixpkgs {};
  # target packages
  target_nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05" system = aarch64-linux;
  target_pkgs = import target_nixpkgs {};
in
target_pkgs.hello
