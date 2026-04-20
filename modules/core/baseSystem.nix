{ self, inputs, ... }: {
  flake.nixosModules.baseSystem = { config, lib, ... }: {
    imports = [
      self.nixosModules.baseConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      self.nixosModules.userLicryle
      inputs.home-manager.nixosModules.home-manager
      inputs.sysc-greet.nixosModules.default
    ];
  };

  flake.nixosModules.baseSystemImpureHardware = { config, lib, ... }: {
    imports = [
      self.nixosModules.baseSystem
      /etc/nixos/hardware-configuration.nix
    ];
  };
}
