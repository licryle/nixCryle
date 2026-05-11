{ inputs, self, user, nixOsVersion, keyboardLayout, ... }:

let
  proCryleModules = [
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

in {
# sudo nixos-rebuild switch --flake .#proCryle --impure
  flake.nixosConfigurations = {
    proCryle = inputs.nixpkgs.lib.nixosSystem {
      modules =
        proCryleModules
        ++ [ 
          self.nixosModules.impureHardware
          self.nixosModules.metalHardware
        ];

      inherit specialArgs;
    };
  
    proCryleSD = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        proCryleModules
        ++ [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-x86_64.nix"

          {
            image.fileName = "proCryle.img";
          }
        ];

      inherit specialArgs;
    };
  };
}
