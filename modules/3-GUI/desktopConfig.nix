{ self, inputs, ... }: {
  # Full desktop/GUI config. Extends systemConfig (which extends coreConfig).
  # NOT for WSL or headless systems.
  flake.nixosModules.desktopConfig = { pkgs, user, keyboardLayout, ... }: {
    virtualisation.vmware.guest.enable = true;

    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = keyboardLayout;
      variant = "";
    };

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services = {
      gvfs.enable = true;
      dbus.packages = [ pkgs.gvfs ];
      udisks2.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      # Useful apps
      google-chrome
      vlc
      # VMware
      pkgs.open-vm-tools
      # Wayland clipboard
      wl-clipboard
      wl-clip-persist
      wtype
      xclip
      # File manager
      pcmanfm
      gvfs
      file-roller
      lxterminal
      # Themes & Icons
      qt6Packages.qt6ct
      papirus-icon-theme
    ];

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    home-manager.users.${user} = {
      

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
