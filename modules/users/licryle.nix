{inputs, ...}: {
  flake.nixosModules.userLicryle = { inputs, pkgs, user, nixOsVersion, ... }: {    
    users.users.${user} = {
        shell = pkgs.fish;
        isNormalUser = true;
        description = user;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };

    imports = [
      inputs.nixos-modules.nixosModules.usbChime
    ];
    # USB connect/disconnect chime from licryle/nixos-modules.
    services.usbChime = {
      enable = true;
      user = user;
      theme = "COSMIC";
      volume = 3; # modest db boost
    };
  
    home-manager.users.${user} = { pkgs, ... }: {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia = {
        enable = true;
        settings = ./licryle/noctalia-v5.toml;
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
      };

      home.stateVersion = nixOsVersion; 
      home.file = {
        "Pictures/wallpaper.png".source = ./${user}/Pictures/wallpaper.png;
        "Pictures/profile.jpg".source = ./${user}/Pictures/profile.jpg;
        ".cache/noctalia/wallpapers.json" = {
          text = builtins.toJSON {
            defaultWallpaper = "/home/${user}/Pictures/wallpaper.png";
          };
        };
      };

      xdg.configFile."kitty/right_click.py".text = ''
        from kittens.tui.handler import result_handler

        def main(args):
            pass

        @result_handler(no_ui=True)
        def handle_result(args, answer, target_window_id, boss):
            window = boss.window_id_map.get(target_window_id)
            if window is None:
                return
            if window.text_for_selection():
                window.copy_to_clipboard()
                window.clear_selection()
            else:
                boss.paste_from_clipboard()
      '';

      # 2. Configure Kitty to run the kitten on right-click
      programs.kitty = {
        enable = true;
        settings = {
          mouse_map = "right press ungrabbed kitten right_click.py";

          confirm_os_window_close = 0;
          dynamic_background_opacity = true;
          enable_audio_bell = false;
          mouse_hide_wait = "-1.0";
          window_padding_width = 10;
          background_opacity = "0.5";
          background_blur = 5;
          symbol_map = let
            mappings = [
              "U+23FB-U+23FE"
              "U+2B58"
              "U+E200-U+E2A9"
              "U+E0A0-U+E0A3"
              "U+E0B0-U+E0BF"
              "U+E0C0-U+E0C8"
              "U+E0CC-U+E0CF"
              "U+E0D0-U+E0D2"
              "U+E0D4"
              "U+E700-U+E7C5"
              "U+F000-U+F2E0"
              "U+2665"
              "U+26A1"
              "U+F400-U+F4A8"
              "U+F67C"
              "U+E000-U+E00A"
              "U+F300-U+F313"
              "U+E5FA-U+E62B"
            ];
          in
            (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font";
        };
      };
    };
  };
}