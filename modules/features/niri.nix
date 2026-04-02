{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.featureNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.featureNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;

      env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ 
        pkgs.libxcursor 
        pkgs.libx11
        pkgs.libxext
        pkgs.libxi        
        pkgs.libxrandr
        pkgs.libxinerama
      ];    

      v2-settings = true;
      settings = {        
        spawn-at-startup = [
          (lib.getExe self'.packages.featureNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb.layout = "es,es";

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Q".close-window = {};
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.featureNoctalia} ipc call launcher toggle";
        };
      };
    };
  };
}