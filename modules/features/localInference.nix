{ inputs, ... }: {
  flake.nixosModules.localInference = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      lmstudio
    ];
  };
}