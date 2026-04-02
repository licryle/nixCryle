{ inputs, self, system, ... }: {
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {    
    specialArgs = { inherit inputs self ; };

    system = system;

    modules = [
      self.nixosModules.hardwareConfig
      self.nixosModules.baseConfig

      self.nixosModules.devTools
      self.nixosModules.china

      self.nixosModules.niri

      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.userLicryle
    ];

  };
}
