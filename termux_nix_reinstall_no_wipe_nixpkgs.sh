echo "wiping nix_chroot without wiping /nix/store and /nix_channel ..."
if [[ -e $PREFIX/nix_chroot/nix/store ]] ; then
	mv $PREFIX/nix_chroot/nix/store nix_store__tmp
fi
if [[ -e $PREFIX/nix_chroot/nix_channel ]] ; then
	mv $PREFIX/nix_chroot/nix_channel nix_channel__tmp
fi
chmod -R 700 $PREFIX/nix_chroot
rm -rf $PREFIX/nix_chroot
mkdir -p $PREFIX/nix_chroot/nix
chmod -R 755 $PREFIX/nix_chroot
if [[ -e nix_store__tmp ]] ; then
	mv nix_store__tmp $PREFIX/nix_chroot/nix/store
fi
if [[ -e nix_channel__tmp ]] ; then
	mv nix_channel__tmp $PREFIX/nix_chroot/nix_channel
fi
echo "done"
./termux_nix_install_proot.sh
