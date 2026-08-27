{ self, inputs, ... }: {
  # Full desktop stack: desktopConfig → systemConfig → coreConfig
  flake.nixosModules.niriDesktop = { config, lib, pkgs, ... }: {
    imports = [
      self.nixosModules.desktopConfig
      self.nixosModules.devTools
      self.nixosModules.china
      self.nixosModules.niri
      inputs.noctalia-greeter.nixosModules.default
    ];

    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.system}.default;
    };

    programs.noctalia-greeter = {
      enable = true;

      # Optional configuration
      greeter-args = "";
      # Full declarative greeter.toml (overwritten on each activation).
      # See examples/greeter.toml for every key (appearance.palette, output, …).
      settings = {
        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 24;
          path = "${pkgs.bibata-cursors}/share/icons";
        };
        keyboard = {
          layout = "es";
        };

        appearance = {
          palette = "Eldritch";
          mode = "dark";
          wallpaper = "/home/licryle/Pictures/wallpaper.png";
        };

        user = {
          avatar = "/home/licryle/Pictures/profile.jpg";
        };
      };
    };
  };
}
