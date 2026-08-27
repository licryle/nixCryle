{ self, inputs, user, keyboardLayout, ... }: {
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
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    programs.noctalia-greeter = {
      enable = true;

      settings = {
        keyboard = {
          layout = keyboardLayout;
        };
      };
    };
  };
}
