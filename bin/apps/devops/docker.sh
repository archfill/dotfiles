#!/usr/bin/env bash

# Minimal Docker Engine setup for non-NixOS Linux hosts.
# NixOS should use nix/modules/nixos-common.nix instead.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

source "$DOTFILES_DIR/bin/lib/common.sh"
source "$DOTFILES_DIR/bin/lib/install_checker.sh"

setup_error_handling

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] $*"
  else
    "$@"
  fi
}

ensure_systemd_available() {
  if ! command -v systemctl >/dev/null 2>&1 || ! systemctl is-system-running >/dev/null 2>&1; then
    log_warning "systemd is not available; skipping Docker service enable/start"
    return 1
  fi
}

setup_docker_group() {
  local current_user="${USER:-$(whoami)}"

  run_cmd sudo groupadd -f docker
  if ! groups "$current_user" | grep -qw docker; then
    run_cmd sudo usermod -aG docker "$current_user"
    log_info "Added $current_user to docker group. Log out and back in to apply it."
  else
    log_info "$current_user is already in docker group"
  fi
}

enable_docker_service() {
  if ensure_systemd_available; then
    run_cmd sudo systemctl enable --now docker.service
  fi
}

install_docker_arch() {
  log_info "Installing Docker Engine on Arch Linux..."
  run_cmd sudo pacman -Syu --needed --noconfirm docker docker-compose
  enable_docker_service
  setup_docker_group
}

install_docker_debian_ubuntu() {
  log_info "Installing Docker Engine from Docker's official apt repository..."

  run_cmd sudo apt remove -y docker docker-engine docker.io containerd runc
  run_cmd sudo apt update
  run_cmd sudo apt install -y ca-certificates curl gnupg lsb-release

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Add Docker apt key and repository"
  else
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]')/gpg" |
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  fi

  run_cmd sudo apt update
  run_cmd sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  enable_docker_service
  setup_docker_group
}

verify_docker() {
  if [[ "$DRY_RUN" == "true" ]]; then
    return 0
  fi

  if ! command -v docker >/dev/null 2>&1; then
    log_error "docker command was not found"
    return 1
  fi

  log_success "Docker command is available: $(docker --version)"

  if docker compose version >/dev/null 2>&1; then
    log_success "Docker Compose plugin is available: $(docker compose version)"
  elif command -v docker-compose >/dev/null 2>&1; then
    log_success "docker-compose is available: $(docker-compose --version)"
  else
    log_warning "Docker Compose is not available"
  fi

  if docker info >/dev/null 2>&1; then
    log_success "Docker daemon is accessible"
  else
    log_warning "Docker daemon is not accessible yet"
    log_info "If group membership changed, log out and back in."
  fi
}

main() {
  parse_install_options "$@"

  if [[ -e /etc/NIXOS ]]; then
    log_info "NixOS detected. Docker is managed by nix/modules/nixos-common.nix."
    return 0
  fi

  if is_wsl; then
    log_info "WSL detected. Prefer Docker Desktop WSL integration; skipping daemon setup."
    return 0
  fi

  case "$(detect_platform)" in
    macos)
      log_info "macOS detected. Manage Docker Desktop/OrbStack via nix-darwin/Homebrew or install manually."
      return 0
      ;;
    linux)
      case "$(get_os_distribution)" in
        arch) install_docker_arch ;;
        debian | ubuntu) install_docker_debian_ubuntu ;;
        *)
          log_error "Docker setup supports only Arch, Debian, and Ubuntu"
          return 1
          ;;
      esac
      ;;
    *)
      log_error "Unsupported platform for Docker setup"
      return 1
      ;;
  esac

  verify_docker
}

main "$@"
