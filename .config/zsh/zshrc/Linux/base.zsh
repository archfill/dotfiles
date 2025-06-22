# Linux-specific base configurations

# AWS CLI completion (if available)
if command -v aws_completer >/dev/null 2>&1; then
  autoload -U compinit && compinit
  compdef '_arguments "*::aws commands:_command_names"' aws
fi

# Terraform completion (if available)
if command -v terraform >/dev/null 2>&1; then
  autoload -U compinit && compinit
  compdef '_arguments "*::terraform commands:_command_names"' terraform
fi

# Linux-specific aliases
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'  # Ubuntu/Debian bat package name
fi

# systemd shortcuts (if available)
if command -v systemctl >/dev/null 2>&1; then
  alias start='sudo systemctl start'
  alias stop='sudo systemctl stop'
  alias restart='sudo systemctl restart'
  alias status='systemctl status'
  alias enable='sudo systemctl enable'
  alias disable='sudo systemctl disable'
fi