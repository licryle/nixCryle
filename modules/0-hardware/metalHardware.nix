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

    hardware.bluetooth.enable = true;
  };
}
