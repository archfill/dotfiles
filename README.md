# 🏠 Dotfiles Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://github.com)
[![日本語](https://img.shields.io/badge/lang-ja-blue)](README.ja.md)

Cross-platform dotfiles for modern development environments with Japanese language support.

## ✨ Features

- **Multi-Platform**: macOS, Linux, Windows
- **Modern Tools**: Neovim, WezTerm, Zsh with optimized configurations
- **Japanese Support**: SKK input method, textlint for technical writing
- **Development Ready**: Python (uv), Node.js (mise), Flutter, Docker support

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Configure personal settings interactively
make config

# Complete setup
make init
```

### 2. Essential Commands

```bash
make init     # Complete installation
make diff     # Preview Nix changes
make status   # Check status
make help     # Show all commands
```

On Linux, `make init` now prefers Nix/Home Manager for the user environment. Minimal OS bootstrap packages are opt-in:

```bash
make init NIX_ATTR='archfill@arch-desktop'
make init NIX_ATTR='archfill@ubuntu-desktop'
make init NIX_ATTR='archfill@wsl-ubuntu'

# Bootstrap curl/git/zsh before installing Nix, only when explicitly needed
make init DOTFILES_INSTALL_MODE=legacy
```

## 📁 Key Configurations

- **Neovim**: `.config/nvim/` - 50+ plugins with LSP support
- **Zsh**: `.config/zsh/` - Optimized shell with completions
- **Terminal**: `.config/wezterm/` - Modern terminal configuration
- **Git**: Global git settings and lazygit integration

## 🌍 Platform Support

| Platform | Package Manager | Window Manager      | Special Features          |
| -------- | --------------- | ------------------- | ------------------------- |
| macOS    | Homebrew        | AeroSpace/SketchyBar | Unified setup             |
| Linux    | apt/pacman/dnf  | Hyprland            | Systemd services, Wayland |
| Windows  | Scoop/WSL       | Native              | WSL2 config management    |

### Windows WSL Configuration

For Windows users, this repository includes WSL2 configuration management:

```bash
# Setup Windows dotfiles (requires Administrator privileges)
make windows-setup

# Check Windows dotfiles status
make windows-status
```

The `windows/.wslconfig` file is automatically symlinked to manage WSL2 performance settings.

### Hyprland Setup (NixOS / Arch Linux)

Hyprland is a modern Wayland compositor with GPU-accelerated animations and extensive customization.

#### Installation

```bash
# NixOS: apply the declared Hyprland desktop
make rebuild

# Check installation status
make hyprland-status
```

#### What Gets Installed

**Core Hyprland Packages:**

- `hyprland` - Main compositor
- `hyprcursor` - Cursor management
- `hypridle` - Idle daemon
- `hyprpicker` - Color picker
- `hyprshot` - Screenshot utility
- `hyprpolkitagent` - Polkit authentication agent
- `xdg-desktop-portal-hyprland` - Desktop portal integration

**Shell and Wayland Tools:**

- `caelestia-shell` - Bar, launcher, sidebar, session menu, wallpaper selector, notifications
- `rofi` - Fallback menus for clipboard history and keybind cheatsheet
- `wl-clipboard` - Clipboard utilities
- `cliphist` - Clipboard history
- `matugen` - Color generation synced from the current Caelestia scheme

**Screenshot Tools (1):**

- `satty` - Screenshot editor/annotation

**Optional Packages:**

- `pavucontrol` - Audio control GUI
- `brightnessctl` - Brightness control
- `playerctl` - Media player control (MPRIS)
- `network-manager-applet` - Network management GUI
- `overskride` - Bluetooth manager

**NVIDIA-Specific Packages (2, if NVIDIA GPU detected):**

- `egl-wayland` - Wayland EGL support for NVIDIA
- `libva-nvidia-driver` - Hardware acceleration for NVIDIA

#### GPU-Specific Configuration

NixOS declares shared GPU settings in the Nix modules. Host-specific differences should live in `nix/hosts/<host>/`; monitor layout is still kept in `~/.config/hypr/monitors.conf`.

**NVIDIA GPU (RTX 4070, etc.):**

- Configures NVIDIA/VA-API environment variables for Hyprland
- Includes VA-API hardware acceleration support
- Enables Wayland support for Electron/Chromium apps on NixOS via `NIXOS_OZONE_WL=1`

**Intel/AMD GPU:**

- No additional configuration needed

**Multi-PC Setup:**

- Host-specific Nix settings live under `nix/hosts/<host>/`
- Same dotfiles work across different GPU configurations
- No git diff conflicts when using different hardware

#### Post-Installation Steps

**For All Users:**

1. Review configuration: `~/.config/hypr/hyprland.conf`
2. Adjust keybindings if needed (default: Super/Windows key)
3. Configure monitor layout if using multiple displays

**For NVIDIA Users (REQUIRED):**

On NixOS, NVIDIA DRM modeset, fbdev, early modules, and Hyprland environment variables are declared in the Nix configuration. On Arch Linux, after installation, the script displays a setup guide. Key steps:

1. **Kernel Parameters** (REQUIRED):

   ```bash
   sudo vim /etc/default/grub
   # Add to GRUB_CMDLINE_LINUX_DEFAULT:
   # nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1

   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo reboot
   ```

2. **Modprobe Configuration** (RECOMMENDED):

   ```bash
   sudo tee /etc/modprobe.d/nvidia.conf <<EOF
   options nvidia_drm modeset=1
   options nvidia NVreg_PreserveVideoMemoryAllocations=1
   EOF
   ```

3. **Early KMS** (RECOMMENDED):

   ```bash
   sudo vim /etc/mkinitcpio.conf
   # Add: MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

   sudo mkinitcpio -P
   ```

4. **Suspend/Resume Support** (OPTIONAL):
   ```bash
   sudo systemctl enable nvidia-suspend.service
   sudo systemctl enable nvidia-hibernate.service
   sudo systemctl enable nvidia-resume.service
   ```

For detailed NVIDIA setup instructions, see: https://wiki.hyprland.org/Nvidia/

#### Starting Hyprland

**From TTY:**

```bash
Hyprland
```

**With Display Manager:**

- GDM, SDDM, or LightDM will automatically detect Hyprland
- Select "Hyprland" from the session menu

#### Configuration Files

Configuration files are symlinked by Nix/Home Manager:

- `~/.config/hypr/hyprland.conf` - Main configuration
- `~/.config/hypr/hypridle.conf` - Idle management (screen dim, DPMS, suspend; lock UI is Caelestia)
- `~/.config/caelestia/shell.json` - Caelestia Shell settings
- `~/.config/rofi/` - Fallback clipboard/keybind menus
- `~/.config/matugen/` - Color generation templates

#### Desktop Responsibilities

- `caelestia-shell` owns the bar, launcher, sidebar, session menu, wallpaper selector, notifications, and lock UI.
- `hypridle` owns idle timers, brightness dim/restore, DPMS, suspend, and resume hooks.
- `rofi` remains the picker UI for clipboard history and the keybind cheatsheet.
- `matugen` syncs the current Caelestia scheme into Hyprland, rofi, and terminal color files.

#### NixOS Hyprland Coverage

Hyprland and the desktop stack are declared through Nix modules:

| Purpose | NixOS declaration |
| ------- | ----------------- |
| Hyprland, XWayland, portal | `programs.hyprland` and `xdg.portal` in `nix/modules/desktop/hyprland.nix` |
| Hyprland tools | `hyprcursor`, `hypridle`, `hyprpicker`, `hyprshot`, `hyprpolkitagent` in `nix/modules/desktop/hyprland.nix` |
| Clipboard and picker UI | `rofi`, `wl-clipboard`, `cliphist` in `nix/modules/desktop/hyprland.nix` |
| Screenshots and colors | `satty`, `matugen`, `gettext` in `nix/modules/desktop/hyprland.nix` |
| Desktop utilities | `pavucontrol`, `brightnessctl`, `playerctl`, `networkmanagerapplet`, `nwg-look`, `overskride` in `nix/modules/desktop/hyprland.nix` |
| NVIDIA Wayland support | `egl-wayland`, `nvidia-vaapi-driver` in `nix/modules/desktop/hyprland.nix`; driver/kernel details in `nix/hosts/<host>/configuration.nix` |
| Network and audio services | `networking.networkmanager` and `services.pipewire` in `nix/modules/nixos-common.nix` |
| Japanese input method | `i18n.inputMethod.fcitx5` in `nix/modules/nixos-common.nix` |
| GNOME integration | `services.desktopManager.gnome`, GDM, Nautilus, and GNOME keyring from `nix/modules/nixos-common.nix` |
| Caelestia Shell | Home Manager module in `nix/hosts/archfill-nixos/home.nix` |

#### Default Keybindings

| Key                       | Action                                  |
| ------------------------- | --------------------------------------- |
| `Super + Return`          | Open terminal (ghostty)                 |
| `Super + D`               | Toggle Caelestia launcher               |
| `Super + W`               | Toggle Caelestia launcher               |
| `Super + Shift + W`       | Open Caelestia wallpaper selector       |
| `Super + N`               | Toggle Caelestia sidebar                |
| `Super + M`               | Toggle Caelestia session menu           |
| `Super + V`               | Clipboard history via rofi/cliphist     |
| `Super + /`               | Keybind cheatsheet via rofi             |
| `Alt + Tab`               | Cycle windows via Hyprland              |
| `Alt + Shift + Tab`       | Cycle windows backward via Hyprland     |
| `Super + Q`               | Kill active window                      |
| `Super + Space`           | Toggle floating                         |
| `Super + F`               | Fullscreen                              |
| `Super + S`               | Enter workspace submap                  |
| `Super + h/j/k/l`         | Move focus (vim-like)                   |
| `Super + Shift + h/j/k/l` | Move active window                      |
| `Print`                   | Screenshot region                       |
| `Shift + Print`           | Screenshot window                       |
| `Ctrl + Print`            | Screenshot with annotation              |

#### Troubleshooting

**Black screen after launch:**

- Check journal: `journalctl -b | grep hyprland`
- Verify NVIDIA kernel parameter: `cat /sys/module/nvidia_drm/parameters/modeset` (should show `Y`)

**Electron apps not using Wayland:**

- On NixOS, `NIXOS_OZONE_WL=1` is configured in the Hyprland Nix module

**Screen tearing:**

- Check the NVIDIA driver and Hyprland logs first: `journalctl -b -k | grep -i nvidia`

**Monitor not detected:**

- List monitors: `hyprctl monitors`
- Edit `~/.config/hypr/hyprland.conf` monitor section

For more help:

- Hyprland Wiki: https://wiki.hyprland.org
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr

## 🇯🇵 Japanese Features

- **Japanese Input**: SKK-oriented editor/input configuration
- **Text Linting**: textlint for technical Japanese writing
- **Media Styles**: WEB+DB PRESS, TechBooster style guides

## 🛠️ Development Tools

### Programming Languages

- **Python**: Nix-provided Python with uv / pipx for package workflows
- **Node.js**: Nix-provided Node.js with mise for project overrides
- **Rust**: Nix-provided cargo / rustc / clippy / rustfmt
- **Go**: Nix-provided Go with project-level overrides when needed
- **Java**: Nix-provided OpenJDK with project-level overrides when needed

### Development Environment

- **Editor**: Neovim with LSP, completion, and debugging
- **Terminal**: WezTerm with custom themes and SSH integration
- **Git**: Advanced configurations with lazygit interface
- **Containers**: Docker and Docker Compose setup
- **Mobile**: Flutter with FVM version management

## 📄 License

[MIT License](LICENSE) - Feel free to use and modify for your own dotfiles setup.
