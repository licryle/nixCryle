{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {

  # sudo nixos-rebuild switch --flake .#nixCryle --impure
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.impureHardware
      self.nixosModules.metalHardware
      self.nixosModules.tuiSystem
      self.nixosModules.niriDesktop
      {
        networking.hostName = "nixCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
