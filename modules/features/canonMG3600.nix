{...}: {
  flake.nixosModules.canonMG3600 = { pkgs, ... }: {
    # Enable CUPS printing and drivers
    services.printing = {
      enable = true;

      drivers = with pkgs; [
        gutenprint
      ];
    };

    # CLI tool to check ink levels
    environment.systemPackages = with pkgs; [
        ink
    ];

    systemd.services.configure-canon-mg3600 = {
      description = "Configure Canon PIXMA MG3600 CUPS printer";
      after = [ "cups.service" ];
      requires = [ "cups.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };

      script = ''
        ${pkgs.cups}/bin/lpadmin \
          -p Canon_MG3600 \
          -E \
          -v 'usb://Canon/MG3600%20series?serial=G0GJ5Y&interface=1' \
          -m 'gutenprint.5.3://bjc-MG3600-series/expert'

        ${pkgs.cups}/bin/lpadmin -d Canon_MG3600
      '';
    };

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="04a9", ATTR{idProduct}=="178a", TAG+="systemd", ENV{SYSTEMD_WANTS}+="configure-canon-mg3600.service"
    '';
  };
}