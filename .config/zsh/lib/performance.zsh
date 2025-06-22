# ZSH Performance Optimization Library
# Provides caching, efficient PATH management, and optimized file operations

# ===== PERFORMANCE CACHE SYSTEM =====
# Global cache for command existence checks
typeset -Ag _zsh_command_cache

# Cache for directory existence checks
typeset -Ag _zsh_dir_cache

# Cache for file existence checks
typeset -Ag _zsh_file_cache

# Cache for PATH entries
typeset -Ag _zsh_path_cache

# Cache TTL in seconds (default: 300 seconds = 5 minutes)
_ZSH_CACHE_TTL=${_ZSH_CACHE_TTL:-300}

# ===== CACHE UTILITY FUNCTIONS =====
# Get current timestamp
_zsh_timestamp() {
  echo $EPOCHSECONDS
}

# Check if cache entry is valid (not expired)
_zsh_cache_valid() {
  local key="$1"
  local cache_var="$2"
  local current_time=$(_zsh_timestamp)
  
  # Get cached timestamp
  local cached_time=${(P)${cache_var}[$key]}
  
  if [[ -n "$cached_time" ]]; then
    # Check if cache is still valid
    if (( current_time - cached_time < _ZSH_CACHE_TTL )); then
      return 0  # Cache is valid
    fi
  fi
  
  return 1  # Cache is invalid or expired
}

# Set cache entry with timestamp
_zsh_cache_set() {
  local key="$1"
  local value="$2"
  local cache_var="$3"
  local current_time=$(_zsh_timestamp)
  
  # Store value with timestamp
  eval "${cache_var}[$key]='$current_time:$value'"
}

# Get cached value
_zsh_cache_get() {
  local key="$1"
  local cache_var="$2"
  
  local cached_entry=${(P)${cache_var}[$key]}
  if [[ -n "$cached_entry" ]]; then
    echo "${cached_entry#*:}"  # Remove timestamp prefix
  fi
}

# ===== OPTIMIZED COMMAND CHECKING =====
# Fast command existence check with caching
command_exists() {
  local cmd="$1"
  local cache_key="cmd_$cmd"
  
  # Check cache first
  if _zsh_cache_valid "$cache_key" "_zsh_command_cache"; then
    local cached_result=$(_zsh_cache_get "$cache_key" "_zsh_command_cache")
    [[ "$cached_result" == "1" ]] && return 0 || return 1
  fi
  
  # Check command existence
  local result=0
  command -v "$cmd" &>/dev/null || result=1
  
  # Cache result
  _zsh_cache_set "$cache_key" "$result" "_zsh_command_cache"
  
  return $result
}

# ===== OPTIMIZED DIRECTORY CHECKING =====
# Fast directory existence check with caching
dir_exists() {
  local dir="$1"
  local cache_key="dir_$dir"
  
  # Check cache first
  if _zsh_cache_valid "$cache_key" "_zsh_dir_cache"; then
    local cached_result=$(_zsh_cache_get "$cache_key" "_zsh_dir_cache")
    [[ "$cached_result" == "1" ]] && return 0 || return 1
  fi
  
  # Check directory existence
  local result=0
  [[ -d "$dir" ]] || result=1
  
  # Cache result
  _zsh_cache_set "$cache_key" "$result" "_zsh_dir_cache"
  
  return $result
}

# ===== OPTIMIZED FILE CHECKING =====
# Fast file existence check with caching
file_exists() {
  local file="$1"
  local cache_key="file_$file"
  
  # Check cache first
  if _zsh_cache_valid "$cache_key" "_zsh_file_cache"; then
    local cached_result=$(_zsh_cache_get "$cache_key" "_zsh_file_cache")
    [[ "$cached_result" == "1" ]] && return 0 || return 1
  fi
  
  # Check file existence
  local result=0
  [[ -f "$file" ]] || result=1
  
  # Cache result
  _zsh_cache_set "$cache_key" "$result" "_zsh_file_cache"
  
  return $result
}

# ===== OPTIMIZED PATH MANAGEMENT =====
# Check if path is already in PATH with caching
path_contains() {
  local path_to_check="$1"
  local cache_key="path_$path_to_check"
  
  # Check cache first
  if _zsh_cache_valid "$cache_key" "_zsh_path_cache"; then
    local cached_result=$(_zsh_cache_get "$cache_key" "_zsh_path_cache")
    [[ "$cached_result" == "1" ]] && return 0 || return 1
  fi
  
  # Check if path is in PATH
  local result=0
  [[ ":$PATH:" == *":$path_to_check:"* ]] || result=1
  
  # Cache result
  _zsh_cache_set "$cache_key" "$result" "_zsh_path_cache"
  
  return $result
}

# Add path to PATH only if not already present
add_to_path() {
  local new_path="$1"
  local position="${2:-front}"  # front or back
  
  # Early return if path doesn't exist
  if ! dir_exists "$new_path"; then
    return 1
  fi
  
  # Early return if path is already in PATH
  if path_contains "$new_path"; then
    return 0
  fi
  
  # Add to PATH
  if [[ "$position" == "back" ]]; then
    export PATH="$PATH:$new_path"
  else
    export PATH="$new_path:$PATH"
  fi
  
  # Invalidate cache for this path
  local cache_key="path_$new_path"
  unset "_zsh_path_cache[$cache_key]"
  
  return 0
}

# Unified PATH setup function
setup_path_unified() {
  local -a path_entries=("$@")
  local entry
  
  for entry in "${path_entries[@]}"; do
    add_to_path "$entry"
  done
}

# ===== OPTIMIZED FILE SOURCING =====
# Safe file sourcing with caching
source_if_exists() {
  local file="$1"
  
  if file_exists "$file"; then
    source "$file"
    return 0
  fi
  
  return 1
}

# Batch source multiple files
source_files() {
  local -a files=("$@")
  local file
  local sourced_count=0
  
  for file in "${files[@]}"; do
    if source_if_exists "$file"; then
      ((sourced_count++))
    fi
  done
  
  return $sourced_count
}

# ===== OPTIMIZED INITIALIZATION FUNCTIONS =====
# Initialize environment variable only if not already set
init_env_var() {
  local var_name="$1"
  local var_value="$2"
  
  # Early return if already set
  if [[ -n "${(P)var_name}" ]]; then
    return 0
  fi
  
  # Set variable
  export "$var_name"="$var_value"
  return 0
}

# Initialize multiple environment variables
init_env_vars() {
  local -A env_vars=("$@")
  local var_name var_value
  
  for var_name var_value in "${(@kv)env_vars}"; do
    init_env_var "$var_name" "$var_value"
  done
}

# ===== CONDITIONAL EXECUTION OPTIMIZATION =====
# Execute command only if condition is met (short-circuit evaluation)
exec_if() {
  local condition="$1"
  shift
  
  # Early return if condition is false
  if ! eval "$condition"; then
    return 1
  fi
  
  # Execute command
  "$@"
}

# Execute command only if command exists
exec_if_command() {
  local cmd="$1"
  shift
  
  # Early return if command doesn't exist
  if ! command_exists "$cmd"; then
    return 1
  fi
  
  # Execute command
  "$@"
}

# ===== PERFORMANCE MEASUREMENT =====
# Measure function execution time
measure_time() {
  local func_name="$1"
  shift
  
  local start_time=$(_zsh_timestamp)
  "$func_name" "$@"
  local result=$?
  local end_time=$(_zsh_timestamp)
  
  local duration=$((end_time - start_time))
  echo "Function '$func_name' took ${duration}s" >&2
  
  return $result
}

# ===== CACHE MANAGEMENT =====
# Clear all caches
clear_performance_cache() {
  _zsh_command_cache=()
  _zsh_dir_cache=()
  _zsh_file_cache=()
  _zsh_path_cache=()
  echo "Performance cache cleared"
}

# Show cache statistics
show_cache_stats() {
  echo "=== ZSH Performance Cache Statistics ==="
  echo "Command cache entries: ${#_zsh_command_cache}"
  echo "Directory cache entries: ${#_zsh_dir_cache}"
  echo "File cache entries: ${#_zsh_file_cache}"
  echo "PATH cache entries: ${#_zsh_path_cache}"
  echo "Cache TTL: ${_ZSH_CACHE_TTL}s"
}

# ===== INITIALIZATION =====
# Auto-clear expired cache entries on load
_zsh_cleanup_expired_cache() {
  local current_time=$(_zsh_timestamp)
  local cache_name cache_key cached_entry cached_time
  
  # Cleanup each cache type
  for cache_name in "_zsh_command_cache" "_zsh_dir_cache" "_zsh_file_cache" "_zsh_path_cache"; do
    local -A cache_copy
    eval "cache_copy=(\${(kv)${cache_name}})"
    
    for cache_key cached_entry in "${(@kv)cache_copy}"; do
      cached_time="${cached_entry%%:*}"
      if (( current_time - cached_time >= _ZSH_CACHE_TTL )); then
        eval "unset ${cache_name}[$cache_key]"
      fi
    done
  done
}

# Initialize cache cleanup (run on library load)
_zsh_cleanup_expired_cache

# ===== ALIASES FOR BACKWARD COMPATIBILITY =====
alias cmd_exists='command_exists'
alias dir_exists_cached='dir_exists'
alias file_exists_cached='file_exists'
alias path_safe_add='add_to_path'
alias source_safe='source_if_exists'