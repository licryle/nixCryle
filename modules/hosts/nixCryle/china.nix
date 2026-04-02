{inputs, ...}: {
  flake.nixosModules.china = { pkgs, ... }: {
    programs.clash-verge.enable = true;
  };
}