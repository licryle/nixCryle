{ self, inputs, user, ... }: {
  # Full desktop stack: desktopConfig → systemConfig → coreConfig
  flake.nixosModules.niriNoctaliaDesktop = { config, lib, pkgs, ... }: {
    imports = [
      self.nixosModules.desktopConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      inputs.noctalia-greeter.nixosModules.default
      inputs.noctalia.nixosModules.default
    ];

    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.system}.default;
    };

    programs.noctalia-greeter = {
      enable = true;
      settings = ./noctalia-v5.toml;
    };
  };
}
