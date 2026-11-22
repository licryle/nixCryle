{ inputs, self, user, nixOsVersion, keyboardLayout, ... }: {
  # sudo nixos-rebuild switch --flake .#gameCryle --impure
  # or better
  # nix flake update && sudo nixos-rebuild switch --flake .#gameCryle --impure
  flake.nixosConfigurations.gameCryle = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.impureHardware
      self.nixosModules.metalHardware
      
      ({ config, pkgs, ... }:
        let
          # niri is Wayland, so the stock `nvidia-offload` script (X11/GLX vars
          # only) is not enough. This one covers GBM for native Wayland apps,
          # GLX for XWayland, and Vulkan for games/inference.
          nvidiaOffload = pkgs.writeShellScriptBin "nvidia-offload" ''
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __VK_LAYER_NV_optimus=NVIDIA_only
            export GBM_BACKEND=nvidia-drm
            export LIBVA_DRIVER_NAME=nvidia
            exec "$@"
          '';

          # Force the iGPU back on for a single app (handy for mixed sessions).
          amdOffload = pkgs.writeShellScriptBin "amd-offload" ''
            unset __NV_PRIME_RENDER_OFFLOAD __NV_PRIME_RENDER_OFFLOAD_PROVIDER
            unset __GLX_VENDOR_LIBRARY_NAME __VK_LAYER_NV_optimus
            unset GBM_BACKEND LIBVA_DRIVER_NAME
            export DRI_PRIME=0
            exec "$@"
          '';
        in {
          boot.extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];
          boot.kernelModules = [ "legion_laptop" ];

          users.users.${user}.extraGroups = [ "kvm" ];

          # The RTL9201 USB-SATA bridge holding / and swap loses all I/O after
          # S4 resume when driven by `uas`. Force the battle-tested usb-storage
          # driver instead (slower, but survives suspend/hibernate).
          boot.kernelParams = [
            "usb_storage.quirks=0bda:9201:u"
          ];

          # Hybrid graphics: the Radeon 610M (iGPU) drives the desktop and the
          # RTX 4060 (dGPU) stays off until something is launched through
          # `nvidia-offload`. Requires BIOS -> Advanced -> Graphics Mode =
          # "Hybrid"/"Switchable Graphics"; in discrete mode the iGPU is hidden
          # as dummy PCI function 1022:14de at 05:00.0 instead of 1002:164e.
          #
          # Bus IDs: NVIDIA 01:00.0 -> PCI:1:0:0, AMD 05:00.0 -> PCI:5:0:0
          # Verify with: lspci -nn | grep -Ei 'vga|3d|display'
          services.xserver.videoDrivers = [ "nvidia" ];

          hardware.graphics.enable = true;

          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement = {
              enable = true;
              # Let the dGPU actually power down while idle on battery.
              finegrained = true;
              # The 595 kernel suspend notifier throws "Error in service of
              # callback" on S4 entry; use the nvidia-sleep.sh services instead.
              kernelSuspendNotifier = false;
            };
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;

            prime = {
              nvidiaBusId = "PCI:1:0:0";
              amdgpuBusId = "PCI:5:0:0";
              offload = {
                enable = true;
                # We install our own Wayland-capable wrapper under this name.
                enableOffloadCmd = false;
              };
            };
          };

          environment.systemPackages = [ nvidiaOffload amdOffload pkgs.lenovo-legion ];
        })

      self.nixosModules.tuiSystem
      self.nixosModules.gaming
      self.nixosModules.localInference

      self.nixosModules.niriNoctaliaDesktop
      {
        networking.hostName = "gameCryle";
      }
    ];

    specialArgs = {
      inherit inputs self user nixOsVersion keyboardLayout;
    };
  };
}
