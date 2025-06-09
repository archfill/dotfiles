# macOS-specific base configurations

# AWS CLI completion (dynamic path detection)
setup_aws_completion() {
  local aws_completers=(
    "/opt/homebrew/bin/aws_completer"     # Apple Silicon Homebrew
    "/usr/local/bin/aws_completer"        # Intel Homebrew
    "$(command -v aws_completer 2>/dev/null)"  # PATH lookup
  )
  
  for completer in "${aws_completers[@]}"; do
    if [ -f "$completer" ]; then
      complete -C "$completer" aws
      return 0
    fi
  done
}

# Terraform completion (dynamic path detection)
setup_terraform_completion() {
  local terraform_paths=(
    "/opt/homebrew/bin/terraform"        # Apple Silicon Homebrew
    "/usr/local/bin/terraform"           # Intel Homebrew
    "$(command -v terraform 2>/dev/null)"     # PATH lookup
  )
  
  for terraform in "${terraform_paths[@]}"; do
    if [ -f "$terraform" ]; then
      complete -o nospace -C "$terraform" terraform
      return 0
    fi
  done
}

# Initialize completions
setup_aws_completion
setup_terraform_completion

# macOS-specific aliases
alias finder='open .'
alias plistbuddy='/usr/libexec/PlistBuddy'
