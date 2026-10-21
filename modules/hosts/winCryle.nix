{ inputs, self, withSystem, user, nixOsVersion, keyboardLayout, ... }: {
  # WSL Config
  # sudo nixos-rebuild switch --flake .#winCryle
  # or better
  # nix flake update && sudo nixos-rebuild switch --flake .#winCryle
  flake.nixosConfigurations.winCryle = withSystem "x86_64-linux" ({ system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        self.nixosModules.wslHardware
        self.nixosModules.tuiSystem
        {
          networking.hostName = "winCryle";
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          nix.settings.extra-platforms = [ "aarch64-linux" ];
          programs.nix-ld.enable = true;
        }
      ];

      specialArgs = {
        inherit inputs self user nixOsVersion keyboardLayout;
      };
    }
  );
}
