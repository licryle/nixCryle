{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  flake.nixosConfigurations.proCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.baseSystemImpureHardware
      {
        networking.hostName = "proCryle";
      }

      self.nixosModules.appleIntel
      {
        hardware.graphics.enable = true;
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
