{ self, inputs, ... }: {
  # WSL stack: coreConfig only (no boot, no GUI, no Wayland IME)
  flake.nixosModules.tuiSystem = { config, lib, ... }: {
    imports = [
      self.nixosModules.coreConfig
      self.nixosModules.devTools
      self.nixosModules.userLicryle
      inputs.home-manager.nixosModules.home-manager
    ];
  };
}
