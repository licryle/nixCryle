{inputs, ...}: {
  flake.nixosModules.devTools = { pkgs, ... }: {
    programs.git = {
      enable = true;
      config = {
        pull.rebase = true;
        init.defaultBranch = "main";
      };
    };
    programs.vscode.enable = true;

    environment.systemPackages = with pkgs; [
      vim
      gh

      android-studio
      antigravity
    ];
  };
}
