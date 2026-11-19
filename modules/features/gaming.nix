{ ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];

    boot.kernel.sysctl = { /* Because of steam */
      "net.ipv6.conf.wlo1.disable_ipv6" = 1;
    };
  };
}