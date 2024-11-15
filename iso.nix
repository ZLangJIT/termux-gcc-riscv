{ config, pkgs, ... }:
{
  imports = [
    #<iso-base.nix>
    #<channel.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  #config.nixpkgs.hostPlatform = "riscv64-linux";
}
