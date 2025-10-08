# 🏠 Dotfiles Repository

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows%20%7C%20Android-blue)](https://github.com)
[![日本語](https://img.shields.io/badge/lang-ja-blue)](README.ja.md)

Cross-platform dotfiles for modern development environments with Japanese language support.

## ✨ Features

- **Multi-Platform**: macOS, Linux, Windows (Cygwin), Android (Termux)
- **Modern Tools**: Neovim, WezTerm, Zsh with optimized configurations
- **Japanese Support**: SKK input method, textlint for technical writing
- **Development Ready**: Python (uv), Node.js (volta), Flutter, Docker support

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Configure personal settings
cp config/personal.conf.template config/personal.conf
$EDITOR config/personal.conf  # Set USER_NAME and USER_EMAIL

# Complete setup
make init
```

### 2. Essential Commands

```bash
make init     # Complete installation
make test     # Verify setup
make status   # Check status
make help     # Show all commands
```

## 📁 Key Configurations

- **Neovim**: `.config/nvim/` - 50+ plugins with LSP support
- **Zsh**: `.config/zsh/` - Optimized shell with completions
- **Terminal**: `.config/wezterm/` - Modern terminal configuration
- **Git**: Global git settings and lazygit integration

## 🌍 Platform Support

| Platform | Package Manager | Window Manager | Special Features |
|----------|----------------|----------------|------------------|
| macOS    | Homebrew       | yabai/skhd     | Unified setup    |
| Linux    | apt/pacman/dnf | i3/polybar/Hyprland | Systemd services, Wayland |
| Windows  | Scoop/WSL      | Native         | WSL2 config management |
| Android  | Termux         | Native         | Mobile optimization |

### Windows WSL Configuration

For Windows users, this repository includes WSL2 configuration management:

```bash
# Setup Windows dotfiles (requires Administrator privileges)
make windows-setup

# Check Windows dotfiles status
make windows-status
```

The `windows/.wslconfig` file is automatically symlinked to manage WSL2 performance settings.

### Hyprland Setup (Arch Linux)

Hyprland is a modern Wayland compositor with GPU-accelerated animations and extensive customization.

#### Installation

```bash
# Install Hyprland and ecosystem
make hyprland-install

# Check installation status
make hyprland-status
```

#### What Gets Installed

**Core Hyprland Packages (8):**
- `hyprland` - Main compositor
- `hyprcursor` - Cursor management
- `hypridle` - Idle daemon
- `hyprlock` - Screen locker
- `hyprpaper` - Wallpaper manager
- `hyprpicker` - Color picker
- `hyprshot` - Screenshot utility
- `xdg-desktop-portal-hyprland` - Desktop portal integration

**Essential Wayland Tools (4):**
- `waybar` - Status bar with customizable modules
- `fuzzel` - Fast application launcher
- `swaync` - Notification daemon with notification center
- `wl-clipboard` - Clipboard utilities

**Screenshot Tools (1):**
- `satty` - Screenshot editor/annotation

**Optional Packages (4):**
- `pavucontrol` - Audio control GUI
- `brightnessctl` - Brightness control
- `playerctl` - Media player control (MPRIS)
- `network-manager-applet` - Network management GUI

**NVIDIA-Specific Packages (2, if NVIDIA GPU detected):**
- `egl-wayland` - Wayland EGL support for NVIDIA
- `libva-nvidia-driver` - Hardware acceleration for NVIDIA

#### GPU-Specific Configuration

The installation script automatically detects your GPU and creates `~/.config/hypr/local.conf`:

**NVIDIA GPU (RTX 4070, etc.):**
- Automatically configures 7 environment variables for optimal performance
- Includes VA-API hardware acceleration support
- Enables Electron/Chromium Wayland support (VSCode, Discord, etc.)
- Configures VRR/G-Sync control

**Intel/AMD GPU:**
- Creates empty `local.conf` using default Wayland settings
- No additional configuration needed

**Multi-PC Setup:**
- `local.conf` is git-ignored (environment-specific)
- Same dotfiles work across different GPU configurations
- No git diff conflicts when using different hardware

#### Post-Installation Steps

**For All Users:**
1. Review configuration: `~/.config/hypr/hyprland.conf`
2. Adjust keybindings if needed (default: Super/Windows key)
3. Configure monitor layout if using multiple displays

**For NVIDIA Users (REQUIRED):**

After installation, the script displays a comprehensive setup guide. Key steps:

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

All configuration files are symlinked via `make links`:

- `~/.config/hypr/hyprland.conf` - Main configuration
- `~/.config/hypr/hyprpaper.conf` - Wallpaper settings
- `~/.config/hypr/hypridle.conf` - Idle management (screen dim, lock, suspend)
- `~/.config/hypr/hyprlock.conf` - Lock screen appearance
- `~/.config/waybar/` - Status bar configuration
- `~/.config/fuzzel/fuzzel.ini` - Application launcher
- `~/.config/swaync/` - Notification center
- `~/.config/hypr/local.conf` - Auto-generated, GPU-specific (git-ignored)

#### Default Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal (ghostty) |
| `Super + D` | Application launcher (fuzzel) |
| `Super + Q` | Kill active window |
| `Super + M` | Exit Hyprland |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + h/j/k/l` | Move focus (vim-like) |
| `Super + N` | Toggle notification center |
| `Print` | Screenshot region |
| `Shift + Print` | Screenshot window |
| `Ctrl + Print` | Screenshot with annotation |

#### Troubleshooting

**Black screen after launch:**
- Check journal: `journalctl -b | grep hyprland`
- Verify NVIDIA kernel parameter: `cat /sys/module/nvidia_drm/parameters/modeset` (should show `Y`)

**Cursor invisible (NVIDIA):**
- Already configured via `WLR_NO_HARDWARE_CURSORS=1` in `local.conf`

**Electron apps not using Wayland:**
- Already configured via `ELECTRON_OZONE_PLATFORM_HINT=auto` in `local.conf`

**Screen tearing:**
- Check VRR setting in `local.conf`: `__GL_VRR_ALLOWED=0`
- Try `__GL_VRR_ALLOWED=1` if you have G-Sync/FreeSync monitor

**Monitor not detected:**
- List monitors: `hyprctl monitors`
- Edit `~/.config/hypr/hyprland.conf` monitor section

For more help:
- Hyprland Wiki: https://wiki.hyprland.org
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr

## 🇯🇵 Japanese Features

- **SKK Input**: yaskkserv2 server with comprehensive dictionaries
- **Text Linting**: textlint for technical Japanese writing
- **Media Styles**: WEB+DB PRESS, TechBooster style guides

## 🛠️ Development Tools

### Programming Languages
- **Python**: uv package manager (modern pyenv replacement)
- **Node.js**: volta toolchain manager (replaces nvm/fnm)
- **Rust**: rustup with essential tools (clippy, rustfmt)
- **Go**: g version manager with development tools
- **Java**: SDKMAN! for JDK management

### Development Environment
- **Editor**: Neovim with LSP, completion, and debugging
- **Terminal**: WezTerm with custom themes and SSH integration
- **Git**: Advanced configurations with lazygit interface
- **Containers**: Docker and Docker Compose setup
- **Mobile**: Flutter with FVM version management

## 📄 License

[MIT License](LICENSE) - Feel free to use and modify for your own dotfiles setup.