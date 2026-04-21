{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  flake.nixosConfigurations.proCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.baseSystemImpureHardware
      {
        networking.hostName = "proCryle";
      }

      ({ lib, pkgs, ... }: {
        nixpkgs.config = {
          allowUnfree = true;
          allowInsecurePredicate = pkg: lib.elem (lib.getName pkg) [
            "broadcom-sta"
          ];
        };

        boot = {
          kernelModules = [ "wl" ];
          extraModulePackages = [ pkgs.linuxPackages.broadcom_sta ];
        };
        boot.blacklistedKernelModules = [ "b43" "bcma" ];

        services.xserver.videoDrivers = [ "intel" ];
        hardware.graphics.enable = true;
        hardware.facetimehd.enable = true;
      })
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
