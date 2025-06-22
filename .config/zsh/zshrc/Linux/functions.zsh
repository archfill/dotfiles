function fvim() {
  local files
  local selected_files
  
  files=$(git ls-files) &&
  selected_files=$(echo "$files" | fzf -m --preview 'head -100 {}') &&
  vim "$selected_files"
  return "$?"
}
