# macOS-specific base configurations

# AWS CLI completion (Zsh native)
setup_aws_completion() {
  local aws_completer
  aws_completer=$(command -v aws_completer 2>/dev/null)

  if [[ -n "$aws_completer" ]]; then
    autoload -Uz bashcompinit && bashcompinit
    complete -C "$aws_completer" aws
  fi
}

# Terraform completion (Zsh native)
setup_terraform_completion() {
  local terraform
  terraform=$(command -v terraform 2>/dev/null)

  if [[ -n "$terraform" ]]; then
    autoload -Uz bashcompinit && bashcompinit
    complete -o nospace -C "$terraform" terraform
  fi
}

# Initialize completions
setup_aws_completion
setup_terraform_completion

# macOS-specific aliases
alias finder='open .'
alias plistbuddy='/usr/libexec/PlistBuddy'
