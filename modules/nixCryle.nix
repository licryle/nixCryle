{ inputs, ... }: {
  flake.nixosConfigurations.nixCryle = inputs.nixpkgs.lib.nixosSystem {
  };

  flake.nixosModules.nixCryle = { pkgs, ... }: {
    boot.loader.grub.enable = true;
  };
}
