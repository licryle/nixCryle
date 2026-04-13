{ self, inputs, ... }: {
  flake.nixosModules.baseSystem = { ... }: {
    imports = [
      /etc/nixos/hardware-configuration.nix
      self.nixosModules.baseConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      self.nixosModules.userLicryle
      inputs.home-manager.nixosModules.home-manager
      inputs.sysc-greet.nixosModules.default
    ];
  };
}
