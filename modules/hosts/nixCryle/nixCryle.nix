{ inputs, self, user, nixOsVersion, ... }: {
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      /etc/nixos/hardware-configuration.nix
      self.nixosModules.baseConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      inputs.home-manager.nixosModules.home-manager
      inputs.sysc-greet.nixosModules.default
      self.nixosModules.userLicryle
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion;
    };
  };
}