#!/bin/bash

top=$(git rev-parse --show-toplevel)

#set -x
set -e

# Colors
ESC_SEQ="\e["
COL_RESET=$ESC_SEQ"39m"
COL_RED=$ESC_SEQ"31m"
COL_GREEN=$ESC_SEQ"32m"
COL_YELLOW=$ESC_SEQ"33m"

message() {
  /bin/echo -e "\n${COL_GREEN}*** ${1}${COL_RESET}"
}

ok() {
  /bin/echo -e "${COL_GREEN}[ok]${COL_RESET}"
}

running() {
  /bin/echo -e "${COL_YELLOW} ⇒ ${COL_RESET}${1}: "
  ${1}
}

action() {
  /bin/echo -e "\n${COL_YELLOW}[action]:${COL_RESET}\n ⇒ ${1}..."
}

warn() {
  /bin/echo -e "${COL_YELLOW}[warning]${COL_RESET} ${1}"
}

error() {
  /bin/echo -e "${COL_RED}[error]${COL_RESET} ${1}"
}

cd "$top"

read -r -s -p "[sudo] password for $USER: " PASSWORD
echo ""
TEMPPASSWORD=$(mktemp --tmpdir="${top}" --quiet)
trap 'rm -f "${TEMPPASSWORD}"' EXIT
echo "$PASSWORD" >"${TEMPPASSWORD}"

# shellcheck disable=SC2024
sudo --stdin --validate <"${TEMPPASSWORD}"

message "Checking requirements"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq --yes dirmngr libffi-dev libssl-dev python3-pip python3-dev python3-psutil </dev/null >/dev/null && echo "apt OK"
command -v figlet >/dev/null 2>&1 || {
  message "installing figlet via apt"
  running "sudo apt-get install -qq --yes figlet"
}
command -v lolcat >/dev/null 2>&1 || {
  message "installing lolcat via apt"
  running "sudo apt-get install -qq --yes lolcat"
}

VERSION=$(./version.sh)

clear
{
  figlet "dotfile++"
  echo "    v${VERSION}"
  echo ''
} | lolcat

message "Checking ansible requirements"
command -v ansible >/dev/null 2>&1 || {
  action "ansible not found, installing via pip3"
  running "pip3 install ansible-core"
}
grep -- '  -' requirements.yml | sed -e 's/^.* //' -e 's/\./\//g' | while IFS= read -r dir
do
  if [ ! -d "$HOME/.ansible/collections/ansible_collections/$dir" ]
  then
    running "ansible-galaxy install -r requirements.yml"
  fi
done

running "ansible --version"
ok

command -v git >/dev/null 2>&1 && {
  message "Updating dotfiles"
  umask g-w,o-rwx
  git pull origin master
  # To update to new version of submodule
  #git submodule update --recursive --remote
  git submodule update --recursive
  ok
}

tag_arg=()
if [ -n "${1}" ]
then
  tag_arg[0]="--tags"
  tag_arg[1]="${1}"
fi

if [ -f "$HOME/.gitconfig" ]
then
  firstname=$(grep 'name.*=.*' "$HOME/.gitconfig" | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 1)
  lastname=$(grep 'name.*=.*' "$HOME/.gitconfig" | sed -e 's/.*name\s*=\s//' | cut -d ' ' -f 2)
  email=$(grep 'email.*=.*' "$HOME/.gitconfig" | sed -e 's/.*email\s*=\s//')
  githubuser=$(grep 'user.*=.*' "$HOME/.gitconfig" | sed -e 's/.*user\s*=\s//')
fi

if [ -z "${firstname}" ] || [ -z "${lastname}" ]
then
  firstname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 1)
  lastname=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1 | cut -d ' ' -f 2)

  message "Need some configuration"
  echo "What is ..."
  read -r -p "  ... your first name? " -i "$firstname" -e firstname
  read -r -p "  ... your family name? " -i "$lastname" -e lastname
  read -r -p "  ... your email? " -i "$email" -e email
  read -r -p "  ... your github username? " -i "$githubuser" -e githubuser
fi

gnome_terminal_default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
gnome_terminal_default_profile=${gnome_terminal_default_profile:1:-1}
monitor=$(xrandr | grep '^DP-.*1920x1080+1920+0' | awk '{print $1}')

rm -f "${TEMPPASSWORD}"

message "Starting Ansible Playbook"
export ANSIBLE_CONFIG="${top}/ansible.cfg"
ansible-playbook \
  --inventory "${top}/inventory" \
  --limit localhost \
  --extra-vars="ansible_become_pass=$PASSWORD" \
  --extra-vars="firstname=$firstname" \
  --extra-vars="lastname=$lastname" \
  --extra-vars="email=$email" \
  --extra-vars="githubuser=$githubuser" \
  --extra-vars="username=${USER}" \
  --extra-vars="userid=$(id --user "$USER")" \
  --extra-vars="groupid=$(id --group "$USER")" \
  --extra-vars="homedir=$HOME" \
  --extra-vars="dotdir=$(realpath --relative-to="$HOME" "$top")" \
  --extra-vars="gnome_terminal_default_profile=$gnome_terminal_default_profile" \
  --extra-vars="monitor=$monitor" \
  "${tag_arg[@]}" \
  dotfiles.yml
ok
