let
  # host packages, in case we need to build something not available in target packages
  host_nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  host_pkgs = import target_nixpkgs {};
  # target packages
  target_nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  target_pkgs = import target_nixpkgs { system = aarch64-linux };
in
target_pkgs.hello
