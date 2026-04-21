{ self, inputs, ... }: {
  flake.nixosModules.impureHardware = { config, lib, ... }: {
    imports = [
      /etc/nixos/hardware-configuration.nix
    ];
  };
}
