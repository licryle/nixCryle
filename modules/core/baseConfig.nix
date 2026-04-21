{inputs, ...}: {
  flake.nixosModules.baseConfig = { pkgs, nixOsVersion, keyboardLayout, ... }: {
    networking.networkmanager.enable = true;
    nixpkgs.config.allowUnfree = true;

    virtualisation.vmware.guest.enable = true;

    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    system.stateVersion = nixOsVersion;
    system.autoUpgrade = {
      enable = true;
      flake = "github:licryle/nixCryle";
      dates = "daily";
      flags = [
        "-L"
        "--impure"
        "--no-write-lock-file"
      ];
      allowReboot = false;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2w";
    };

    ##############################

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
    time.timeZone="Asia/Shanghai";

    console.keyMap = keyboardLayout;

    services.xserver.enable = true;
    services.xserver.xkb = {
        layout = keyboardLayout;
        variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.upower.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    programs.fish = {
        enable = true;

        shellAliases = {
          nixos-edit = "sudo vim /etc/nixos/configuration.nix && sudo nixos-rebuild switch";
          noctalia-save-settings = "nix run .\#noctalia ipc call state all > ./modules/features/noctalia.json";
        }; 
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    environment.systemPackages = with pkgs; [
      # Shell stuff
      coreutils
      bash
      vim
      lf
      gnugrep
      wget
      fzf
      fishPlugins.fzf-fish
      htop
      # Useful apps
      google-chrome
      vlc
      #vmware
      pkgs.open-vm-tools
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

    services = {
      gvfs.enable = true;
      dbus.packages = [ pkgs.gvfs ];
      udisks2.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    programs.ssh.extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
        TCPKeepAlive yes
    '';

    hardware.bluetooth.enable = true;


    services.sysc-greet = {
      enable = true;
      compositor = "niri";
    };

    programs.dconf.enable = true;
  };
}
