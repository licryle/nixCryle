# nixCryle

A comprehensive **NixOS** configuration designed by and for Licryle flake based on `flake-parts`, designed for flexible deployment across multiple hardware platforms including bare-metal, WSL, VMs, and Apple Intel machines.

## 📋 Overview

`nixCryle` is a modular NixOS system configuration that provides:
- **Multi-platform support**: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin
- **Hardware-specific configurations**: Metal (bare-metal), WSL, SD Card, Apple Intel
- **Desktop environments**: Wayland (niri compositor) with GTK theming
- **Container support**: Podman with Docker compatibility
- **Development tools**: Pre-configured VSCode, Git, and developer utilities

## 🏗️ Project Structure

```
nixCryle/
├── flake.nx              # Main flake definition with inputs and outputs
├── flake.lock            # Lock file for reproducible builds
└── modules/
    ├── 0-hardware/       # Hardware-specific configurations
    │   ├── appleIntelHardware.nix   # Apple Intel Mac support
    │   ├── impureHardware.nix       # Standard hardware config imports
    │   ├── metalHardware.nix        # Bare-metal and VM configuration
    │   ├── sdCardHardware.nix       # SD Card/USB boot configuration
    │   └── wslHardware.nix          # WSL (Windows Subsystem for Linux) support
    │
    ├── 1-core/           # Core system configurations
    │   ├── coreConfig.nix      # Core settings, locales, SSH, sudo
    │   ├── nix.nix             # Nix configuration and GC settings
    │   └── podman.nix          # Podman container runtime setup
    │
    ├── 2-TUI/            # Terminal User Interface configurations
    │   └── tuiSystem.nix       # Headless/WSL TUI environment
    │
    ├── 3-GUI/            # Desktop/GUI configurations
    │   ├── desktopConfig.nix   # Full desktop stack (X11, Wayland)
    │   └── niriDesktop.nix     # Niri compositor + sysc-greet login screen
    │
    ├── features/         # Feature modules
    │   └── devTools.nix      # Developer tools and VSCode extensions
    │
    ├── hosts/            # Host machine configurations
    │   └── tourCryle.nix     # Main host configuration (tourCryle)
    │
    └── users/            # User-specific configurations
        └── licryle.nix       # User "licryle" home-manager config
```

## 🚀 Quick Start

### Prerequisites

- Nix installed on your system
- Git (for cloning the repository)

### Host Targets & Installation

#### tourCryle — Portable Linux System (USB / SD Card)
```bash
# Set LUKS passphrase and build
read -s -l -P "Enter LUKS Passphrase: " PASS
echo "$PASS" > /tmp/luks-password.txt
nix build .#tourCryle
sudo ./result --build-memory 2048 --pre-format-files /tmp/luks-password.txt /tmp/luks-password.txt
rm /tmp/luks-password.txt
```

Now just burn using the image balenaEtcher on a USB disk and boot in another computer (non Mx Apple sillicon).

#### winCryle — Windows Subsystem for Linux (WSL)

**Installation in WSL:**
First download the most recent NixOS WSL system from [github/nix-community](https://github.com/nix-community/NixOS-WSL/releases)

Then in Powershell
```Powershell
wsl --install --from-file nixos.wsl
```

Git fetch the flake then:
```bash
# Then apply your nixCryle configuration
sudo nixos-rebuild switch --flake .#winCryle
```

#### proCryle — Apple Mac Pro 2013

Install nixOs, git fetch the flake, then:

**Installation on Intel Mac:**
```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#proCryle --impure
```

#### airCryle — Apple MacBook Air 2012

**Installation on MacBook Air:**
```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#airCryle --impure
```

#### nixCryle — Generic NixOS System

**Installation on Standard NixOS:**
```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#nixCryle --impure
```

## ⚙️ Configuration Modules

### Hardware Modules (`modules/0-hardware/`)

- **metalHardware**: Bare-metal and VM configuration with systemd-boot, NetworkManager, CUPS, Bluetooth
- **wslHardware**: WSL integration using `nixos-wsl` input
- **sdCardHardware**: SD Card/USB boot with LUKS encryption and disko partitioning
- **appleIntelHardware**: Apple Intel Mac support with Broadcom WiFi drivers

### Core Modules (`modules/1-core/`)

- **coreConfig**: System-wide settings including:
  - Auto-upgrades (daily via flake)
  - French locale for address/time formatting
  - Fish shell with custom aliases
  - SSH and sudo configurations
  - Essential utilities (vim, lf, yazi, btop, etc.)

- **nix**: Nix configuration:
  - Automatic garbage collection (weekly)
  - Experimental features enabled
  - Store optimization

- **podman**: Container runtime with Docker compatibility

### Desktop Modules (`modules/3-GUI/`)

- **desktopConfig**: Full desktop environment:
  - X11 server with PipeWire audio
  - GTK theming (Adwaita-dark, Papirus icons)
  - Pre-installed apps (Chrome, VLC, PCManFM)
  - VMware guest tools

- **niriDesktop**: Wayland compositor setup:
  - Niri compositor
  - sysc-greet login screen

### User Configuration (`modules/users/`)

- **licryle.nix**: Home-manager configuration for user "licryle":
  - Kitty terminal with custom settings
  - Wallpaper and profile picture support
  - Git integration

## 🛠️ Development Tools

The `devTools` module includes:
- VSCode with Nix extension
- Git with rebase on pull
- GitHub CLI (`gh`)
- Lazygit, direnv
- Android Studio
- Essential dev utilities (pv, git-filter-repo)

## 🔐 Security Notes

- **LUKS encryption** for USB Card installations
- **SSH hardening**: ServerAliveInterval, TCPKeepAlive
- **Sudo visibility**: Password shown as asterisks (`pwfeedback`)
- **NetworkManager** for network management

## 📝 License

This project is provided as-is. Review and modify configurations to suit your needs.

## 🔗 External Resources

- [NixOS Documentation](https://nixos.org/manual/nixos/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Flake Parts](https://flake.parts/)
- [Disko](https://github.com/nix-community/disko)