{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  # sudo nixos-rebuild switch --flake .#airCryle --impure
  flake.nixosConfigurations.airCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.impureHardware
      self.nixosModules.metalHardware
      self.nixosModules.appleIntelHardware
      self.nixosModules.tuiSystem
      self.nixosModules.niriDesktop
      {
        networking.hostName = "airCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
