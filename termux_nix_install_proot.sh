#!/usr/bin/env -S bash -i

# exit on any non-zero return code from any command
set -e -o pipefail

NIX_ISO=$TMPDIR/nix.iso
NIX_CHROOT=$PREFIX/nix_chroot
NIX_CHROOT_ISO=$PREFIX/nix_chroot_iso

if [[ ! -e $NIX_CHROOT/nix/store ]] ; then
	if [[ ! -e $NIX_CHROOT_ISO/nix-store.squashfs ]] ; then
		if [[ ! -e $NIX_ISO ]] ; then
			if [[ -e $NIX_ISO.tmp ]] ; then
				rm -v $NIX_ISO.tmp
			fi
			wget --no-verbose --show-progress https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-aarch64-linux.iso -O $NIX_ISO.tmp
			mv -v $NIX_ISO.tmp $NIX_ISO
		fi
		if [[ ! -e $(command -v bsdtar) ]] ; then
			apt update
			apt install -y bsdtar
		fi
	        if [[ ! -e $NIX_CHROOT_ISO ]] ; then
			mkdir $NIX_CHROOT_ISO
			chmod 700 $NIX_CHROOT_ISO
		fi
		echo "extracting iso..."
		cd $NIX_CHROOT_ISO
		bsdtar xmf $NIX_ISO
		chmod -R 755 $NIX_ISO
	fi
	if [[ ! -e $(command -v rdsquashfs) ]] ; then
		apt update
		apt install -y squashfs-tools-ng
	fi
	echo "unpacking squashfs..."
	rdsquashfs -u / -C  -p $NIX_CHROOT/nix/store $NIX_CHROOT_ISO/nix-store.squashfs
fi

if [[ ! -e $NIX_CHROOT/proc ]] ; then
	mkdir -p $NIX_CHROOT/dev $NIX_CHROOT/proc $NIX_CHROOT/sys
fi

#if [[ ! -e $NIX_CHROOT/etc ]] ; then
#	echo "finding /etc in /nix/store/*etc/"
#	ETC=$(find $NIX_CHROOT/nix/store/*etc/ -type d -path '*/etc' | tail -n 1 | sed -e "s#$NIX_CHROOT##")
#	echo $ETC
#	echo "copying $ETC to /"
#	cp -r $NIX_CHROOT$ETC $NIX_CHROOT
#	chmod 755 $NIX_CHROOT/etc
#fi

#cp -v $PREFIX/etc/resolv.conf $NIX_CHROOT/etc

#if [[ ! -e $NIX_CHROOT/empty ]] ; then
#	mkdir -p $NIX_CHROOT/empty
#fi

#if [[ ! -e $NIX_CHROOT/bin ]] ; then
#	mkdir -p $NIX_CHROOT/bin
#fi

#export NPATH=/empty

#echo "finding installed packages..."
#NIXPKG=$TMPDIR/nixpkgs_list
#NIXCAND=$TMPDIR/nixpkgs_list_c
#(cd $NIX_CHROOT/nix/store ; find -maxdepth 1 | sed -e "s#\./##g") > $NIXPKG
#echo "found $(cat $NIXPKG | wc -l) packages"

function find_path_() {
	(grep "$1" $NIXPKG || true) > $NIXCAND
	for pkg in $(cat $NIXCAND | xargs) ; do
		#echo "CHECKING: \$PREFIX/nix_chroot/nix/store/$pkg$2$3"
		if [[ -L $NIX_CHROOT/nix/store/$pkg$2$3 || -e $NIX_CHROOT/nix/store/$pkg$2$3 ]] ; then
			echo "found $pkg$2$3"
			export NPATH="$NPATH:/nix/store/$pkg$2"
			break
		fi
	done
}

function link_() {
	(grep "$1" $NIXPKG || true) > $NIXCAND
	for pkg in $(cat $NIXCAND | xargs) ; do
		#echo "CHECKING: \$PREFIX/nix_chroot/nix/store/$pkg$2$3"
		if [[ -L $NIX_CHROOT/nix/store/$pkg$2$3 || -e $NIX_CHROOT/nix/store/$pkg$2$3 ]] ; then
			echo "found $pkg/2$3"
			export NPATH="$NPATH:/nix/store/$pkg$2"
			old=$(pwd)
			echo "linking contents..."
			cd $NIX_CHROOT/nix/store/$pkg$2
			find -exec bash -c "p=\$(printf \"{}\" | grep -v -e '^.$' | sed -e 's#\./##g') ; if [[ ! -z \$p ]] ; then if ln -s /nix/store/$pkg$2/\$p $NIX_CHROOT$2/\$p ; then echo \"$pkg$2/\$p -> $2/\$p\" ; else echo \"$2/\$p already exists\" ; fi ; fi" \; || true
			cd $old
			break
		fi
	done
}

function find_path() {
	find_path_ $1 /bin $2
	find_path_ $1 /sbin $2
}

function find_and_link_path() {
	link_ $1 /bin $2
	link_ $1 /sbin $2
}

#find_path coreutils
#find_path gnugrep
#find_path findutils
#find_path getent-glibc
#find_path glibc-2
#find_path shadow /shadow
#find_path net-tools
#find_path util-linux
#find_path nix /nix
#find_path nano /nano
#find_path nixos /nixos-install
#find_path nixos /nixox-rebuild
#find_path path /bash
#find_and_link_path bash-interactive /bash

#/nix/store/fnzgdg4h11n962m2b80bv6jp5yvjdy0z-perl-5.38.2-env/bin/perl \
#/nix/store/rg5rf512szdxmnj9qal3wfdnpfsx38qi-setup-etc.pl \
#/nix/store/ky5d0ax3d1kkdp2h84n2hvdc3xgr0cql-etc/etc


#echo "exporting paths to /etc/profile"
#echo "export PATH=\$PATH:$NPATH" >> $NIX_CHROOT/$(readlink $NIX_CHROOT/etc/profile)

#echo "listing contents of /"
#ls -l $NIX_CHROOT

cp activate_proot.sh $NIX_CHROOT/activate_proot.sh

cat << EOF > $NIX_CHROOT/init.sh
#!/nix/store/psz650xdnl6z94larfkrplng1fvg2aik-bash-5.2p32/bin/bash
export TERM=xterm-256color
export LC_ALL=C
export SHELL=bash
export NIX_PATH='nixpkgs=channel:nixos-24.05'


if [ \$# == 0 ] ; then
	cmd=
	args=
else
	cmd="-c"
	args="\"\$@\""
fi

eval exec /nix/store/4l95pg51sd92r5lpwvh2yd5l640xfhh3-bash-interactive-5.2p32/bin/bash -i -l \$cmd \$args
EOF
chmod +x $NIX_CHROOT/init.sh

echo "running activation script"
env -i proot --cwd=/ --sysvipc --ashmem-memfd -L --kill-on-exit -l -b "$NIX_CHROOT:/" -b "/proc:/proc" -b "/dev:/dev" -b "/sys:/sys" -0 /init.sh /activate_proot.sh

rm $NIX_CHROOT/activate_proot.sh

echo "copying host resolv.conf"

cp $PREFIX/etc/resolv.conf $NIX_CHROOT/etc

chmod +x nixos_shell.sh

if [[ ! -e $NIX_CHROOT/nix_channel ]] ; then
	if [[ ! -e $NIX_CHROOT/nix_channel.xz ]] ; then
		echo "downloading channel..."
		wget --no-verbose --show-progress "https://channels.nixos.org/nixos-24.05/nixexprs.tar.xz" -O $NIX_CHROOT/nix_channel.xz
	fi
	echo "unpacking channel..."
	mkdir -m 0755 $NIX_CHROOT/nix_channel_tmp
	tar --dir $NIX_CHROOT/nix_channel_tmp -Jxf $NIX_CHROOT/nix_channel.xz
	mv $NIX_CHROOT/nix_channel_tmp/* $NIX_CHROOT/nix_channel
	rm -rf $NIX_CHROOT/nix_channel_tmp $NIX_CHROOT/nix_channel.xz
fi


cat << EOF > $NIX_CHROOT/install.sh
#!/nix/store/psz650xdnl6z94larfkrplng1fvg2aik-bash-5.2p32/bin/bash

#nixos-generate-config --no-filesystems --root /mnt
#nixos-install -v -v -v --no-bootloader --no-root-password --root /mnt --debug

echo "installing ..."

if [[ ! -e /mnt/nix/store ]] ; then
	mkdir -p /mnt/nix/store
	chmod -R 755 /mnt
	chmod -R 700 /mnt/nix
fi

export NIX_PATH="nixpkgs=/nix_channel"

#echo "dropping to nix repl..."
#nix repl --store /mnt "<nixpkgs>"
#echo "continuing installation..."

nix-build --store /mntx86 --out-link /tmp/bash "<nixpkgs>" -A pkgs.linux --option system x86_64-linux
nix-build --store /mnt --out-link /tmp/bash "<nixpkgs>" -A pkgs.bashInteractive -A pkgs.nix -A pkgs.coreutils-full
nix-env --verbose --store /mnt -p /mnt/nix/var/nix/profiles/bash --set "\$(readlink -f /tmp/bash)"

if [[ ! -e /mnt/etc ]] ; then
	mkdir -m 0755 /mnt/etc
	echo 'export NIX_PATH="nixpkgs=/nix_channel"' >> /mnt/etc/profile
	touch /mnt/etc/NIXOS
fi

cat <<EOF2 > /mnt/init.sh
#!\$(readlink -f /tmp/bash)/bin/bash
export PATH="\$(readlink -f /tmp/bash)/bin"
export TERM=xterm
exec bash -i -l
EOF2
chmod +x /mnt/init.sh

echo "entering chroot"
chroot /mnt /init.sh
echo "installation finished"
EOF

chmod +x $NIX_CHROOT/install.sh

./nixos_shell.sh /install.sh
