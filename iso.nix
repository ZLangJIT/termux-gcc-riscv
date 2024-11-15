{ config, pkgs, ... }:
{
  imports = [
    <iso-base.nix>
    <channel.nix>
  ];
  config.nixpkgs.hostPlatform
}
