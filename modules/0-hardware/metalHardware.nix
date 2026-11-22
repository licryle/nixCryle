{ self, inputs, ... }: {
  # Non-GUI system config. Extends coreConfig with boot, networking, hardware services.
  # Safe for bare-metal and VMs. NOT for WSL.
  flake.nixosModules.metalHardware = { pkgs, ... }: {
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
  };
}
