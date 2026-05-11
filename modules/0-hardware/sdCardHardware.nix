{ inputs, ... }: {
  flake.nixosModules.sdCardHardware = { pkgs, lib, config, ... }: {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    users.users.licryle = {
      initialPassword = "hell0Me";
    };

    disko.devices.disk.main = {
      imageSize = "29G";
      type = "disk";
      device = lib.mkDefault "/dev/sda"; 
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "root";
              # Required for build: Path to a file containing your temp passphrase
              passwordFile = "/tmp/luks-password.txt"; 
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };

    # CRITICAL: Make the image boot on generic hardware
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false; # Don't mess with host's NVRAM
    boot.loader.efi.efiSysMountPoint = "/boot"; # Better Mac Intel detection of USB stick

    # Modern way to handle auto-expansion in Initrd
    boot.initrd.availableKernelModules = [ "usb_storage" "uas" "xhci_pci" "ahci" "nvme" "sd_mod" ];
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.repart.enable = true;
    fileSystems."/".autoResize = true;
    
    # Performance optimizations for SD/USB
    fileSystems."/".options = [ "noatime" "nodiratime" ];
    fileSystems."/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "relatime" "nodev" "nosuid" "size=2G" "mode=1777" ];
    };

    # Ensure the kernel knows how to resize the filesystem on boot
    boot.initrd.systemd.extraBin = {
      resize2fs = "${pkgs.e2fsprogs}/bin/resize2fs";
    };

    zramSwap.enable = true;
  };
}
