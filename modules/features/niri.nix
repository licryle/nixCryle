{ self, inputs, keyboardLayout, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.featureNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }:
  let 
    noct-exe = lib.getExe self'.packages.noctalia;
    noctalia = cmd: [
      "${noct-exe} ipc call ${cmd}"
    ];
  in
  {
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
          (lib.getExe self'.packages.noctalia)
          "${pkgs.open-vm-tools}/bin/vmware-user"
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.wl-clipboard}/bin/wl-copy --primary --paste-once"
        ];

        switch-events = {
          "lid-close" = {
            spawn = [ "sh" "-c" "${noct-exe} ipc call lockScreen lock" ];
          };
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input = {
          keyboard = {
            xkb.layout = keyboardLayout;
            numlock = true;
          };

          touchpad = {
            click-method = "button-areas"; 
          };

          disable-power-key-handling = true; # Don't let Niri handle the power button > straight to power off.
        };

        layout.gaps = 5;

        binds = {
          "Ctrl+Space".spawn-sh = noctalia "launcher toggle";
          "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;

          "XF86LaunchA".toggle-overview = { };
          "Mod+Space".toggle-overview = { };

          "Mod+Q".close-window = { };
          "Ctrl+Alt+Delete".quit = { };

          # --- Extra Copy/Paste / Undo / Redo
          "Mod+C".spawn-sh = "wtype -M ctrl c -m ctrl";
          "Mod+X".spawn-sh = "wtype -M ctrl x -m ctrl";
          "Mod+V".spawn-sh = "wtype -M ctrl v -m ctrl";
          "Mod+Z".spawn-sh = "wtype -M ctrl z -m ctrl";
          "Mod+Y".spawn-sh = "wtype -M ctrl y -m ctrl";

          # --- Toggle inputs
          "Alt+Space".spawn-sh = "${pkgs.fcitx5}/bin/fcitx5-remote -t";

          # --- Backlight
          "XF86KbdBrightnessUp".spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl -d 'smc::kbd_backlight' s 25%+";
          "XF86KbdBrightnessDown".spawn-sh = "${pkgs.brightnessctl}/bin/brightnessctl -d 'smc::kbd_backlight' s 25%-";

          # --- Navigation (Vim-style + Arrows) ---
          "Mod+Left".focus-column-left = { };
          "Mod+Right".focus-column-right = { };
          "Mod+Up".focus-window-up = { };
          "Mod+Down".focus-window-down = { };

          # --- Mouse Wheel Support ---
          "Mod+WheelScrollDown".focus-column-right = { };
          "Mod+WheelScrollUp".focus-column-left = { };

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
          "Mod+G".center-column = { };

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

          # --- Screenshots ---
          "Mod+P".screenshot-window = { };
          "Print".screenshot = { };
          "Mod+alt+P".screenshot-screen = { };
          "Ctrl+Print".screenshot-screen = { };
          "Alt+Print".screenshot-window = { };

          # ---Brightness ---
          "XF86MonBrightnessUp".spawn-sh =
            noctalia "brightness increase";
          "XF86MonBrightnessDown".spawn-sh =
            noctalia "brightness decrease";

          # Media keys
          "XF86AudioPrev".spawn-sh = noctalia "media previous";
          "XF86AudioPlay".spawn-sh = noctalia "media playPause";
          "XF86AudioNext".spawn-sh = noctalia "media next";

          "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioRaiseVolume".spawn-sh =
            noctalia "volume increase";
          "XF86AudioLowerVolume".spawn-sh =
            noctalia "volume decrease";
            
          # Lock screen
          "Ctrl+L".spawn-sh = noctalia "lockScreen lock";
          "Mod+L".spawn-sh =  noctalia "lockScreen lock";

          # Spotlight‑style launcher (Fn+Space)
          "XF86Search".spawn-sh = noctalia "launcher toggle";
          "XF86LaunchB".spawn-sh = noctalia "launcher toggle";
        };
      };
    };
  };
}