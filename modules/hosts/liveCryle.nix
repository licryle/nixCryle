{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  flake.nixosConfigurations.liveCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      self.nixosModules.metalHardware
      self.nixosModules.tuiSystem
      self.nixosModules.niriDesktop
      {
        networking.hostName = "liveCryle";
        nixpkgs.hostPlatform = "x86_64-linux";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };

  # nix build .#liveCryle
  perSystem = { system, ... }: {
    packages.liveCryle = self.nixosConfigurations.liveCryle.config.system.build.isoImage;
  };
}
