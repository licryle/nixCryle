{ self, inputs, ... }: {
  # Non-GUI system config. Extends coreConfig with boot, networking, hardware services.
  # Safe for bare-metal and VMs. NOT for WSL.
  flake.nixosModules.metalHardware = { pkgs, lib, config, ... }:
    let
      # hardware-configuration.nix (pulled in by impureHardware) may declare
      # swap on a LUKS mapper device without declaring how to unlock it.
      # The mapper name is "luks-<uuid>", so derive the initrd unlock entry
      # from the swap device path instead of hardcoding any device ID here.
      luksSwaps = builtins.filter
        (s: lib.hasPrefix "/dev/mapper/luks-" (s.device or ""))
        config.swapDevices;

      luksUnlockEntries = lib.listToAttrs (map
        (s: let
          name = lib.removePrefix "/dev/mapper/" s.device; # luks-<uuid>
          uuid = lib.removePrefix "luks-" name;            # <uuid>
        in {
          inherit name;
          value.device = "/dev/disk/by-uuid/${uuid}";
        })
        luksSwaps);
    in {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.upower.enable = true;

    # On lid close: suspend first, then hibernate after 1 hour.
    # Applies when docked / on external power too (logind ignores the lid in
    # those cases by default).
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandleLidSwitchDocked = "suspend-then-hibernate";
    };

    # Delay before suspend-then-hibernate turns S3 into S4.
    systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

    boot.kernelParams = [
      "mem_sleep_default=deep"
    ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Derived from swapDevices: unlock encrypted swap before swap.target tries
    # to use it, avoiding the 90s device timeout at boot. No-op on machines
    # whose swap is not a LUKS mapper (e.g. zram-only tourCryle image).
    boot.initrd.luks.devices = luksUnlockEntries;

    # suspend-then-hibernate needs the resume device, otherwise S4 cannot
    # restore the image once swap is actually usable.
    boot.resumeDevice = lib.mkIf (luksSwaps != []) (builtins.head luksSwaps).device;
  };
}
