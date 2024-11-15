{ config, pkgs, ... }:
{
  nixpkgs.crossSystem = {
    system = "riscv64-linux";
  };

  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  #isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
