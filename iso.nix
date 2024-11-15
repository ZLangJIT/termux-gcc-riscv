{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  #config.nixpkgs.hostPlatform = "riscv64-linux";

  # required and default packages are controlled via
  # nixpkgs/nixos/modules/config/system-path.nix

  # systemd units are controlled via
  # nixpkgs/nixos/modules/system/boot/systemd/initrd.nix

}
