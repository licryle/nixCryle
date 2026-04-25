{inputs, keyboardLayout, ...}: {
  flake.nixosModules.china = { pkgs, ... }: {
    programs.clash-verge = {
      enable = true;
      tunMode = true;
      serviceMode = true;
    };

    ## ClashVerge https://github.com/NixOS/nixpkgs/issues/477636
    networking.firewall = {
      trustedInterfaces = [ "utun" ];
      extraReversePathFilterRules = ''iifname { "utun" } accept comment "trusted interface"'';
    };
    networking.nftables.enable = true;

    i18n.inputMethod = {
      # Available since NixOS 24.11
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        ignoreUserConfig = true;    # Use settings below, ignore user config
        addons = with pkgs; [
          qt6Packages.fcitx5-chinese-addons
        ];
        settings = {
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = keyboardLayout;
              DefaultIM = "keyboard-${keyboardLayout}";
            };  
            "Groups/0/Items/0".Name = "keyboard-${keyboardLayout}";
            "Groups/0/Items/1".Name = "pinyin";
          };
        };
      };
    };
  };
}