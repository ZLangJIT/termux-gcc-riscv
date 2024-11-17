#!/nix/store/psz650xdnl6z94larfkrplng1fvg2aik-bash-5.2p32/bin/bash

source /nix/store/mhxn5kwnri3z9hdzi3x0980id65p0icn-lib.sh

systemConfig='/nix/store/zirszy9y5fdhxy9x63wnmf57mwx5v5hx-nixos-system-nixos-24.05.6632.c21b77913ea8'

export PATH=/empty
for i in /nix/store/4384fl7d33ajhzszjr64nqdiv5sp9nqz-coreutils-9.5 /nix/store/i6ic61prvhxz3izx2cl2f7agp23f64hn-gnugrep-3.11 /nix/store/6yqbnfdj9fh9nvj897myaphf1nkvsyx2-findutils-4.9.0 /nix/store/rkwxhpgnni1alldkb7hkfmcgvqfjs3dc-getent-glibc-2.39-52 /nix/store/cvq4qjhms4ghfgx18cw2vqar5gncppia-glibc-2.39-52-bin /nix/store/j0qpjpprxb8aww3680vcxzsd4h2nw5x1-shadow-4.14.6 /nix/store/j90dr810m6g07gdnpsx4pql033dmadd1-net-tools-2.10 /nix/store/x62y0qgxhkw7fs3iw91dcb6hcvhs35hc-util-linux-2.39.4-bin; do
    PATH=$PATH:$i/bin:$i/sbin
done

install -m 0755 -d /etc
install -m 0755 -d /run
install -m 0750 -d /run/keys
install -m 0755 -d /run/wrappers
install -m 0777 -d /tmp

_status=0
trap "_status=1 _localstatus=\$?" ERR

# Ensure a consistent umask.
umask 0022

#### Activation script snippet stdio:
_localstatus=0


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "stdio" "$_localstatus"
fi

#### Activation script snippet binsh:
_localstatus=0
# Create the required /bin/sh symlink; otherwise lots of things
# (notably the system() function) won't work.
mkdir -p /bin
chmod 0755 /bin
ln -sfn "/nix/store/4l95pg51sd92r5lpwvh2yd5l640xfhh3-bash-interactive-5.2p32/bin/sh" /bin/.sh.tmp
mv /bin/.sh.tmp /bin/sh # atomically replace /bin/sh
ln -sfn "/nix/store/4l95pg51sd92r5lpwvh2yd5l640xfhh3-bash-interactive-5.2p32/bin/sh" /bin/.bash.tmp
mv /bin/.bash.tmp /bin/bash # atomically replace /bin/bash


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "binsh" "$_localstatus"
fi

#### Activation script snippet users:
_localstatus=0
install -m 0700 -d /root
install -m 0755 -d /home

/nix/store/wgjrs1b6pf5w7x72zrzs7avb371c3saj-perl-5.38.2-env/bin/perl \
-w /nix/store/38hbyd1gwyszqslh3wycv5ly03dr75gj-update-users-groups.pl /nix/store/s279pck3rhp1pmzdw9i9zv8a1gvwgha7-users-groups.json


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "users" "$_localstatus"
fi

#### Activation script snippet groups:
_localstatus=0


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "groups" "$_localstatus"
fi

#### Activation script snippet etc:
_localstatus=0
# Set up the statically computed bits of /etc.
echo "setting up /etc..."
/nix/store/fnzgdg4h11n962m2b80bv6jp5yvjdy0z-perl-5.38.2-env/bin/perl /nix/store/rg5rf512szdxmnj9qal3wfdnpfsx38qi-setup-etc.pl /nix/store/ky5d0ax3d1kkdp2h84n2hvdc3xgr0cql-etc/etc


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "etc" "$_localstatus"
fi

#### Activation script snippet hashes:
_localstatus=0
users=()
while IFS=: read -r user hash _; do
  if [[ "$hash" = "$"* && ! "$hash" =~ ^\$(y|gy|7|2b|2y|2a|6)\$ ]]; then
    users+=("$user")
  fi
done </etc/shadow

if (( "${#users[@]}" )); then
  echo "
WARNING: The following user accounts rely on password hashing algorithms
that have been removed. They need to be renewed as soon as possible, as
they do prevent their users from logging in."
  printf ' - %s\n' "${users[@]}"
fi


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "hashes" "$_localstatus"
fi

#### Activation script snippet specialfs:
_localstatus=0
specialMount() {
  local device="$1"
  local mountPoint="$2"
  local options="$3"
  local fsType="$4"

  if mountpoint -q "$mountPoint"; then
    local options="remount,$options"
  else
    mkdir -p "$mountPoint"
    chmod 0755 "$mountPoint"
  fi
  echo mount -t "$fsType" -o "$options" "$device" "$mountPoint"
}
#source /nix/store/295wlclm8brxmrxp922rpcfxjjwh8mcn-mounts.sh


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "specialfs" "$_localstatus"
fi

#### Activation script snippet usrbinenv:
_localstatus=0
mkdir -p /usr/bin
chmod 0755 /usr/bin
ln -sfn /nix/store/4384fl7d33ajhzszjr64nqdiv5sp9nqz-coreutils-9.5/bin/env /usr/bin/.env.tmp
mv /usr/bin/.env.tmp /usr/bin/env # atomically replace /usr/bin/env


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "usrbinenv" "$_localstatus"
fi

#### Activation script snippet var:
_localstatus=0


if (( _localstatus > 0 )); then
  printf "Activation script snippet '%s' failed (%s)\n" "var" "$_localstatus"
fi


# Make this configuration the current configuration.
# The readlink is there to ensure that when $systemConfig = /system
# (which is a symlink to the store), /run/current-system is still
# used as a garbage collection root.
ln -sfn "$(readlink -f "$systemConfig")" /run/current-system

exit $_status
