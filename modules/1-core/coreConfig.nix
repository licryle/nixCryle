{ inputs, ... }: {
  flake.nixosModules.coreConfig = { pkgs, nixOsVersion, keyboardLayout, ... }: {
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
    time.timeZone = "Asia/Shanghai";

    console.keyMap = keyboardLayout;

    programs.fish = {
      enable = true;

      shellAliases = {
        noctalia-save-settings = "nix run .\\#noctalia ipc call state all > ./modules/features/noctalia.json";
        please = "sudo $(fc -ln -1)";
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
      yazi
      btop
    ];

    programs.ssh.extraConfig = ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 3
        TCPKeepAlive yes
    '';

    security.sudo.extraConfig = # sh
    ''
      Defaults pwfeedback # Make typed password visible as asterisks
    '';
  };
}
