{inputs, ...}: {
  flake.nixosModules.appleIntelHardware = { pkgs, lib, ... }: {
    nixpkgs.config = {
      allowUnfree = true;
      allowInsecurePredicate = pkg: lib.elem (lib.getName pkg) [
        "broadcom-sta"
      ];
    };

    boot = {
      kernelModules = [ "wl" ];
      extraModulePackages = [ pkgs.linuxPackages.broadcom_sta ];
    };
    boot.blacklistedKernelModules = [ "b43" "bcma" ];

    services.xserver.videoDrivers = [ "intel" ];
    hardware.graphics.enable = true;
  };
}