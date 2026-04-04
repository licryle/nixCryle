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
          "${pkgs.open-vm-tools}/bin/vmware-user"
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.wl-clipboard}/bin/wl-copy --primary --paste-once"
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input = {
          keyboard.xkb.layout = "es,es";

          touchpad = {
            click-method = "button-areas"; 
          };
        };

        layout.gaps = 5;

        binds = {
          "Ctrl+Space".spawn-sh = "${lib.getExe self'.packages.featureNoctalia} ipc call launcher toggle";
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Space".toggle-overview = { };

          "Mod+Q".close-window = { };
          "Ctrl+Alt+Delete".quit = { };

          # --- Navigation (Vim-style + Arrows) ---
          "Mod+Left".focus-column-left = { };
          "Mod+Right".focus-column-right = { };
          "Mod+Up".focus-window-up = { };
          "Mod+Down".focus-window-down = { };

          # --- Moving Windows ---
          "Mod+Ctrl+Left".move-column-left = { };
          "Mod+Ctrl+Right".move-column-right = { };
          "Mod+Ctrl+Up".move-window-up = { };
          "Mod+Ctrl+Down".move-window-down = { };

          # --- Sizing ---
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";
          "Mod+R".switch-preset-column-width = { };
          "Mod+F".maximize-column = { };
          "Mod+Shift+F".fullscreen-window = { };
          "Mod+C".center-column = { };

          # --- Workspaces (1-9) ---
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;
          
          "Mod+Ctrl+1".move-column-to-workspace = 1;
          "Mod+Ctrl+2".move-column-to-workspace = 2;
          "Mod+Ctrl+3".move-column-to-workspace = 3;
          "Mod+Ctrl+4".move-column-to-workspace = 4;
          "Mod+Ctrl+5".move-column-to-workspace = 5;
          "Mod+Ctrl+6".move-column-to-workspace = 6;
          "Mod+Ctrl+7".move-column-to-workspace = 7;
          "Mod+Ctrl+8".move-column-to-workspace = 8;
          "Mod+Ctrl+9".move-column-to-workspace = 9;

          # --- Mouse Wheel Support ---
          "Mod+WheelScrollDown".focus-workspace-down = { };
          "Mod+WheelScrollUp".focus-workspace-up = { };

          # --- Screenshots ---
          "Mod+P".screenshot-window = { };
          "Print".screenshot = { };
          "Mod+alt+P".screenshot-screen = { };
          "Ctrl+Print".screenshot-screen = { };
          "Alt+Print".screenshot-window = { };
        };
      };
    };
  };
}