{inputs, nixOsVersion, ...}: {
  flake.nixosModules.userLicryle = { pkgs, ... }: {
    users.users.licryle = {
        shell = pkgs.zsh;
        isNormalUser = true;
        description = "Licryle";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };
    home-manager.users.licryle = { pkgs, ... }: {
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
        "Pictures/wallpaper.png".source = ./licryle/Pictures/wallpaper.png;
        "Pictures/profile.jpg".source = ./licryle/Pictures/profile.jpg;
      };
    };
  };
}