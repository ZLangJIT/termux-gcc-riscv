{ configuration ? import ./configuration.nix, nixpkgs ? <nixpkgs>, extraModules ? [], system ? builtins.currentSystem, platform ? null }:

let
  pkgs = import nixpkgs {
  	system = system;
  	platform = platform;
  	config = {};
  };

  mod = rec { 
  	 _file = ./default.nix;
    key = _file;
    config = {
      nixpkgs.system = pkgs.lib.mkDefault system;
    };
  };

  sys = pkgs.lib.evalModules {
    prefix = [];
    check = true;
    modules = [
      configuration
      ./base.nix
      <nixpkgs/nixos/modules/system/boot/kernel.nix>
      <nixpkgs/nixos/modules/misc/assertions.nix>
      <nixpkgs/nixos/modules/misc/lib.nix>
      mod
    ] ++ extraModules;
    args = {};
  };
in

sys.config