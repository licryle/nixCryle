{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  # sudo nixos-rebuild switch --flake .#gameCryle --impure
  # or better
  # nix flake update && sudo nixos-rebuild switch --flake .#gameCryle --impure
  flake.nixosConfigurations.gameCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.impureHardware
      self.nixosModules.metalHardware
      
      ({ config, ... }: {
        users.users.${user}.extraGroups = [ "kvm" ];

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.graphics.enable = true;

        hardware.nvidia = {
          modesetting.enable = true;
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      })

      self.nixosModules.tuiSystem
      self.nixosModules.gaming

      self.nixosModules.niriNoctaliaDesktop
      {
        networking.hostName = "gameCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
