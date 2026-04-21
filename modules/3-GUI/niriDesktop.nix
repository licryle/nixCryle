{ self, inputs, ... }: {
  # Full desktop stack: desktopConfig → systemConfig → coreConfig
  flake.nixosModules.niriDesktop = { config, lib, ... }: {
    imports = [
      self.nixosModules.desktopConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      inputs.sysc-greet.nixosModules.default
    ];

    services.sysc-greet = {
      enable = true;
      compositor = "niri";
    };
  };
}
