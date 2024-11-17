NIX_CHROOT=/data/data/com.termux/files/usr/nix_chroot
NIX_CHROOT_TARGET=$NIX_CHROOT
#NIX_CHROOT_TARGET=$NIX_CHROOT/mnt

export OPTS=""

if [[ $NIX_CHROOT != $NIX_CHROOT_TARGET ]] ; then
	echo "finding installed packages..."
	NIXPKG=$TMPDIR/nixpkgs_list
	NIXCAND=$TMPDIR/nixpkgs_list_c
	(cd $NIX_CHROOT/nix/store ; find -maxdepth 1 | sed -e "s#\./##g") > $NIXPKG
	echo "found $(cat $NIXPKG | wc -l) packages"

	function bind_path_store() {
		(grep "$1" $NIXPKG || true) > $NIXCAND
		for pkg in $(cat $NIXCAND | xargs) ; do
			if [[ -L $NIX_CHROOT/nix/store/$pkg$2$3 || -e $NIX_CHROOT/nix/store/$pkg$2$3 ]] ; then
				echo "binding $pkg"
				export OPTS="$OPTS -b $NIX_CHROOT/nix/store/$pkg:/nix/store/$pkg"
				break
			fi
		done
	}

	function bind_path_raw() { echo "binding $1" ; export OPTS="$OPTS -b $NIX_CHROOT$1:$1"; }

	bind_path_store bash-5 /bin
	bind_path_store bash-interactive-5 /bin
	bind_path_store glibc-2.3 /lib
	bind_path_store glibc-2.3 /bin
	bind_path_store readline /lib
	bind_path_store ncurses /lib
	bind_path_store system-path /bin
	bind_path_store coreutils /bin
	bind_path_store acl /lib
	bind_path_store attr /lib
	bind_path_store nixos-system
	bind_path_store etc /etc /profile
	bind_path_store etc-bashrc
	bind_path_store etc-profile
	bind_path_store etc-shells
	bind_path_store set-environment
	bind_path_store sudoers
	bind_path_store bash-completion
	bind_path_store tzdata
	bind_path_store vconsole.conf
	bind_path_store iana-etc
	bind_path_store etc-resolv
	bind_path_store etc-hostname
	bind_path_store etc-host
	bind_path_store os-release
	bind_path_store hosts
	bind_path_store hostid
	bind_path_store locale.conf
	bind_path_store glibc-locale
	bind_path_store inputrc
	bind_path_store etc-man
	bind_path_store grub
	bind_path_store lsb-release
	bind_path_store util /bin /ls
	bind_path_store nix.conf
	bind_path_store nix /bin /nix
	bind_path_store coreutils-full /bin
	bind_path_store nano /bin /nano
	bind_path_store nanorc
	bind_path_store linux-pam /lib
	bind_path_store procps
	bind_path_store kbd
	bind_path_store openssl
	bind_path_store gmp-with-cxx
        bind_path_store 8i6ni7xnx7xq7cma27gjhvzw6zwnq8pf-gmp-with-cxx-6.3.0
	bind_path_store which
	bind_path_store findutils
	bind_path_store sodium
	bind_path_store editline
	bind_path_store lowdown
	bind_path_store 2mcbvjdjb2cp2qjqxc220cjjg09qgg2q-boehm-gc-8.2.6
	bind_path_store keyutils
	bind_path_store krb5
	bind_path_store libunistring
	bind_path_store bzip2
	bind_path_store xz
	bind_path_store brotli
	bind_path_store xml2
	bind_path_store aws-c-common
	bind_path_store aws-c-auth
	bind_path_store aws-c-http
	bind_path_store aws-c-sdkutil
	bind_path_store aws-c-compress
	bind_path_store aws-check
	bind_path_store aws-c-cal
	bind_path_store aws-c-s3
	bind_path_store aws-c-event
	bind_path_store zstd
	bind_path_store psl /lib
	bind_path_store s2n /lib
	bind_path_store curl /bin /curl
	bind_path_store sqlite /lib /libsqlite.so.1
	bind_path_store ssh2
	bind_path_store 5vq5pk4zq5qjg55zymqrl1ypna8qf13q-gcc-13.2.0-lib
	bind_path_store 4yw6z9dxy750jfccbligy1kh0vggflb5-gcc-13.2.0-libgcc
	bind_path_store libarchive

	bind_path_raw /init.sh
	bind_path_raw /bin
	bind_path_raw /etc
	bind_path_raw /home
	bind_path_raw /run
	bind_path_raw /root
	bind_path_raw /var
	bind_path_raw /usr
	bind_path_raw /tmp
fi

env -i proot --cwd=/ --sysvipc --ashmem-memfd -L --kill-on-exit -l -b "$NIX_CHROOT_TARGET:/" -b "/proc:/proc" -b "/dev:/dev" -b "/sys:/sys" $OPTS -0 /init.sh $@
