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
      git-filter-repo
      gh
      lazygit
      pv

      android-studio
      antigravity

      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
        ];
      })
    ];

    environment.variables.EDITOR = "code";

    programs.direnv.enable = true;
  };
}
