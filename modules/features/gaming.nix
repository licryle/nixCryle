{ pkgs, user, ... }: {
  flake.nixosModules.gaming = { pkgs, ... }:
    let
      ds4XboxBridge = pkgs.writers.writePython3Bin "ds4-xbox-bridge" {
        libraries = [ pkgs.python3Packages.evdev ];
      } ''
        import sys
        import evdev
        from evdev import UInput, AbsInfo, ecodes as e

        if len(sys.argv) < 2:
            sys.exit(1)

        dev_path = sys.argv[1]
        src = evdev.InputDevice(dev_path)
        src.grab()

        cap = {
            e.EV_KEY: [
                e.BTN_A, e.BTN_B, e.BTN_X, e.BTN_Y, e.BTN_TL, e.BTN_TR,
                e.BTN_SELECT, e.BTN_START, e.BTN_MODE, e.BTN_THUMBL, e.BTN_THUMBR,
            ],
            e.EV_ABS: [
                (e.ABS_X, AbsInfo(0, -32768, 32767, 16, 128, 0)),
                (e.ABS_Y, AbsInfo(0, -32768, 32767, 16, 128, 0)),
                (e.ABS_RX, AbsInfo(0, -32768, 32767, 16, 128, 0)),
                (e.ABS_RY, AbsInfo(0, -32768, 32767, 16, 128, 0)),
                (e.ABS_Z, AbsInfo(0, 0, 255, 0, 0, 0)),
                (e.ABS_RZ, AbsInfo(0, 0, 255, 0, 0, 0)),
                (e.ABS_HAT0X, AbsInfo(0, -1, 1, 0, 0, 0)),
                (e.ABS_HAT0Y, AbsInfo(0, -1, 1, 0, 0, 0)),
            ],
        }

        key_map = {
            e.BTN_SOUTH: e.BTN_A,
            e.BTN_EAST: e.BTN_B,
            e.BTN_WEST: e.BTN_X,
            e.BTN_NORTH: e.BTN_Y,
            e.BTN_TL: e.BTN_TL,
            e.BTN_TR: e.BTN_TR,
            e.BTN_SELECT: e.BTN_SELECT,
            e.BTN_START: e.BTN_START,
            e.BTN_MODE: e.BTN_MODE,
            e.BTN_THUMBL: e.BTN_THUMBL,
            e.BTN_THUMBR: e.BTN_THUMBR,
        }

        ui = UInput(
            cap,
            name="Microsoft X-Box 360 pad",
            vendor=0x045E,
            product=0x028E,
            version=0x0110,
        )

        try:
            for ev in src.read_loop():
                if ev.type == e.EV_KEY and ev.code in key_map:
                    ui.write(e.EV_KEY, key_map[ev.code], ev.value)
                    ui.syn()
                elif ev.type == e.EV_ABS:
                    if ev.code in (e.ABS_X, e.ABS_Y, e.ABS_RX, e.ABS_RY):
                        val = max(-32768, min(32767, (ev.value - 128) * 256))
                    else:
                        val = ev.value
                    ui.write(e.EV_ABS, ev.code, val)
                    ui.syn()
        except OSError:
            pass
        finally:
            ui.close()
      '';
    in
    {
      programs.steam = {
        enable = true;
        extest.enable = true;
        # Steam is the "on demand" dGPU case: every game/Proton process it
        # spawns inherits these, while the desktop itself stays on the iGPU.
        # GLX covers XWayland games, Vulkan covers native/proton VK games.
        package = pkgs.steam.override {
          extraEnv = {
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            __VK_LAYER_NV_optimus = "NVIDIA_only";
            GBM_BACKEND = "nvidia-drm";
          };
        };
      };

      programs.gamemode.enable = true;
      programs.gamescope.enable = true;

      environment.systemPackages = with pkgs; [
        mangohud
        heroic
      ];

      hardware.uinput.enable = true;
      hardware.steam-hardware.enable = true;

      systemd.services."ds4-xbox@" = {
        description = "DualShock 4 to Xbox 360 Controller Bridge (%I)";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${ds4XboxBridge}/bin/ds4-xbox-bridge /dev/input/%I";
          Restart = "no";
        };
      };

      services.udev.extraRules = ''
        # Ensure uinput is accessible
        KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", TAG+="uaccess", OPTIONS+="static_node=uinput"

        # Prevent PS4/PS5 motion sensors from grabbing js0 ahead of actual gamepads
        SUBSYSTEM=="input", ATTRS{name}=="*Motion Sensors", ENV{ID_INPUT_JOYSTICK}=""

        # Automatically start/stop Xbox 360 bridge whenever a DualShock 4 connects/disconnects
        ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Wireless Controller", TAG+="systemd", ENV{SYSTEMD_WANTS}="ds4-xbox@%k.service"
        ACTION=="remove", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Wireless Controller", RUN+="${pkgs.systemd}/bin/systemctl stop ds4-xbox@%k.service"
      '';

      users.users.${user}.extraGroups = [ "input" "uinput" ];
    };
}
