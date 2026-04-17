{inputs, ...}: {
  flake.nixosModules.userLicryle = { pkgs, user, nixOsVersion, ... }: {
    users.users.${user} = {
        shell = pkgs.fish;
        isNormalUser = true;
        description = user;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };
    home-manager.users.${user} = { pkgs, ... }: {
      programs.git = {
      enable = true;
        settings = {
            user = {
            name  = "Cyrille Berliat";
            email = "cyrille@berliat.fr";
          };
        };
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

      programs.kitty = {
        enable = true;
        settings = {
          copy_on_select="clipboard";
          mouse_map="right press ungrabbed paste_from_clipboard";

          confirm_os_window_clok_bise = 0;
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

      # Theming
      gtk = {
        enable = true;

        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        cursorTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          icon-theme = "Papirus-Dark";
          cursor-theme = "Adwaita";
        };
      };
    };
  };
}