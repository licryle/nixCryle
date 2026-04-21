{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  # sudo nixos-rebuild switch --flake .#proCryle --impure
  flake.nixosConfigurations.proCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.impureHardware
      self.nixosModules.metalHardware
      self.nixosModules.appleIntelHardware
      {
        hardware.graphics.enable = true;
      }

      self.nixosModules.tuiSystem

      self.nixosModules.niriDesktop
      {
        networking.hostName = "proCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
