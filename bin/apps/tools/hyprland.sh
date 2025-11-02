#!/usr/bin/env bash

# Hyprland and ecosystem installation script
# Installs Hyprland compositor and related Wayland tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"
source "$DOTFILES_DIR/bin/lib/symlink_manager.sh"

setup_error_handling

# Check NVIDIA GPU
check_nvidia_gpu() {
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        return 0  # NVIDIA GPU detected
    else
        return 1  # No NVIDIA GPU
    fi
}

# Check NVIDIA kernel parameter
check_nvidia_kernel_param() {
    local modeset_value

    if [[ -f /sys/module/nvidia_drm/parameters/modeset ]]; then
        modeset_value=$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null)

        if [[ "$modeset_value" == "Y" ]]; then
            return 0  # Properly configured
        else
            return 1  # Not configured
        fi
    else
        return 2  # NVIDIA driver not loaded
    fi
}

# Show NVIDIA setup instructions
show_nvidia_setup() {
    log_warning "NVIDIA GPU detected - Additional setup required!"
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "  NVIDIA + Hyprland Setup Guide"
    log_info "═══════════════════════════════════════════════════════════"
    log_info ""

    # Check kernel parameter
    check_nvidia_kernel_param
    local kernel_status=$?

    log_info "1. Kernel Parameters (REQUIRED)"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $kernel_status -eq 0 ]]; then
        log_success "✓ nvidia-drm.modeset=1 is configured"
    else
        log_warning "✗ nvidia-drm.modeset=1 is NOT configured"
    fi
    log_info ""
    log_info "Add both parameters to GRUB_CMDLINE_LINUX_DEFAULT:"
    log_info "  nvidia-drm.modeset=1"
    log_info "  nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    log_info ""
    log_info "Example:"
    log_info "  GRUB_CMDLINE_LINUX_DEFAULT=\"quiet nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1\""
    log_info ""
    log_info "Commands:"
    log_info "  sudo vim /etc/default/grub"
    log_info "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
    log_info "  sudo reboot"
    log_info ""

    log_info "2. Modprobe Configuration (RECOMMENDED)"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Create /etc/modprobe.d/nvidia.conf with:"
    log_info "  options nvidia_drm modeset=1"
    log_info "  options nvidia NVreg_PreserveVideoMemoryAllocations=1"
    log_info ""
    log_info "Commands:"
    log_info "  sudo tee /etc/modprobe.d/nvidia.conf <<EOF"
    log_info "options nvidia_drm modeset=1"
    log_info "options nvidia NVreg_PreserveVideoMemoryAllocations=1"
    log_info "EOF"
    log_info ""

    log_info "3. Early KMS (RECOMMENDED)"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Add NVIDIA modules to /etc/mkinitcpio.conf:"
    log_info "  MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
    log_info ""
    log_info "Commands:"
    log_info "  sudo vim /etc/mkinitcpio.conf"
    log_info "  sudo mkinitcpio -P"
    log_info ""

    log_info "4. Suspend/Resume Support (OPTIONAL)"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Enable systemd services:"
    log_info "  sudo systemctl enable nvidia-suspend.service"
    log_info "  sudo systemctl enable nvidia-hibernate.service"
    log_info "  sudo systemctl enable nvidia-resume.service"
    log_info ""

    log_info "5. Environment Variables"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "✓ Already configured in ~/.config/hypr/local.conf"
    log_info ""

    log_info "═══════════════════════════════════════════════════════════"
    log_info "Documentation: https://wiki.hypr.land/Nvidia/"
    log_info "═══════════════════════════════════════════════════════════"
    log_info ""
}

install_hyprland() {
    log_info "Installing Hyprland and ecosystem..."

    # Parse command line options
    parse_install_options "$@"

    # WSL check - Hyprland is not supported in WSL
    if is_wsl; then
        log_warning "Hyprland installation is skipped on WSL"
        log_info "Hyprland requires native Linux graphics stack (Wayland)"
        log_info "WSL does not support Wayland compositors like Hyprland"
        return 0
    fi

    # Platform check
    local distro
    distro="$(get_os_distribution)"

    if [[ "$distro" != "arch" ]]; then
        log_warning "Hyprland installation is only supported on Arch Linux"
        log_info "For other distributions, please refer to:"
        log_info "  https://wiki.hyprland.org/Getting-Started/Installation/"
        return 0
    fi

    # Check if Hyprland is already installed
    if [[ "$FORCE_INSTALL" != "true" ]] && command -v Hyprland >/dev/null 2>&1; then
        log_skip_reason "hyprland" "Already installed: $(Hyprland --version 2>/dev/null | head -1 || echo 'version unknown')"
        return 0
    fi

    # Quick check mode
    if [[ "$QUICK_CHECK" == "true" ]]; then
        log_info "QUICK: Would install Hyprland and ecosystem"
        return 0
    fi

    # Detect NVIDIA GPU
    local has_nvidia=false
    if check_nvidia_gpu; then
        has_nvidia=true
        log_info "NVIDIA GPU detected - Will install additional packages"
    fi

    # Hyprland core packages (9 packages - all from official repos)
    local hypr_packages=(
        hyprland                        # Main compositor
        hyprcursor                      # Cursor management
        hypridle                        # Idle daemon
        hyprlock                        # Screen locker
        hyprpaper                       # Wallpaper manager
        hyprpicker                      # Color picker
        hyprshot                        # Screenshot utility
        hyprpolkitagent                 # Polkit authentication agent
        xdg-desktop-portal-hyprland     # Desktop portal integration
    )

    # Essential Wayland tools (4 packages)
    local wayland_tools=(
        waybar          # Status bar
        fuzzel          # Application launcher (fast, modern)
        swaync          # Notification daemon with notification center
        wl-clipboard    # Clipboard utilities
    )

    # Screenshot tools (1 package)
    local screenshot_tools=(
        satty           # Screenshot editor/annotation
    )

    # Optional but recommended packages (10 packages)
    local optional_packages=(
        pavucontrol     # Audio control GUI
        brightnessctl   # Brightness control
        playerctl       # Media player control (MPRIS)
        networkmanager  # Network management daemon (provides nmtui)
        network-manager-applet  # Network management GUI (provides nm-connection-editor)
        btop            # Modern system monitor (for Waybar CPU/Memory modules)
        gnome-calendar  # Calendar application (for Waybar clock module)
        papirus-icon-theme  # Icon theme (for Waybar taskbar module)
        pacman-contrib  # Pacman tools (provides checkupdates for Waybar updates module)
        wireplumber     # PipeWire session manager (provides wpctl for audio control)
    )

    # NVIDIA-specific packages (2 packages - conditional)
    local nvidia_packages=()
    if [[ "$has_nvidia" == "true" ]]; then
        nvidia_packages=(
            egl-wayland             # Wayland EGL support for NVIDIA
            libva-nvidia-driver     # Hardware acceleration for NVIDIA
        )
    fi

    # AUR packages (2 packages - conditional on yay availability)
    local aur_packages=(
        wlogout         # Wayland logout menu
        overskride      # Bluetooth manager (GTK4, Hyprland-recommended)
    )

    if [[ "$DRY_RUN" != "true" ]]; then
        # Install core Hyprland packages
        log_info "Installing ${#hypr_packages[@]} Hyprland core packages..."
        sudo pacman -S --needed --noconfirm "${hypr_packages[@]}"

        # Install Wayland tools
        log_info "Installing ${#wayland_tools[@]} essential Wayland tools..."
        sudo pacman -S --needed --noconfirm "${wayland_tools[@]}"

        # Install screenshot tools
        log_info "Installing ${#screenshot_tools[@]} screenshot tools..."
        sudo pacman -S --needed --noconfirm "${screenshot_tools[@]}"

        # Install optional packages
        log_info "Installing ${#optional_packages[@]} optional packages..."
        sudo pacman -S --needed --noconfirm "${optional_packages[@]}"

        # Install NVIDIA packages if needed
        if [[ ${#nvidia_packages[@]} -gt 0 ]]; then
            log_info "Installing ${#nvidia_packages[@]} NVIDIA-specific packages..."
            sudo pacman -S --needed --noconfirm "${nvidia_packages[@]}"
        fi

        # Install AUR packages if yay is available
        if command -v yay >/dev/null 2>&1; then
            log_info "Installing ${#aur_packages[@]} AUR packages..."
            yay -S --needed --noconfirm "${aur_packages[@]}"
        else
            log_warning "yay not found. Skipping AUR packages: ${aur_packages[*]}"
            log_info "Install yay to enable AUR package installation"
        fi

        # Verify installation
        if command -v Hyprland >/dev/null 2>&1; then
            log_success "Hyprland installed successfully: $(Hyprland --version | head -1)"
            log_info ""
            log_info "Installed packages:"
            log_info "  - Hyprland core: ${#hypr_packages[@]} packages"
            log_info "  - Wayland tools: ${#wayland_tools[@]} packages"
            log_info "  - Screenshot: ${#screenshot_tools[@]} packages"
            log_info "  - Optional: ${#optional_packages[@]} packages"
            if [[ ${#nvidia_packages[@]} -gt 0 ]]; then
                log_info "  - NVIDIA: ${#nvidia_packages[@]} packages"
            fi
            if command -v yay >/dev/null 2>&1; then
                log_info "  - AUR: ${#aur_packages[@]} packages"
            fi
            log_info ""

            # Create necessary directories
            log_info "Creating Hyprland directories..."
            mkdir -p "${HOME}/Pictures/Screenshots"
            log_success "Created: ~/Pictures/Screenshots"

            # Ensure Hyprland configuration symlinks are created
            log_info "Ensuring Hyprland configuration symlinks..."
            local hyprland_configs=(
                ".config/hypr"
                ".config/waybar"
                ".config/fuzzel"
                ".config/swaync"
                ".config/wlogout"
            )

            for config_path in "${hyprland_configs[@]}"; do
                local target_path="${HOME}/${config_path}"
                local source_path="${DOTFILES_DIR}/${config_path}"

                # Check if dotfiles have this config
                if [[ ! -e "$source_path" ]]; then
                    log_warning "Config not found in dotfiles, skipping: $config_path"
                    continue
                fi

                # Check if already a symlink pointing to dotfiles
                if [[ -L "$target_path" ]]; then
                    local current_target
                    current_target="$(readlink "$target_path")"
                    if [[ "$current_target" == "$source_path" ]]; then
                        log_info "✓ Already symlinked: $config_path"
                        continue
                    fi
                fi

                # Create or update symlink
                if [[ -e "$target_path" ]] && [[ ! -L "$target_path" ]]; then
                    log_warning "Existing directory/file found: $target_path"
                    log_info "Creating symlink (existing file will be backed up)..."
                fi

                create_symlink_from_dotfiles "$config_path" || {
                    log_warning "Failed to create symlink for $config_path"
                    continue
                }
            done
            log_success "Hyprland configuration symlinks ready"

            # Create local.conf for GPU-specific environment variables
            local local_conf="${HOME}/.config/hypr/local.conf"
            log_info "Creating local configuration file..."

            if [[ "$has_nvidia" == "true" ]]; then
                # NVIDIA GPU detected - create local.conf with NVIDIA environment variables
                cat > "$local_conf" << 'EOF'
# =====================================================
# Local Environment Variables (Auto-generated)
# =====================================================
# This file is created automatically during installation
# and is not tracked by git (.gitignore)
#
# NVIDIA GPU detected - NVIDIA-specific environment variables enabled
# =====================================================

# Basic NVIDIA environment
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1

# Hardware video acceleration (VA-API)
env = NVD_BACKEND,direct

# Native Wayland support for Electron/Chromium apps (VSCode, Discord, etc)
env = ELECTRON_OZONE_PLATFORM_HINT,auto

# VRR/G-Sync control (set to 0 to avoid problems in some games)
env = __GL_VRR_ALLOWED,0
EOF
                log_success "Created local.conf with NVIDIA environment variables"
                show_nvidia_setup
            else
                # Intel/AMD GPU - create empty local.conf
                cat > "$local_conf" << 'EOF'
# =====================================================
# Local Environment Variables (Auto-generated)
# =====================================================
# This file is created automatically during installation
# and is not tracked by git (.gitignore)
#
# No NVIDIA GPU detected - using default settings
# =====================================================
EOF
                log_success "Created local.conf (empty - using default settings)"
            fi

            # Create monitors.conf for monitor-specific configuration
            local monitors_conf="${HOME}/.config/hypr/monitors.conf"
            local monitors_example="${HOME}/.config/hypr/monitors.conf.example"
            log_info "Creating monitors configuration file..."

            if [[ ! -f "$monitors_conf" ]]; then
                if [[ -f "$monitors_example" ]]; then
                    cp "$monitors_example" "$monitors_conf"
                    log_success "Created monitors.conf from monitors.conf.example (single display default)"
                    log_info ""
                    log_info "⚠️  IMPORTANT: Configure your monitors!"
                    log_info "  1. Check your monitors: hyprctl monitors"
                    log_info "  2. Edit: ~/.config/hypr/monitors.conf"
                    log_info "  3. Update MONITOR_MAIN to your actual monitor name (e.g., DP-6, HDMI-A-2)"
                    log_info ""
                    log_info "For dual display examples, see:"
                    log_info "  ~/.config/hypr/examples/monitors.conf.dual"
                else
                    log_warning "monitors.conf.example not found, creating basic config"
                    echo "# Monitor configuration - Edit this file" > "$monitors_conf"
                    echo "# Check monitors with: hyprctl monitors" >> "$monitors_conf"
                    echo "monitor=,preferred,auto,1" >> "$monitors_conf"
                fi
            else
                log_info "monitors.conf already exists, skipping creation"
            fi

            log_info "Next steps:"
            log_info "  1. Configure monitors: ~/.config/hypr/monitors.conf"
            log_info "     Check current monitors: hyprctl monitors"
            log_info "  2. Configure keybindings: ~/.config/hypr/hyprland.conf"
            log_info "  3. Start Hyprland: 'Hyprland' (from TTY)"
            log_info "  4. Or use a display manager (GDM, SDDM, etc.)"
            log_info ""
            log_info "Documentation: https://wiki.hyprland.org"
        else
            log_error "Hyprland installation failed"
            return 1
        fi
    else
        log_info "[DRY RUN] Would install:"
        log_info "  - ${#hypr_packages[@]} Hyprland core packages"
        log_info "  - ${#wayland_tools[@]} Wayland tools"
        log_info "  - ${#screenshot_tools[@]} screenshot tools"
        log_info "  - ${#optional_packages[@]} optional packages"
        if [[ ${#nvidia_packages[@]} -gt 0 ]]; then
            log_info "  - ${#nvidia_packages[@]} NVIDIA packages"
        fi
        if command -v yay >/dev/null 2>&1; then
            log_info "  - ${#aur_packages[@]} AUR packages"
        fi
    fi

    return 0
}

# Run installation
install_hyprland "$@"
