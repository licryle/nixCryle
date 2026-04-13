{inputs, ...}: {
  flake.nixosModules.baseConfig = { pkgs, nixOsVersion, keyboardLayout, ... }: {
    networking.networkmanager.enable = true;
    nixpkgs.config.allowUnfree = true;

    virtualisation.vmware.guest.enable = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = nixOsVersion;

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
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    programs.fish = {
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
      fzf
      fishPlugins.fzf-fish
      # Useful apps
      google-chrome
      vlc
      #vmware
      pkgs.open-vm-tools
      wl-clipboard
      wl-clip-persist
      xclip
    ];


    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    programs.ssh.extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
        TCPKeepAlive yes
    '';

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    hardware.bluetooth.enable = true;


    services.sysc-greet = {
      enable = true;
      compositor = "niri";
    };
  };
}
