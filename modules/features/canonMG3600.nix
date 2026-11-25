{...}: {
  flake.nixosModules.canonMG3600 = { pkgs, user, ... }: {
    # SANE is the scanner side of this multifunction printer.
    hardware.sane.enable = true;

    # Needed for direct access to /dev/bus/usb; seat uaccess also works, but
    # the group is useful for non-seat tools such as saned.
    users.users.${user}.extraGroups = [ "scanner" ];

    # Enable CUPS printing and drivers
    services.printing = {
      enable = true;

      drivers = with pkgs; [
        gutenprint
      ];
    };

    # CLI tool to check ink levels, plus a scanning/PDF frontend.
    environment.systemPackages = with pkgs; [
      ink
      (scantpaper.overridePythonAttrs (old: rec {
        version = "4.0.4";
        src = pkgs.fetchFromGitHub {
          owner = "carygravel";
          repo = "scantpaper";
          tag = "v${version}";
          hash = "sha256-kr5Bwc06+B7PPFd9JLitFVB/vpC5ucjdtYz4gwCcUPY=";
        };

        # Upstream's headless install-check suite aborts under this nixpkgs
        # GTK4/Xvfb/Python combo; the application itself builds fine.
        doInstallCheck = false;

        # 4.x moved to a src/ layout and gained these dependencies.
        dependencies = old.dependencies ++ [
          python3.pkgs.pikepdf
          python3.pkgs.typing-extensions
        ];

        # scantpaper assumes a Debian-like system PATH and calls several CLI
        # tools directly. The nixpkgs wrapper only includes the 3.0.x set, so
        # add the extra programs needed by 4.x at runtime.
        makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
          "--prefix"
          "PATH"
          ":"
          (pkgs.lib.makeBinPath (with pkgs; [
            file
            imagemagick
            jbig2enc
            poppler-utils
            ghostscript
            xdg-utils
          ]))
        ];

        # 4.x is a GTK4 app; the nixpkgs 3.0.x derivation still wraps with GTK3.
        nativeBuildInputs =
          builtins.filter (p:
            toString p != toString pkgs.wrapGAppsHook3
            && ! pkgs.lib.hasInfix "pytest-check-hook" (toString p))
            old.nativeBuildInputs
          ++ [
            pkgs.wrapGAppsHook4
            pkgs.gtk4
          ];
        nativeCheckInputs =
          builtins.filter (p: ! pkgs.lib.hasInfix "pytest-check-hook" (toString p))
            old.nativeCheckInputs
          ++ [
            pkgs.gtk4
            python3.pkgs.polib
          ];

        postInstall = ''
          install -Dm644 \
            src/scantpaper/icons/hicolor/scalable/apps/scantpaper.svg \
            $out/share/icons/hicolor/scalable/apps/scantpaper.svg
          install -Dm444 \
            org.scantpaper.desktop \
            $out/share/applications/org.scantpaper.desktop
          install -Dm444 \
            org.scantpaper.desktop.metainfo.xml \
            $out/share/metainfo/org.scantpaper.metainfo.xml
        '';
      }))
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