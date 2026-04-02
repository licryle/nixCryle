{ inputs, self, system, nixOsVersion, ... }: {
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {    
    specialArgs = { inherit inputs self system nixOsVersion; };

    modules = [
      self.nixosModules.hardwareConfig
      self.nixosModules.baseConfig
      self.nixosModules.devTools
      self.nixosModules.china

      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.userLicryle
    ];

  };
}
