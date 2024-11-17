#!/usr/bin/env -S bash -i
if [[ -z $IN_SHELL ]] ; then
  set -x
  exec ./termux_shell_nosysv.sh "IN_SHELL=1 ./termux_nix_install.sh"
fi

set -x

if [[ ! -e /usr/bin/nix ]] ; then
  apt install nix
fi
if [[ -z $NIX_PATH ]] ; then
  echo "exporting NIX_PATH"
  echo 'export NIX_PATH="nixpkgs=/nixpkgs" >> /etc/profile'
fi
# nix-channel --update crashes in termux for unknown reasons
#  manually unpack instead
#nix-channel --update
if [[ ! -e /nixpkgs ]] ; then
  git clone --depth=1 https://github.com/nixos/nixpkgs -b 24.05
fi
nix-shell --dry-run -p nixos bash
#nix-build --dry-run "<nixpkgs/nixos>" -A pkgs.nixos
#nix-build --dry-run "<nixpkgs/nixos>" -A pkgs.bash
