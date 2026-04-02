{ inputs, ... }: {
  flake.nixosModules.hardwareConfig = { pkgs, ... }: {
    imports = [ ../hardware-configuration.nix ];
  };
}