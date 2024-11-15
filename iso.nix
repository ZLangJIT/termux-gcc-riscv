{ config, pkgs, lib, ... }:

with config;
with lib;

{

  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # qemu reads from ttyS0
  boot.kernelParams = [ "console=ttyS0" ];

  system.stateVersion = "24.05";

  system.build.bootStage1 = mkForce (pkgs.writeScript "stage1" ''
    #!${shell}
    echo
    echo "[1;32m<<< NixOS Stage 1 >>>[0m"
    echo
    exec bash
  '');

  system.build.initialRamdisk = mkForce (pkgs.makeInitrd {
    contents = [ { object = system.build.bootStage1; symlink = "/init"; } ];
  });

  # no lvm

  # Some additional utilities needed in stage 1, like mount, fsck
  # etc.  We don't want to bring in all of those packages, so we just
  # copy what we need.  Instead of using statically linked binaries,
  # we just copy what we need from Glibc and use patchelf to make it
  # work.
  system.build.extraUtils = mkForce (pkgs.runCommand "extra-utils"

    { nativeBuildInputs = with pkgs.buildPackages; [ nukeReferences bintools ];
      allowedReferences = [ "out" ]; # prevent accidents like glibc being included in the initrd
    }
    ''
      set +o pipefail

      mkdir -p $out/bin $out/lib
      ln -s $out/bin $out/sbin

      copy_bin_and_libs () {
        [ -f "$out/bin/$(basename $1)" ] && rm "$out/bin/$(basename $1)"
        cp -pdv $1 $out/bin
      }

      # Copy BusyBox.
      for BIN in ${pkgs.busybox}/{s,}bin/* # */
	do
          copy_bin_and_libs $BIN
      done

      ${optionalString zfsRequiresMountHelper ''
        # Filesystems using the "zfsutil" option are mounted regardless of the
        # mount.zfs(8) helper, but it is required to ensure that ZFS properties
        # are used as mount options.
        #
        # BusyBox does not use the ZFS helper in the first place.
        # util-linux searches /sbin/ as last path for helpers (stage-1-init.sh
        # must symlink it to the store PATH).
        # Without helper program, both `mount`s silently fails back to internal
        # code, using default options and effectively ignore security relevant
        # ZFS properties such as `setuid=off` and `exec=off` (unless manually
        # duplicated in `fileSystems.*.options`, defeating "zfsutil"'s purpose).
        copy_bin_and_libs ${lib.getOutput "mount" pkgs.util-linux}/bin/mount
        copy_bin_and_libs ${config.boot.zfs.package}/bin/mount.zfs
      ''}

      # Copy some util-linux stuff.
      copy_bin_and_libs ${pkgs.util-linux}/sbin/blkid

      # Copy udev.
      copy_bin_and_libs ${config.systemd.package}/bin/udevadm
      copy_bin_and_libs ${config.systemd.package}/lib/systemd/systemd-sysctl
      for BIN in ${config.systemd.package}/lib/udev/*_id # */
	do
          copy_bin_and_libs $BIN
      done
      # systemd-udevd is only a symlink to udevadm these days
      ln -sf udevadm $out/bin/systemd-udevd

      # Copy modprobe.
      copy_bin_and_libs ${pkgs.kmod}/bin/kmod
      ln -sf kmod $out/bin/modprobe

      # Copy multipath.
      ${optionalString config.services.multipath.enable ''
        copy_bin_and_libs ${config.services.multipath.package}/bin/multipath
        copy_bin_and_libs ${config.services.multipath.package}/bin/multipathd
        # Copy lib/multipath manually.
        cp -rpv ${config.services.multipath.package}/lib/multipath $out/lib
      ''}

      # Copy secrets if needed.
      #
      # TODO: move out to a separate script; see #85000.
      ${optionalString (!config.boot.loader.supportsInitrdSecrets)
          (concatStringsSep "\n" (mapAttrsToList (dest: source:
             let source' = if source == null then dest else source; in
               ''
                  mkdir -p $(dirname "$out/secrets/${dest}")
                  # Some programs (e.g. ssh) doesn't like secrets to be
                  # symlinks, so we use `cp -L` here to match the
                  # behaviour when secrets are natively supported.
                  cp -Lr ${source'} "$out/secrets/${dest}"
                ''
          ) config.boot.initrd.secrets))
       }

      ${config.boot.initrd.extraUtilsCommands}

      # Copy ld manually since it isn't detected correctly
      cp -pv ${pkgs.stdenv.cc.libc.out}/lib/ld*.so.? $out/lib

      # Copy all of the needed libraries in a consistent order so
      # duplicates are resolved the same way.
      find $out/bin $out/lib -type f | sort | while read BIN; do
        echo "Copying libs for executable $BIN"
        for LIB in $(${findLibs}/bin/find-libs $BIN); do
          TGT="$out/lib/$(basename $LIB)"
          if [ ! -f "$TGT" ]; then
            SRC="$(readlink -e $LIB)"
            cp -pdv "$SRC" "$TGT"
          fi
        done
      done

      # Strip binaries further than normal.
      chmod -R u+w $out
      stripDirs "$STRIP" "$RANLIB" "lib bin" "-s"

      # Run patchelf to make the programs refer to the copied libraries.
      find $out/bin $out/lib -type f | while read i; do
        nuke-refs -e $out $i
      done

      find $out/bin -type f | while read i; do
        echo "patching $i..."
        patchelf --set-interpreter $out/lib/ld*.so.? --set-rpath $out/lib $i || true
      done

      find $out/lib -type f \! -name 'ld*.so.?' | while read i; do
        echo "patching $i..."
        patchelf --set-rpath $out/lib $i
      done

      if [ -z "${toString (pkgs.stdenv.hostPlatform != pkgs.stdenv.buildPlatform)}" ]; then
      # Make sure that the patchelf'ed binaries still work.
      echo "testing patched programs..."
      $out/bin/ash -c 'echo hello world' | grep "hello world"
      ${if zfsRequiresMountHelper then ''
        $out/bin/mount -V 1>&1 | grep -q "mount from util-linux"
        $out/bin/mount.zfs -h 2>&1 | grep -q "Usage: mount.zfs"
      '' else ''
        $out/bin/mount --help 2>&1 | grep -q "BusyBox"
      ''}
      $out/bin/blkid -V 2>&1 | grep -q 'libblkid'
      $out/bin/udevadm --version
      $out/bin/dmsetup --version 2>&1 | tee -a log | grep -q "version:"
      LVM_SYSTEM_DIR=$out $out/bin/lvm version 2>&1 | tee -a log | grep -q "LVM"
      ${optionalString config.services.multipath.enable ''
        ($out/bin/multipath || true) 2>&1 | grep -q 'need to be root'
        ($out/bin/multipathd || true) 2>&1 | grep -q 'need to be root'
      ''}

      ${config.boot.initrd.extraUtilsCommandsTest}
      fi
    '');

  boot.initrd.availableKernelModules = [ ];

  #boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" ];
  boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" "virtio_gpu" ];

  xdg.autostart.enable = mkDefault false;
  xdg.icons.enable = mkDefault false;
  xdg.mime.enable = mkDefault false;
  xdg.sounds.enable = mkDefault false;

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

    # Use less privileged nixos user
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      # Allow the graphical user to login without password
      initialHashedPassword = "";
    };

    # Allow the user to log in as root without a password.
    users.users.root.initialHashedPassword = "";

    # Don't require sudo/root to `reboot` or `poweroff`.
    security.polkit.enable = true;

    # Allow passwordless sudo from nixos user
    security.sudo = {
      enable = mkDefault true;
      wheelNeedsPassword = mkImageMediaOverride false;
    };

    # Automatically log in at the virtual consoles.
    services.getty.autologinUser = "nixos";

    # Some more help text.
    services.getty.helpLine = ''
      The "nixos" and "root" accounts have empty passwords.

      To log in over ssh you must set a password for either "nixos" or "root"
      with `passwd` (prefix with `sudo` for "root"), or add your public key to
      /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

      If you need a wireless connection, type
      `sudo systemctl start wpa_supplicant` and configure a
      network using `wpa_cli`. See the NixOS manual for details.
    '' + optionalString services.xserver.enable ''

      Type `sudo systemctl start display-manager' to
      start the graphical user interface.
    '';

    # allow nix-copy to live system
    nix.settings.trusted-users = [ "root" "nixos" ];

    # Prevent installation media from evacuating persistent storage, as their
    # var directory is not persistent and it would thus result in deletion of
    # those entries.
    environment.etc."systemd/pstore.conf".text = ''
      [PStore]
      Unlink=no
    '';

    networking.firewall.logRefusedConnections = mkDefault false;


  #config.nixpkgs.hostPlatform = "riscv64-linux";

  # required and default packages are controlled via
  # nixpkgs/nixos/modules/config/system-path.nix

  # systemd units are controlled via
  # nixpkgs/nixos/modules/system/boot/systemd.nix
  # nixpkgs/nixos/modules/system/boot/systemd/initrd.nix

}
