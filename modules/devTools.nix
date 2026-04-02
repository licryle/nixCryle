{inputs, ...}: {
  flake.nixosModules.devTools = { pkgs, ... }: {
    programs.git = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      vim
      gh

      antigravity
      vscode
    ];
  };
}
