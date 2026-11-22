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

          # The AMD GPIO controller (AMDI0030:00 at 0xFED81500) latches a
          # wake status on GPIO 4. The kernel's pinctrl_amd wake handler then
          # aborts every S3 attempt ("PM: Triggering wakeup from IRQ 7").
          # Writing EOI_MASK (bit 29) to WAKE_INT_MASTER_REG (base + 0xFC)
          # clears the latched status, as the driver itself does on IRQ EOI.
          clearAmdGpioWake = pkgs.writeCBin "clear-amd-gpio-wake" ''
            #include <fcntl.h>
            #include <stdint.h>
            #include <stdio.h>
            #include <sys/mman.h>
            #include <unistd.h>

            int main(void) {
              const off_t page = 0xFED81000;            /* AMDI0030:00 MMIO page */
              const size_t reg = 0x5FC;                 /* base + 0xFC = WAKE_INT_MASTER_REG */
              const uint32_t eoi = 1U << 29;            /* EOI_MASK */

              int fd = open("/dev/mem", O_RDWR | O_SYNC);
              if (fd < 0) { perror("open /dev/mem"); return 1; }

              volatile uint8_t *map = mmap(NULL, 0x1000, PROT_READ | PROT_WRITE,
                                           MAP_SHARED, fd, page);
              if (map == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

              /* GPIO 4 pin register: base + 4*4 = 0xFED81510 (offset 0x510).
               * Clear the S0I3/S3 wake-enable bits (13/14) so the line cannot
               * re-latch a wake status, and W1C the interrupt/wake status
               * bits (28/29), which are set again during the suspend path. */
              volatile uint32_t *pin4 = (volatile uint32_t *)(map + 0x510);
              uint32_t v = *pin4;
              v &= ~((1U << 13) | (1U << 14));
              v |= (1U << 28) | (1U << 29);
              *pin4 = v;

              /* Preserve other master-register bits, like the driver's EOI path. */
              volatile uint32_t *master = (volatile uint32_t *)(map + reg);
              *master = *master | eoi;

              munmap((void *)map, 0x1000);
              close(fd);
              return 0;
            }
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
            # /dev/mmio helper needs to clear the latched AMD GPIO wake status
            # in an MMIO range already claimed by the pinctrl_amd driver.
            "iomem=relaxed"
          ];

          systemd.services.clear-amd-gpio-wake = {
            description = "Clear stale AMD GPIO wake status before suspend";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${clearAmdGpioWake}/bin/clear-amd-gpio-wake";
            };
            before = [ "systemd-suspend.service" ];
            requiredBy = [ "systemd-suspend.service" ];
          };

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
