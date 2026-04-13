{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.baseSystem
      {
        networking.hostName = "nixCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
