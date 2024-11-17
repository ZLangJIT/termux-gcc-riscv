echo "removing nix_chroot..."
chmod -R 700 $PREFIX/nix_chroot
rm -rf $PREFIX/nix_chroot
echo "done"
./termux_nix_install_proot.sh
