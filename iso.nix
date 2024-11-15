{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  config.boot.kernelParams = [ "console=tty1" "boot.debugtrace" ];
  config.system.stateVersion = "24.05";

  config.boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  config.boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" "virtio_gpu" ];

  lib.xdg.autostart.enable = mkDefault false;
  lib.xdg.icons.enable = mkDefault false;
  lib.xdg.mime.enable = mkDefault false;
  lib.xdg.sounds.enable = mkDefault false;

  config.boot.blacklistedKernelModules = [
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
    config.users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      # Allow the graphical user to login without password
      initialHashedPassword = "";
    };

    # Allow the user to log in as root without a password.
    config.users.users.root.initialHashedPassword = "";

    # Don't require sudo/root to `reboot` or `poweroff`.
    config.security.polkit.enable = true;

    # Allow passwordless sudo from nixos user
    config.security.sudo = {
      enable = mkDefault true;
      wheelNeedsPassword = mkImageMediaOverride false;
    };

    # Automatically log in at the virtual consoles.
    config.services.getty.autologinUser = "nixos";

    # Some more help text.
    config.services.getty.helpLine = ''
      The "nixos" and "root" accounts have empty passwords.

      To log in over ssh you must set a password for either "nixos" or "root"
      with `passwd` (prefix with `sudo` for "root"), or add your public key to
      /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

      If you need a wireless connection, type
      `sudo systemctl start wpa_supplicant` and configure a
      network using `wpa_cli`. See the NixOS manual for details.
    '' + optionalString config.services.xserver.enable ''

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
