{ config, pkgs, ... }:
{
  nixpkgs.crossSystem = {
    system = "riscv64-linux";
  };

  imports = [
    #<nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    #<nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
}
