{ inputs, lib, self, user, nixOsVersion, keyboardLayout, ... }: {
  # read -s -l -P "Enter LUKS Passphrase: " PASS; echo "$PASS" > /tmp/luks-password.txt && nix build .#tourCryle && sudo ./result --build-memory 2048 --pre-format-files /tmp/luks-password.txt /tmp/luks-password.txt &&  rm /tmp/luks-password.txt
  flake.nixosConfigurations.tourCryle = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      self.nixosModules.metalHardware
      self.nixosModules.sdCardHardware {
        disko.devices.disk.main.content.partitions.boot.content.extraArgs = [ "-n" "TOURCRYLE" ]; 
      }

      self.nixosModules.appleIntelHardware
      {
        hardware.graphics.enable = true;
      }

      self.nixosModules.tuiSystem

      self.nixosModules.niriDesktop
      {
        networking.hostName = "tourCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };

  flake.packages.x86_64-linux.tourCryle =
    self.nixosConfigurations.tourCryle.config.system.build.diskoImagesScript;
}