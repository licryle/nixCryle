{ self, inputs, ... }: {
  # Full desktop/GUI config. Extends systemConfig (which extends coreConfig).
  # NOT for WSL or headless systems.
  flake.nixosModules.wslHardware = { pkgs, keyboardLayout, user, ... }: {
    imports = [ inputs.nixos-wsl.nixosModules.default ];

    wsl = {
      enable = true;
      defaultUser = user;
    };

    boot.kernelModules = [ "vhci_hcd" ]; # Unable WSL to attach to USB devices from host with usbipd attach --wsl --busid 2-1
    environment.systemPackages = [ pkgs.kmod ];
  };
}