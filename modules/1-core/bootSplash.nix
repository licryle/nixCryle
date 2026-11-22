{ inputs, ... }: {
  # Thin local wrapper around licryle/nixos-modules. The theme package and
  # the generic option-based module both live in that flake.
  flake.nixosModules.bootSplash = { config, lib, ... }: {
    imports = [
      inputs.nixos-modules.nixosModules.nixosMacStylePlymouth
    ];

    # Keep Plymouth off WSL; enable early KMS on real hardware.
    boot.plymouth.nixos-mac-style = {
      enable = lib.mkIf (!((config.wsl or {}).enable or false)) true;
      earlyKms = lib.mkIf (!((config.wsl or {}).enable or false)) true;
    };
  };
}
