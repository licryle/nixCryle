{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {

  # sudo nixos-rebuild switch --flake .#nixCryle --impure
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.baseSystemImpureHardware
      {
        networking.hostName = "nixCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
