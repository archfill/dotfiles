# Development SDKs and Version Managers Configuration
# This file configures environment variables and PATH for all development SDKs
# Optimized for performance with caching and early returns

# Load performance optimization library if not already loaded
if ! command -v command_exists &>/dev/null; then
  if [[ -f "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.config/zsh/lib/performance.zsh"
  else
    # Fallback functions if performance library fails to load
    command_exists() { command -v "$1" &>/dev/null; }
    dir_exists() { [[ -d "$1" ]]; }
    add_to_path() { 
      local new_path="$1"
      local position="${2:-front}"
      [[ -d "$new_path" ]] || return 1
      [[ ":$PATH:" == *":$new_path:"* ]] && return 0
      if [[ "$position" == "back" ]]; then
        export PATH="$PATH:$new_path"
      else
        export PATH="$new_path:$PATH"
      fi
    }
    source_if_exists() { [[ -f "$1" ]] && source "$1"; }
    init_env_var() { [[ -z "$(eval echo \$${1})" ]] && export "$1"="$2"; }
    exec_if_command() {
      local cmd="$1"
      shift
      command_exists "$cmd" || return 1
      eval "$@"
    }
  fi
fi

# ===== SDKMAN! (Java, Maven, Gradle) - Optimized =====
if source_if_exists "$HOME/.sdkman/bin/sdkman-init.sh"; then
  # Auto-set JAVA_HOME if available (with error handling)
  if command_exists sdk; then
    java_home_path="$(sdk home java current 2>/dev/null || echo '')"
    [[ -n "$java_home_path" ]] && dir_exists "$java_home_path" && \
      init_env_var "JAVA_HOME" "$java_home_path"
  fi
fi

# Fallback JAVA_HOME detection for manual installations - Optimized
if [[ -z "${JAVA_HOME:-}" ]]; then
  # Platform-specific Java detection with early returns
  java_paths=()
  case "$(uname)" in
    Darwin)
      # macOS - Check common Homebrew locations
      java_paths=(
        "/opt/homebrew/opt/openjdk@21"
        "/opt/homebrew/opt/openjdk@17"
        "/opt/homebrew/opt/openjdk@11"
        "/usr/local/opt/openjdk@21"
        "/usr/local/opt/openjdk@17"
        "/usr/local/opt/openjdk@11"
      )
      ;;
    Linux)
      # Linux - Check common package manager locations
      java_paths=(
        "/usr/lib/jvm/java-21-openjdk-amd64"
        "/usr/lib/jvm/java-21-openjdk"
        "/usr/lib/jvm/java-17-openjdk-amd64"
        "/usr/lib/jvm/java-17-openjdk"
        "/usr/lib/jvm/java-11-openjdk-amd64"
        "/usr/lib/jvm/java-11-openjdk"
        "/usr/lib/jvm/default-java"
      )
      ;;
  esac
  
  # Find first available Java installation (optimized)
  for java_path in "${java_paths[@]}"; do
    if dir_exists "$java_path"; then
      export JAVA_HOME="$java_path"
      break
    fi
  done
fi

# Add JAVA_HOME to PATH if set (optimized)
[[ -n "${JAVA_HOME:-}" ]] && add_to_path "$JAVA_HOME/bin"

# ===== Rust (rustup + Cargo) - Optimized =====
# Rust environment variables (with defaults)
init_env_var "RUSTUP_HOME" "$HOME/.rustup"
init_env_var "CARGO_HOME" "$HOME/.cargo"

# Source Rust environment if available (optimized)
source_if_exists "$CARGO_HOME/env"

# Add Cargo bin to PATH (optimized)
add_to_path "$CARGO_HOME/bin"

# ===== Go (g version manager + official) - Optimized =====
# Go environment variables (with defaults)
init_env_var "GOPATH" "$HOME/go"
init_env_var "GOBIN" "$GOPATH/bin"

# Source g environment if available (optimized)
source_if_exists "$HOME/.g/env"

# Add Go binaries to PATH (optimized)
add_to_path "$GOBIN"

# Fallback GOROOT detection for manual installations - Optimized
if [[ -z "${GOROOT:-}" ]]; then
  local go_paths=(
    "$HOME/.local/go"
    "/usr/local/go"
    "/opt/homebrew/opt/go/libexec"
    "/usr/lib/go"
  )
  
  for go_path in "${go_paths[@]}"; do
    if dir_exists "$go_path" && [[ -x "$go_path/bin/go" ]]; then
      init_env_var "GOROOT" "$go_path"
      add_to_path "$GOROOT/bin"
      break
    fi
  done
fi

# ===== PHP (phpenv) - Optimized =====
init_env_var "PHPENV_ROOT" "$HOME/.phpenv"

# Initialize phpenv if available (optimized)
if dir_exists "$PHPENV_ROOT"; then
  add_to_path "$PHPENV_ROOT/bin"
  add_to_path "$PHPENV_ROOT/shims"
  
  # Initialize phpenv (with error handling)
  exec_if_command phpenv eval "$(phpenv init -)" 2>/dev/null || true
  
  # Ensure Composer global packages are in PATH
  if command_exists phpenv && command_exists php; then
    local composer_bin_path="$(php -r 'echo $_SERVER["HOME"];' 2>/dev/null)/.composer/vendor/bin"
    [[ -d "$composer_bin_path" ]] && add_to_path "$composer_bin_path"
    
    # Alternative Composer global path
    local composer_global_path="$HOME/.config/composer/vendor/bin"
    [[ -d "$composer_global_path" ]] && add_to_path "$composer_global_path"
  fi
fi

# ===== Ruby (rbenv) - Optimized =====
init_env_var "RBENV_ROOT" "$HOME/.rbenv"

# Initialize rbenv if available (optimized)
if dir_exists "$RBENV_ROOT"; then
  add_to_path "$RBENV_ROOT/bin"
  add_to_path "$RBENV_ROOT/shims"
  
  # Initialize rbenv (with error handling)
  exec_if_command rbenv eval "$(rbenv init -)" 2>/dev/null || true
  
  # Ensure gems are in PATH
  if command_exists rbenv && command_exists ruby; then
    local gem_bin_path="$(ruby -e 'puts Gem.user_dir' 2>/dev/null)/bin"
    [[ -d "$gem_bin_path" ]] && add_to_path "$gem_bin_path"
  fi
fi

# ===== Node.js (volta - already configured) =====
# Note: volta is already configured in separate files
# This is just for reference and compatibility

# ===== Python (uv - already configured) =====
# Note: uv is already configured in separate files
# This is just for reference and compatibility

# ===== Flutter/Dart Development Environment - Optimized =====
setup_flutter_environment() {
  # Flutter pub global packages path (optimized)
  add_to_path "$HOME/.pub-cache/bin" "back"
  
  # FVM (Flutter Version Management) global path (optimized)
  add_to_path "$HOME/fvm/default/bin" "back"
  
  # Try different Flutter installation locations (optimized)
  local flutter_paths=(
    "$HOME/development/flutter/bin"        # Manual installation
    "$HOME/.local/flutter/bin"             # Local installation
    "$HOME/flutter/bin"                    # Home directory
    "/opt/homebrew/bin/flutter"            # Homebrew Apple Silicon
    "/usr/local/bin/flutter"               # Homebrew Intel
    "/snap/flutter/current/bin"            # Snap package
    "/usr/local/flutter/bin"               # System-wide installation
    "/opt/flutter/bin"                     # Alternative system location
  )
  
  for flutter_path in "${flutter_paths[@]}"; do
    local flutter_dir="$(dirname "$flutter_path")"
    if dir_exists "$flutter_dir" && [[ -x "$flutter_path" ]]; then
      add_to_path "$flutter_dir"
      
      # Set FLUTTER_ROOT if not already set (optimized)
      init_env_var "FLUTTER_ROOT" "$(dirname "$flutter_dir")"
      
      return 0
    fi
  done
  
  return 1
}

# Initialize Flutter environment (with error handling)
setup_flutter_environment 2>/dev/null || true

# ===== Terraform - Optimized =====
# Terraform binary location detection (optimized)
if ! command_exists terraform; then
  add_to_path "$HOME/.local/bin"
fi

# tfenv (Terraform version manager) if available (optimized)
add_to_path "$HOME/.tfenv/bin"

# Initialize tfenv if available
if dir_exists "$HOME/.tfenv" && command_exists tfenv; then
  # Set up tfenv environment
  export TFENV_ROOT="$HOME/.tfenv"
fi

# Terraform workspace and cache directories
init_env_var "TF_DATA_DIR" "$HOME/.terraform.d"
init_env_var "TF_PLUGIN_CACHE_DIR" "$HOME/.terraform.d/plugin-cache"

# Create plugin cache directory if it doesn't exist
[[ ! -d "${TF_PLUGIN_CACHE_DIR}" ]] && mkdir -p "${TF_PLUGIN_CACHE_DIR}" 2>/dev/null || true

# ===== Docker - Optimized =====
# Docker environment (mostly handled by Docker Desktop/system)
# Add common Docker tool locations to PATH (optimized)
docker_paths=(
  "$HOME/.docker/bin"
  "/usr/local/bin"
  "/usr/bin"
)

for docker_path in "${docker_paths[@]}"; do
  add_to_path "$docker_path"
done

# Docker Compose plugin detection and setup
if command_exists docker; then
  # Docker BuildKit environment variables for better build performance
  init_env_var "DOCKER_BUILDKIT" "1"
  init_env_var "COMPOSE_DOCKER_CLI_BUILD" "1"
  
  # Docker configuration directory
  init_env_var "DOCKER_CONFIG" "$HOME/.docker"
fi

# Container-related tools paths
add_to_path "$HOME/.local/share/containers/bin" # Podman tools
add_to_path "$HOME/.local/bin" # General container tools

# ===== Development Tools PATH Management - Optimized =====
# Ensure ~/.local/bin is in PATH (for user-installed tools)
add_to_path "$HOME/.local/bin"

# ===== SDK Status Functions =====
# Function to check SDK installation status
function sdk_status() {
  echo "=== Development SDKs Status ==="
  echo
  
  # Java (optimized)
  if command_exists java; then
    echo "✅ Java: $(java -version 2>&1 | head -1)"
    echo "   JAVA_HOME: ${JAVA_HOME:-'Not set'}"
  else
    echo "❌ Java: Not installed"
  fi
  
  # Rust (optimized)
  if command_exists rustc; then
    echo "✅ Rust: $(rustc --version)"
    echo "   Cargo: $(cargo --version)"
    echo "   CARGO_HOME: ${CARGO_HOME:-'Not set'}"
  else
    echo "❌ Rust: Not installed"
  fi
  
  # Go (optimized)
  if command_exists go; then
    echo "✅ Go: $(go version)"
    echo "   GOPATH: ${GOPATH:-'Not set'}"
    echo "   GOROOT: ${GOROOT:-'Not set'}"
  else
    echo "❌ Go: Not installed"
  fi
  
  # Node.js (optimized)
  if command_exists node; then
    echo "✅ Node.js: $(node --version)"
    command_exists volta && echo "   Manager: volta $(volta --version)"
  else
    echo "❌ Node.js: Not installed"
  fi
  
  # Python (optimized)
  if command_exists python; then
    echo "✅ Python: $(python --version)"
    command_exists uv && echo "   Manager: uv $(uv --version)"
  else
    echo "❌ Python: Not installed"
  fi
  
  # PHP (optimized)
  if command_exists php; then
    echo "✅ PHP: $(php --version | head -1)"
    command_exists phpenv && echo "   Manager: phpenv $(phpenv --version)"
    command_exists composer && echo "   Composer: $(composer --version --no-ansi | head -1)"
  else
    echo "❌ PHP: Not installed"
  fi
  
  # Ruby (optimized)
  if command_exists ruby; then
    echo "✅ Ruby: $(ruby --version)"
    command_exists rbenv && echo "   Manager: rbenv $(rbenv --version)"
    command_exists gem && echo "   Gem: $(gem --version)"
    command_exists bundler && echo "   Bundler: $(bundler --version)"
  else
    echo "❌ Ruby: Not installed"
  fi
  
  # Flutter/Dart (optimized)
  if command_exists flutter; then
    echo "✅ Flutter: $(flutter --version | head -1)"
    echo "   FLUTTER_ROOT: ${FLUTTER_ROOT:-'Not set'}"
  else
    echo "❌ Flutter: Not installed"
  fi
  
  # Terraform (optimized)
  if command_exists terraform; then
    echo "✅ Terraform: $(terraform version | head -1)"
    command_exists tfenv && echo "   Manager: tfenv"
    echo "   Plugin Cache: ${TF_PLUGIN_CACHE_DIR:-'Not set'}"
  else
    echo "❌ Terraform: Not installed"
  fi
  
  # Docker (optimized)
  if command_exists docker; then
    echo "✅ Docker: $(docker --version)"
    if command_exists docker-compose; then
      echo "   Docker Compose: $(docker-compose --version)"
    elif docker compose version >/dev/null 2>&1; then
      echo "   Docker Compose (plugin): $(docker compose version)"
    fi
    echo "   BuildKit: ${DOCKER_BUILDKIT:-'Not set'}"
  else
    echo "❌ Docker: Not installed"
  fi
  
  echo
  echo "=== Path Information ==="
  echo "PATH directories containing SDK tools:"
  echo "$PATH" | tr ':' '\n' | grep -E "(java|cargo|go|node|python|php|ruby|flutter|terraform|docker)" | sort -u
}

# Function to show SDK versions in a compact format
function sdk_versions() {
  echo "=== Installed SDK Versions ==="
  
  # Create compact version display
  local versions=()
  
  command_exists java && versions+=("Java:$(java -version 2>&1 | head -1 | sed 's/.*"\(.*\)".*/\1/')")
  command_exists rustc && versions+=("Rust:$(rustc --version | awk '{print $2}')")
  command_exists go && versions+=("Go:$(go version | awk '{print $3}' | sed 's/go//')")
  command_exists node && versions+=("Node:$(node --version)")
  command_exists python && versions+=("Python:$(python --version | awk '{print $2}')")
  command_exists php && versions+=("PHP:$(php --version | head -1 | awk '{print $2}')")
  command_exists ruby && versions+=("Ruby:$(ruby --version | awk '{print $2}')")
  command_exists flutter && versions+=("Flutter:$(flutter --version | head -1 | awk '{print $2}')")
  command_exists terraform && versions+=("Terraform:$(terraform version | head -1 | awk '{print $2}' | sed 's/v//')")
  command_exists docker && versions+=("Docker:$(docker --version | awk '{print $3}' | sed 's/,//')")
  command_exists composer && versions+=("Composer:$(composer --version --no-ansi | awk '{print $3}')")
  command_exists bundler && versions+=("Bundler:$(bundler --version | awk '{print $3}')")
  
  # Print versions in columns
  printf "%-12s %-12s %-12s\n" "${versions[@]}"
}

# Aliases for SDK management
# SDK management aliases
alias sdk-status='sdk_status'
alias sdk-versions='sdk_versions'
alias sdk-paths='echo "JAVA_HOME: ${JAVA_HOME:-Not set}"; echo "CARGO_HOME: ${CARGO_HOME:-Not set}"; echo "GOPATH: ${GOPATH:-Not set}"; echo "GOROOT: ${GOROOT:-Not set}"; echo "FLUTTER_ROOT: ${FLUTTER_ROOT:-Not set}"; echo "RBENV_ROOT: ${RBENV_ROOT:-Not set}"; echo "PHPENV_ROOT: ${PHPENV_ROOT:-Not set}"; echo "TF_PLUGIN_CACHE_DIR: ${TF_PLUGIN_CACHE_DIR:-Not set}"; echo "DOCKER_CONFIG: ${DOCKER_CONFIG:-Not set}"'

# Performance optimization aliases
alias perf-cache-clear='clear_performance_cache'
alias perf-cache-stats='show_cache_stats'