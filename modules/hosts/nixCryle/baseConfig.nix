{inputs, nixOsVersion, ...}: {
  flake.nixosModules.baseConfig = { pkgs, ... }: {
    networking.hostName = "nixCryle"; # Define your hostname.
    networking.networkmanager.enable = true;
    nixpkgs.config.allowUnfree = true;

    virtualisation.vmware.guest.enable = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = nixOsVersion;

    ##############################

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    i18n.defaultLocale = "fr_FR.UTF-8";
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

    console.keyMap = "es";

    services.xserver.enable = true;
    services.xserver.xkb = {
        layout = "es";
        variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    programs.zsh = {
        enable = true;

        shellAliases = {
          nixos-edit = "sudo vim /etc/nixos/configuration.nix && sudo nixos-rebuild switch";
          noctalia-save-settings = "nix run .\#featureNoctalia ipc call state all > ./modules/features/noctalia.json";
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
      # Useful apps
      google-chrome
      #vmware
      pkgs.open-vm-tools
      wl-clipboard
      wl-clip-persist
      xclip
    ];


    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    hardware.bluetooth.enable = true;
  };
}
