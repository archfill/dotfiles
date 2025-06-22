function gcloud-activate() {
  local name="$1"
  local project="$2"
  echo "gcloud config configurations activate \"${name}\""
  gcloud config configurations activate "${name}"
  return 0
}
function gx-complete() {
  _values $(gcloud config configurations list | awk '{print $1}')
  return 0
}
function gx() {
  local name="$1"
  local line
  local project
  
  if [[ -z "$name" ]]; then
    line=$(gcloud config configurations list | fzf)
    name=$(echo "${line}" | awk '{print $1}')
  else
    line=$(gcloud config configurations list | grep "$name")
  fi
  
  project=$(echo "${line}" | awk '{print $4}')
  gcloud-activate "${name}" "${project}"
  return 0
}
compdef gx-complete gx

