# Dotfiles common libraries

`bin/lib` contains the small shared helpers still used by the remaining setup and maintenance scripts.

## Libraries

### `common.sh`

Shared shell utilities:

- `setup_error_handling`
- `log_info`, `log_success`, `log_warning`, `log_error`
- platform detection: `detect_platform`, `get_os_distribution`, `is_wsl`
- command/file checks: `check_command_exists`, `check_file_exists`, `check_dir_exists`
- setup option parsing: `parse_install_options`

### `config_loader.sh`

Loads dotfiles configuration:

- `config/versions.conf`
- `config/personal.conf`
- `.env.local`

Also provides `validate_config`, `show_config`, and personal config template helpers.

### `logger.sh`

Provides `run_with_log` for `make init-log`.

### `README.md`

This file.

## Policy

Keep this directory small. New helpers should only be added when at least two scripts need the same behavior. User-space tools and runtimes should be managed by Nix instead of new installer libraries.
