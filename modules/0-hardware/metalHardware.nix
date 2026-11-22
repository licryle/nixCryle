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

    # Hibernate when the lid is closed, including when docked to an external
    # display (logind ignores the lid in that case by default).
    services.logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "hibernate";
      HandleLidSwitchDocked = "hibernate";
    };

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
