let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/release-24.05";
  host_pkgs = import nixpkgs {};
  target_pkgs = import nixpkgs { system = "test-linux"; };
in
target_pkgs.hello
